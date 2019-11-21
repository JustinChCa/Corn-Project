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
    print_endline "\nPlease Type in the server ip address...\n";
    let ip = read_line() in 
    print_endline "\nPlease Type in the server port....\n";

    match int_of_string (read_line()) with 
    | t -> begin 
        match create_socket_connection ip t with 
        | k -> k
        | exception Failure k ->
          print_endline "Could not create connection. Server might not exist. try again.\n"; prompt_connection ()

      end

    | exception Failure j -> 
      print_endline "Bad port; must be a number. Please Re-type\n";
      prompt_connection ()


  let shutdown_connection inchan =
    Unix.shutdown (Unix.descr_of_in_channel inchan) Unix.SHUTDOWN_SEND 


  let step_update ic oc r=
    let parse_command = String.split_on_char ' ' r |> List.hd in 
    match parse_command with 
    | "initialize" -> myself := ClientEngine.create_client_player 10 ClientEngine.ship_list ic oc 
    | "attack" -> hit_handler_outbound !myself !enemy oc
    | "attacked" -> hit_handler_inbound !myself !enemy 
                      (String.split_on_char ' ' r |> List.filter (fun x -> if x= "" then false else true) |> List.tl |> List.hd )
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
    | exn -> shutdown_connection ic; 
      close_in ic;
      print_endline "You have disconnected."; exit 0

  let rec connect () =
    try 

      let socket = prompt_connection () in
      let (ic,oc) = open_connection socket 
      in    
      controller ic oc ;
      shutdown_connection ic;
      close_in ic
    with 
      End_of_file -> print_endline "You quit"; exit 0
    |exn -> print_endline "Connection Refused; try again"; connect ()


  let start = ignore (Sys.command "clear"); connect ()
end