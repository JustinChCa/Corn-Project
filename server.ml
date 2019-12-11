open Unix
open Command

type socket = 
  {
    in_channel: in_channel;
    out_channel: out_channel
  }

type player = {
  player: string;
  socket: socket
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
let player1 = ref {player="p10"; socket={in_channel=Stdlib.stdin; 
                                         out_channel=Stdlib.stdout}}

(**[player2] is the second player connected to the server. *)
let player2 = ref {player="p10"; socket={in_channel=Stdlib.stdin; 
                                         out_channel=Stdlib.stdout}}

(**[current_state] is the current state of the game *)
let current_state = ref Initialize


let create_player_conn socket name= 
  {player= name;
   socket=
     {in_channel = in_channel_of_descr socket; 
      out_channel = out_channel_of_descr socket}}




(**[assign_player socc] creates a connection with the client on their
   socket address [socc]*)
let assign_player socc = 

  (if !counter = 0 then 
     begin
       player1 := create_player_conn socc "p1";

     end 
   else 
     player2 := create_player_conn socc "p2");

  !counter


let establish_connections server = 
  listen server.socket_addr 8;
  while !counter <> 2 do 
    match accept server.socket_addr |> fst |> assign_player with 
    | 0
    | 1  -> counter := !counter +1
    | _ -> ignore(failwith "Invariant Violated! 2 Players Exceeded!");

  done


let issue_command () =
  match !current_state with 
  | Initialize -> "initialize "
  | Attack -> "attack "
  | Result -> "winner "

(**[player_turn name in_channel out_channel] is player [name]'s current turn 
   on the in channel [in_channel] and the out channel [out_channel] for that 
   player. Tells the server to allow player [name] to issue commands. *)
let player_turn name in_channel out_channel=
  output_string out_channel (issue_command ()^"\n"); flush out_channel;
  let command = input_line in_channel in 
  if String.trim command = "quit" then failwith "quit";
  let enemy_oc = if name = "p1" then !player2.socket.out_channel else 
      !player1.socket.out_channel in 
  output_string enemy_oc (command^"\n"); flush enemy_oc 

(**[bs_service ()] controls the order in which players may issue commands
   i.e. whose turn it is at any given moment on the server socket. *)
let bs_service () =
  while true do

    print_endline ("player " ^ !player1.player ^"'s turn");
    player_turn !player1.player !player1.socket.in_channel 
      !player1.socket.out_channel;

    print_endline ("player " ^ !player2.player ^"'s turn");
    player_turn !player2.player !player2.socket.in_channel 
      !player2.socket.out_channel;

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



let configure_server () = 
  let get_serv_address = 
    match gethostname () |> gethostbyname with
    | k -> k.h_addr_list.(0) 
    | exception Not_found -> failwith "Could not find localhost"
  in 
  {
    port_number = 8080;
    serv_addr = get_serv_address;
    socket_addr = socket PF_INET SOCK_STREAM 0 ;

  }


let run_server () = 
  let serv_info = configure_server () in
  try
    bind serv_info.socket_addr 
      (ADDR_INET(serv_info.serv_addr,serv_info.port_number));
    print_load_message serv_info.serv_addr serv_info.port_number;
    establish_connections serv_info;  
    print_endline "Battleship Game Started...";
    bs_service ();
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

let _ = run_server ()
