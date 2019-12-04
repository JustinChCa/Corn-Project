open Unix
open Player
open Board
open ClientEngine

module Client = struct 

  (**[myself] is the current player which connected to the server. *)
  let myself = ref PlayerMaker.empty 

  (**[enemy] is the other player connected to the server.*)
  let enemy = ref PlayerMaker.empty 

  (**[create_socket_connection ip port] creates a client side socket connection 
     to the server with an ip address of [ip] and port [port]*)
  let create_socket_connection ip port= 
    let addr = ip |> inet_addr_of_string in 
    let socket = Unix.ADDR_INET (addr, port) in socket


  (**[one_computer_connection] if the player is hosting the server and 
     playing the game only from one computer using two clients, then this
     automatically connects to the server without having to type in the ip
     and port.*)
  let one_computer_connection () =
    match Unix.gethostname () |> Unix.gethostbyname with 
    | k -> create_socket_connection (string_of_inet_addr 
                                       k.h_addr_list.(0)) 8080
    | exception Not_found -> failwith "Could not find localhost."


  (**[prompt_connection] prompts the user to type in the server ip address and
     the server port and creates a socket connection to the server. *)
  let rec prompt_connection ()= 
    print_endline "\nPlease Type in the server ip address...\n";
    let ip = read_line() in 
    print_endline "\nPlease Type in the server port....\n";

    match int_of_string (read_line()) with 
    | t -> 
      begin 
        match create_socket_connection ip t with 
        | k -> k
        | exception Failure k ->
          print_endline "Could not create connection. 
          Server might not exist. try again.\n"; prompt_connection ()
      end

    | exception Failure j -> 
      print_endline "Bad port; must be a number. Please Re-type\n";
      prompt_connection ()

  (**[shutdown_connection inchan] shutsdown the connection to the server on the
     in_channel [inchan]. This was used from a tutorial online. *)
  let shutdown_connection inchan =
    Unix.shutdown (Unix.descr_of_in_channel inchan) Unix.SHUTDOWN_SEND 

  (**[parse_attack_string r] parses the attack string sent from the server
     into a client side readable format. *)
  let parse_attack_string r = 
    String.split_on_char ' ' r |> List.filter 
      (fun x -> if x= "" then false else true) 
    |> List.tl |> List.hd 

  (**[parse_create_player r bool ic oc] creates a copy of the enemy player's 
     board using the given string [r] if [bool] is false. If [bool] is true, 
     then it creates the current client's player using the in_channel [ic] 
     and the out_channel [oc] *)
  let parse_create_player r bool ic oc= 
    if bool = false then 
      let args = String.split_on_char ' ' r |> List.tl in 
      enemy := ClientEngine.create_enemy_player 10 Main.ship_list args
    else 
      myself := ClientEngine.create_client_player 
          10 Main.ship_list oc 


  (**[gamestate_update ic oc r] parses the command sent from the server [r] and 
     appropriately updates the game state on the in channel [ic] and out channel
     [oc] depending upon the command. *)
  let gamestate_update ic oc r=
    match String.split_on_char ' ' r |> List.hd with 
    | "initialize" -> parse_create_player r true ic oc
    | "attack" -> hit_handler_outbound !myself !enemy oc
    | "attacked" -> hit_handler_inbound !myself !enemy (parse_attack_string r)
    | "winner" -> fail_condition ();
    | "lobby-1" -> lobby true;
    | "lobby-2" -> lobby false;
    | "create-enemy" -> parse_create_player r false ic oc
    | _ -> failwith "Invariant violated" 

  (**[controller ic oc] listens for server commands issued to the client on the
     server in channel [ic] and responds appropriately to the server commands
     on the out channel [oc]. *)
  let controller ic oc = 
    try
      while true do
        String.trim (input_line ic) |>
        gamestate_update ic oc 
      done
    with 
      Exit -> exit 0
    | exn -> shutdown_connection ic; 
      close_in ic;
      print_endline "You have lost connection to the server."; exit 0

  (**[connect] establishes a server connection to the provided server ip
     address and server port given by the user when prompted.*)
  let rec connect () =
    try 
      let socket = one_computer_connection () in
      let (ic,oc) = open_connection socket 
      in    
      controller ic oc ;
      shutdown_connection ic;
      close_in ic
    with 
      End_of_file -> print_endline "You quit"; exit 0;
    | Unix_error (ENOTCONN,_,_) -> print_endline "Lost Connection"; exit 0
    |exn -> print_endline "Connection Refused; Make sure the server is running!
    Try again! "; exit 0

  (**[start] is used to load the make client and runs to function connect () *)
  let start = ignore (Sys.command "clear"); connect ()
end