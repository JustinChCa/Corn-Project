open Unix
open Command

type player = {
  player: int;
  ic: in_channel;
  oc: out_channel;
}

type state = | Initialize | Attack | Result

module Server = struct 

  let counter = ref 0
  let players = Array.make 2 {player=10; ic=Stdlib.stdin;oc=Stdlib.stdout}
  let current_state = ref Initialize

  let establish_connections sock_addr = 
    while !counter <> 2 do 
      let (socc, _) = Unix.accept sock_addr in
      players.(!counter) <-
        {
          player= !counter;
          ic = in_channel_of_descr socc;
          oc = out_channel_of_descr socc
        };
      print_endline ((string_of_int (!counter+1)) ^ " players connected");


      (if !counter = 0 then
         begin    
           output_string players.(!counter).oc "lobby-1\n"; flush players.(!counter).oc 
         end 
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
    while true do

      print_endline ("player " ^string_of_int players.(0).player ^"'s turn");
      control_state players.(0).player players.(0).ic players.(0).oc;
      print_endline ("player " ^string_of_int players.(1).player ^"'s turn");
      control_state players.(1).player players.(1).ic players.(1).oc;
      current_state := Attack
    done

  let configure_server () = 
    failwith "DNE"

  let run_server () = 
    let port_number = 8080 in
    let get_serv_address = 
      match Unix.gethostname () |> Unix.gethostbyname with
      | k -> k.h_addr_list.(0) 
      (* | k -> inet_addr_of_string "127.0.0.1" *)
      | exception Not_found -> failwith "Failure to start server; Could not find localhost"
    in 
    let socket_addr = socket (Unix.domain_of_sockaddr (ADDR_INET(get_serv_address,port_number))) SOCK_STREAM 0 in
    try
      bind socket_addr (ADDR_INET(get_serv_address,port_number));
      listen socket_addr 8;
      ignore (Sys.command "clear");
      print_endline "Server running...";
      print_endline "\n To end the server use the shortcut 'control-c'    Do not use Control-Z! \n";
      print_endline ("\nYou're local ip address to connect to the server is: "^ (Unix.string_of_inet_addr get_serv_address) |> String.trim);
      print_endline ("\nYour server port is: "^ (string_of_int port_number));
      establish_connections socket_addr;  
      print_endline "Battleship Game Started...";
      while true do 

        game_service socket_addr;
        print_endline "server closing...";

        close socket_addr;

      done;
    with exc -> 
      shutdown socket_addr SHUTDOWN_ALL;
      close socket_addr; 
      print_endline "The server has shutdown; Please wait some time before starting the server back up again.
      Deallocating the sockets may take some time... (~1-2 mins max.)"; exit 0

  let start = run_server (); 
end 