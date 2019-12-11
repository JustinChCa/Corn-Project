open Unix
open Player
open Board
open ClientEngine


(**[myself] is the current player which connected to the server. *)
let myself = ref PlayerMaker.empty 

(**[enemy] is the other player connected to the server.*)
let enemy = ref PlayerMaker.empty 


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

(**[parse_attack_string r] parses the attack string sent from the server
   into a client side readable format. *)
let parse_attack_string r = 
  String.split_on_char ' ' r |> List.filter 
    (fun x -> if x= "" then false else true) 
  |> List.tl |> List.hd 

(**[parse_create_player r bool in_channel out_channel] creates a copy of 
   the enemy player's board using the given string [r] if [bool] is false. 
   If [bool] is true, then it creates the current client's player using the 
   in_channel [in_channel] and the out_channel [out_channel] *)
let parse_create_player r bool in_channel out_channel= 
  if bool = false then 
    let args = String.split_on_char ' ' r |> List.tl in 
    enemy := ClientEngine.create_enemy_player 10 Main.ship_list args
  else 
    myself := ClientEngine.create_client_player 
        10 Main.ship_list out_channel 


(**[gamestate_update in_channel out_channel r] parses the command sent 
   from the server [r] and  updates the game state on the in channel 
   [in_channel] and out channel [out_channel] depending upon the command. *)
let gamestate_update in_channel out_channel r=
  match String.split_on_char ' ' r |> List.hd with 
  | "initialize" -> parse_create_player r true in_channel out_channel
  | "attack" -> hit_handler_outbound !myself !enemy out_channel
  | "attacked" -> hit_handler_inbound !myself !enemy (parse_attack_string r)
  | "winner" -> fail_condition ();
  | "lobby-1" -> lobby true;
  | "lobby-2" -> lobby false;
  | "create-enemy" -> parse_create_player r false in_channel out_channel
  | _ -> failwith "Invariant violated" 

(**[controller in_channel out_channel] listens for server commands issued to 
   the client on the server in channel [in_channel] and responds appropriately 
   to the server commands on the out channel [out_channel]. *)
let controller in_channel out_channel = 
  while true do
    match String.trim (input_line in_channel) with
    | t -> gamestate_update in_channel out_channel t
    | exception j -> 
      close_in in_channel;
      print_endline "You have lost connection to the server."; exit 0
  done

(**[connect] establishes a server connection to the provided server ip
   address and server port given by the user when prompted.*)
let rec connect () =
  try 
    match one_computer_connection () |> open_connection with  
    | in_channel, out_channel -> controller in_channel out_channel ;
      close_in in_channel
  with 
    End_of_file -> print_endline "You quit"; exit 0;
  | Unix_error (ENOTCONN,_,_) -> print_endline "Lost Connection"; exit 0
  |exn -> print_endline "Connection Refused; Make sure the server is running!
    Try again! "; exit 0

let start () = ignore (Sys.command "clear"); connect ()

let _ = start ()
