open Unix
open Player
open Board
open ClientEngine

type socket =
  | Socket of (inet_addr * int)

module Client = struct 

  let myself = ref PlayerMaker.empty 
  let enemy = ref PlayerMaker.empty 

  let create_socket_connection ip port= 
    let addr = ip |> inet_addr_of_string in 
    let socket = Unix.ADDR_INET (addr, port) in socket


  let rec prompt_connection ()= 
    print_endline "\nPlease Type in the ip address...\n";
    let ip = read_line() in 
    print_endline "\nPlease Type in the port....\n";

    match int_of_string (read_line()) with 
    | t -> begin 
        match create_socket_connection ip t with 
        | k -> k
        | exception Failure k ->
          print_endline "no connection. try again.\n"; prompt_connection ()

      end

    | exception Failure j -> 
      print_endline "Bad port. Please Re-type\n";
      prompt_connection ()


  let shutdown_connection inchan =
    Unix.shutdown (Unix.descr_of_in_channel inchan) Unix.SHUTDOWN_SEND 


  let attack_handler command = 
    failwith "dne"

  let step_update ic oc r=
    let parse_command = String.split_on_char ' ' r |> List.hd in 
    match parse_command with 
    | "initialize" -> myself := ClientEngine.create_player 10 ClientEngine.ship_list ic oc 
    | "attack" -> hit_handler_outbound !myself !enemy oc
    | "attacked" -> hit_handler_inbound !myself !enemy (String.split_on_char ' ' r |> List.tl |> List.hd )
    | "winner" -> print_endline "you lost"; failwith "game over";
    | "lobby-1" -> lobby true;
    | "lobby-2" -> lobby false;
    | "create-enemy" -> 
      let args = String.split_on_char ' ' r |> List.tl in 
      enemy := ClientEngine.create_enemy_player 10 ClientEngine.ship_list args
    | _ -> failwith "dne" 

  let controller ic oc = 
    try
      while true do
        let r = String.trim (input_line ic) 
        in Printf.printf "Server : %s\n\n" r;
        step_update ic oc r
      done
    with 
      Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn;;

  let client_fun_test ic oc step= 
    try
      while true do  
        print_string  "Request : " ;
        flush Stdlib.stdout ;
        output_string oc ((input_line Stdlib.stdin)^"\n") ;
        flush oc ;

      done
    with 
      Exit -> exit 0
    | exn -> shutdown_connection ic ; raise exn  ;;

  let connect () =
    let socket = prompt_connection () in
    let (ic,oc) = open_connection socket in    
    controller ic oc ;
    shutdown_connection ic

  (* match Unix.fork() with
     | 0 -> print_endline "in progress"
     | _ ->  print_endline "in progress" *)




  let disconnect socc =
    failwith "unimplemented"


  let update_to_server () =
    failwith "unimplemented"




end