open Unix
open Command

type player = {
  player: int;
  ic: in_channel;
  oc: out_channel;
}

type server = {
  port_number:int;
  serv_addr:inet_addr;
  socket_addr: file_descr;
}

type state = | Initialize | Attack | Result


(**[counter] is the users connected to the server *)
let counter = ref 0

(**[player1] is the first player connected to the server *)
let player1 = ref {player=10; ic=Stdlib.stdin;oc=Stdlib.stdout}

(**[player2] is the second player connected to the server. *)
let player2 = ref {player=10; ic=Stdlib.stdin;oc=Stdlib.stdout}

(**[current_state] is the current state of the game *)
let current_state = ref Initialize


let create_player_conn socc = 
  {player= !counter;
   ic = in_channel_of_descr socc; 
   oc = out_channel_of_descr socc}

(**[assign_player socc] creates a connection with the client on their
   socket address [socc]*)
let assign_player socc = 
  if !counter = 0 then 
    begin
      player1 := create_player_conn socc;
    end 
  else 
    player2 := create_player_conn socc


let establish_connections sock_addr = 
  listen sock_addr 8;
  while !counter <> 2 do 
    Unix.accept sock_addr |> fst |> assign_player;
    print_endline ((string_of_int (!counter+1)) ^ " players connected");

    (if !counter = 0 then
       begin    
         output_string !player1.oc "lobby-1\n"; 
         flush !player1.oc 
       end 
     else output_string !player2.oc "lobby-2\n"; 
     flush !player2.oc);
    counter := !counter +1;
  done


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
  let enemy_oc = if id = 0 then !player2.oc else !player1.oc in 
  output_string enemy_oc (command^"\n"); flush enemy_oc 

(**[game_service socc] controls the order in which players may issue commands
   i.e. whose turn it is at any given moment on the server socket [socc] *)
let game_service socc =
  while true do

    print_endline ("player " ^string_of_int !player1.player ^"'s turn");
    control_state !player1.player !player1.ic !player1.oc;
    print_endline ("player " ^string_of_int !player2.player ^"'s turn");
    control_state !player2.player !player2.ic !player2.oc;
    current_state := Attack
  done


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


let sock_dom serv_address port_number = 
  Unix.domain_of_sockaddr (ADDR_INET(serv_address,port_number)) 


let configure_server () = 
  let port_number = 8080 in
  let get_serv_address = 
    match Unix.gethostname () |> Unix.gethostbyname with
    | k -> k.h_addr_list.(0) 
    | exception Not_found -> failwith "Could not find localhost"
  in 
  let dom = sock_dom get_serv_address port_number in 
  let socket_addr = socket dom SOCK_STREAM 0 in 
  {
    port_number = port_number;
    serv_addr = get_serv_address;
    socket_addr = socket_addr;

  }


let run_server () = 
  let serv_info = configure_server () in
  try
    bind serv_info.socket_addr 
      (ADDR_INET(serv_info.serv_addr,serv_info.port_number));
    print_load_message serv_info.serv_addr serv_info.port_number;
    establish_connections serv_info.socket_addr;  
    print_endline "Battleship Game Started...";
    game_service serv_info.socket_addr;
    close serv_info.socket_addr
  with 
    Unix_error (_,_,_) -> print_endline "The server is still shutting down. 
      Please give it at most 1 min to shutdown."; exit 0
  | exc -> 
    shutdown serv_info.socket_addr SHUTDOWN_ALL;
    close serv_info.socket_addr; 
    print_endline "The server has shutdown; Please wait some time before 
      starting the server back up again. Deallocating the sockets may take 
      some time... (~1-2 mins max.)"; exit 0


let start = run_server () 
