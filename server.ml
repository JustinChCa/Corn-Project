open Unix
open Command

(**Player representation in the server module *)
type player = {
  player: int;
  ic: in_channel;
  oc: out_channel;
}

(**State represents the different game states that the battleship game 
   could be in. *)
type state = | Initialize | Attack | Result

module Server = struct 

  (**[counter] is the users connected to the server *)
  let counter = ref 0

  (**[players] is all the players connected to the server. *)
  let players = Array.make 2 {player=10; ic=Stdlib.stdin;oc=Stdlib.stdout}

  (**[current_state] is the current state of the game *)
  let current_state = ref Initialize


  (**[assign_player socc] establishes a connection with the client on their
     socket address [socc]*)
  let assign_player socc = 
    players.(!counter) <-
      {player= !counter;
       ic = in_channel_of_descr socc; 
       oc = out_channel_of_descr socc};
    print_endline ((string_of_int (!counter+1)) ^ " players connected");
    ()


  (**[establish_connections sock_addr] waits until two players have joined
     the server with the socket address [sock_addr]. Records the in_channel and
     out_channel connections for each person who connects to the server. *)
  let establish_connections sock_addr = 
    while !counter <> 2 do 
      Unix.accept sock_addr |> fst |> assign_player;
      (if !counter = 0 then
         begin    
           output_string players.(!counter).oc "lobby-1\n"; 
           flush players.(!counter).oc 
         end 
       else output_string players.(!counter).oc "lobby-2\n"; 
       flush players.(!counter).oc);
      counter := !counter +1;
    done


  (**[issue_command ()] is the current state of the game in string form *)
  let issue_command () =
    match !current_state with 
    | Initialize -> "initialize "
    | Attack -> "attack "
    | Result -> "winner "

  (**[control_state id ic oc] is player [id]'s current turn on the in channel
     [ic] and the out channel [oc] for that player. Tells 
     the server to allow player [id] to issue commands. *)
  let control_state id ic oc=
    output_string oc (issue_command ()^"\n"); flush oc;
    let command = input_line ic in 
    if String.trim command = "quit" then failwith "quit";
    let enemy_oc = if id = 0 then players.(1).oc else players.(0).oc in 
    output_string enemy_oc (command^"\n"); flush enemy_oc 

  (**[game_service socc] controls the order in which players may issue commands
     i.e. whose turn it is at any given moment on the server socket [socc] *)
  let game_service socc =
    while true do

      print_endline ("player " ^string_of_int players.(0).player ^"'s turn");
      control_state players.(0).player players.(0).ic players.(0).oc;
      print_endline ("player " ^string_of_int players.(1).player ^"'s turn");
      control_state players.(1).player players.(1).ic players.(1).oc;
      current_state := Attack
    done

  let get_server_configs () = 
    failwith "DNE"

  (**[print_load_message addr port] prints out important server info including
     the server ip address [addr] and the server port [port]. *)
  let print_load_message addr port = 
    ignore (Sys.command "clear");
    print_endline "Server running...";
    print_endline "\n To end the server use the shortcut 'control-c'   
       Do not use Control-Z!!! \n";
    print_endline ("\nYou're local ip address to connect to the server is: "^ 
                   (Unix.string_of_inet_addr addr) |> String.trim);
    print_endline ("\nYour server port is: "^ (string_of_int port));
    ()

  (**[run_server ()] starts up the server with the hosts local ip address 
     and with a port of 8080.  *)
  let run_server () = 
    let port_number = 8080 in
    let get_serv_address = 
      match Unix.gethostname () |> Unix.gethostbyname with
      | k -> k.h_addr_list.(0) 
      | exception Not_found -> failwith "Could not find localhost"
    in 
    let socket_addr = socket 
        (Unix.domain_of_sockaddr (ADDR_INET(get_serv_address,port_number))) 
        SOCK_STREAM 0 in
    try
      bind socket_addr (ADDR_INET(get_serv_address,port_number));
      listen socket_addr 8;
      print_load_message get_serv_address port_number;
      establish_connections socket_addr;  
      print_endline "Battleship Game Started...";
      while true do 
        game_service socket_addr;
        print_endline "server closing...";
        close socket_addr;
      done;
    with 
      Unix_error (_,_,_) -> print_endline "The server is still shutting down. 
      Please give it at most 1 min to shutdown."; exit 0
    | exc -> 
      shutdown socket_addr SHUTDOWN_ALL;
      close socket_addr; 
      print_endline "The server has shutdown; Please wait some time before 
      starting the server back up again. Deallocating the sockets may take 
      some time... (~1-2 mins max.)"; exit 0

  (**[start] initalizes the server when a user types make server in
     the terminal. *)
  let start = run_server (); 
end 