open Player
open Command
open Ship
open Board
open Main

(**[print_boards player enemy print] prints the player's [player] board and also
   displays the hits made to the enemy's [enemy] board if [print] is true. 
   Nothing is displayed if [print] is false. *)
let print_boards player enemy print = 
  if print = true then
    begin
      ignore (Sys.command "clear");
      print_double (PlayerMaker.get_board player) (PlayerMaker.get_board enemy); 
      print_endline (PlayerMaker.get_name player ^ 
                     "Your Turn.\nEnter target coordinates"); 
    end 
  else () 

(**[hit_controller player enemy print arg] if [print] is true then the
   current player [player] is allowed to issue commands to attack the enemy 
   player [enemy]. If [print] is false, then the current player gets attacked by
   the enemy at coordinate [arg] *)
let rec hit_controller player enemy print arg= 
  try 
    begin
      let _ = print_boards player enemy print in 
      let rdln = if print = true then read_line () else arg in
      ignore (Sys.command "clear");
      PlayerMaker.hit enemy (Command.find_coords rdln); 
      rdln
    end 
  with
  | BadCoord s 
  | Missed s
  | Hitted s 
  | Invalid_argument s ->
    ignore (read_line (print_endline (s ^ "\nPress Enter to try again.")));
    hit_controller player enemy print arg


(**[process_condition str] loads and displays the text in the file [str] for
   the winning / losing condition.*)
let process_condition str = 
  ignore (Sys.command "clear");
  a_endline (read_txt (open_in str));
  print_endline "Disconnected from server: game over."

(**[win_condition ()] triggers the winning victory screen when called. *)
let win_condition () = 
  process_condition "won.txt"

let hit_handler_outbound player enemy oc =
  let coord = hit_controller player enemy true "N/A" in
  print_double (PlayerMaker.get_board player) (PlayerMaker.get_board enemy); 
  print_endline "Enemy Player's Turn. Please wait...."; 
  if not (PlayerMaker.alive enemy) then
    begin
      ignore (Sys.command "clear");
      output_string oc ("winner " ^PlayerMaker.get_name player ^"\n") ;
      flush oc ; 
      win_condition ();
    end 
  else
    output_string oc ("attacked " ^ coord ^"\n") ;
  flush oc ; ()


let hit_handler_inbound player enemy arg =
  ignore (hit_controller enemy player false arg); ()

(**[create_client_ship] creates a ship [f] and places it on the board [board] 
   with name [name] given a coordinate and the orientation from the user when
   prompted. *)
let rec create_client_ship f name board=
  ignore (Sys.command "clear");
  print_endline ("Place " ^ name);
  print_board (board);
  print_endline "Enter Coordinate and Orientation";
  let rdln = read_line () |> String.trim in 
  let lst = String.split_on_char ' ' rdln in 
  try 
    if List.length lst <> 2 then failwith "Invalid arg num" 
    else
      let ship_constructed = create_general_ship f name board (List.hd lst) 
          (List.hd (List.tl lst))
      in ship_constructed,rdln

  with
  | BadCoord s 
  | Invalid_argument s  
  | Taken s -> 
    ignore (read_line (a_endline (s ^ "\nPress Enter to try again.")));
    create_client_ship f name board
  | _ -> ignore (read_line (a_endline ("Incorrect number of arguments. 
  Make sure it's in the form 'coordinate orientation'  
  \nPress Enter to try again.")));
    create_client_ship f name board


(**[place_enemy_ships board ships args] places down all the ships in [ship] on
   the board [board] using the coordinates in [args] *)
let rec place_enemy_ships board ships args =
  match ships, args with 
  | [],_ -> []
  | (f,name)::t, h::j::k -> create_general_ship f name board h j::
                            place_enemy_ships board t k
  | _ -> failwith "Env "


let create_enemy_player size ships args = 
  let name ="enemy" in 
  let board = BoardMaker.create size size in 
  let ships = place_enemy_ships board ships args in
  PlayerMaker.create ships board name

let create_client_player size ships oc= 
  let board = BoardMaker.create size size in
  let ships_tups = place_ships board ships create_client_ship in 
  let args = List.fold_left (fun accum x -> match x with | (h,t) ->
      accum ^ t ^" ") "" ships_tups in 
  let real_ships = List.fold_left (fun accum x -> match x with | (h,t) -> 
      h::accum) [] ships_tups in 
  ignore (Sys.command "clear"); 
  print_board board;
  output_string oc ("create-enemy "^args^"\n"); 
  flush oc ;
  ignore (Sys.command "clear");
  print_endline "Waiting on Player 2...";
  PlayerMaker.create real_ships board ""

let lobby t = 
  let disconnect_msg = "If you wish to quit the game, please do 'control-c'" in 
  ignore (Sys.command "clear");
  a_endline title; 
  print_endline disconnect_msg;
  if t= true then 
    print_endline "Please wait while others are joining..."
  else 
    print_endline "Please wait while the other player finishes setting 
    up their board..."


let fail_condition () =
  process_condition "lost.txt";
  failwith "You lost!"




