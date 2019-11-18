open Unix
open Main
open Command

type request = unit

type response = unit

type player = {
  player: int;
  ic: in_channel;
  oc: out_channel;
}

type state = | Initialize | Attack | Result

module MakeServer = struct 

  let counter = ref 0
  let players = Array.make 2 {player=10; ic=Pervasives.stdin;oc=Pervasives.stdout}
  let current_state = ref Initialize

  let port_number = 1400

  let establish_connections sock_addr = 
    while !counter <> 2 do 
      let (s, _) = Unix.accept sock_addr in
      (**REMOVE AFTER!!!!! *)
      print_endline "socket accepted";
      print_endline ((string_of_int (!counter+1)) ^ " players connected");
      players.(!counter) <-
        {
          player= !counter;
          ic = in_channel_of_descr s;
          oc = out_channel_of_descr s 
        };

      (if !counter = 0 then
         begin    
           output_string players.(!counter).oc "lobby-1\n"; flush players.(!counter).oc end 
       else output_string players.(!counter).oc "lobby-2\n"; flush players.(!counter).oc);
      counter := !counter +1;
    done

  let parse_win output = 
    failwith "dne"

  let issue_command () =
    match !current_state with 
    | Initialize -> "initialize "
    | Attack -> "attack "
    | Result -> "winner "

  let control_state id ic oc=
    output_string oc (issue_command ()^"\n"); flush oc;
    let command = input_line ic in 
    if String.trim command = "quit" then failwith "quit";
    let enemy_oc = if id = 0 then players.(1).oc else players.(0).oc in 
    output_string enemy_oc (command^"\n"); flush enemy_oc 


  let game_service socc =
    try while true do
        Array.iter (fun x -> 
            print_endline ("player " ^string_of_int x.player ^"'s turn");
            control_state x.player x.ic x.oc) players;

        current_state := Attack
      done
    with e -> let msg = Printexc.to_string e
      and stack = Printexc.get_backtrace () in
      Printf.eprintf "there was an error: %s%s\n" msg stack; exit 0 ;;



  let test_service ()=
    try while true do
        Array.iter (fun x -> 
            print_endline (string_of_int x.player);
            let s = input_line x.ic in 
            let r = String.uppercase_ascii s in 
            output_string x.oc (r^"\n"); flush x.oc) players


      done
    with e -> let msg = Printexc.to_string e
      and stack = Printexc.get_backtrace () in
      Printf.eprintf "there was an error: %s%s\n" msg stack; ; exit 0 ;;

  let run_server () = 
    let get_serv_address = 
      match Unix.gethostname () |> Unix.gethostbyname with
      (* | k -> k.h_addr_list.(0)  *)
      | k -> inet_addr_of_string "127.0.0.1"
      | exception Not_found -> failwith "Failure to start server."
    in 
    let socket_addr = socket (Unix.domain_of_sockaddr (ADDR_INET(get_serv_address,port_number))) SOCK_STREAM 0 in
    try
      bind socket_addr (ADDR_INET(get_serv_address,port_number));
      listen socket_addr 5;
      print_endline "Server running...";
      establish_connections socket_addr;  
      print_endline "Battleship Game Started...";
      while true do 

        game_service socket_addr;
        print_endline "server closing...";

        close socket_addr;

      done;
    with exc -> close socket_addr; raise exc




  let close_connection socc= 
    close socc

  let game_service socc state = 
    failwith "unimplemented"

end 