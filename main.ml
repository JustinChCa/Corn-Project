open Player
open Command
open Ship
open Board
open Ai

(**[style] is the terminal battleship display style. Displays text as white. *)
let style = [ANSITerminal.white;]
let a_endline s = ANSITerminal.print_string style (s ^ "\n")

let read_txt txt = 
  let rec t_help txt = 
    match input_line txt with
    | s -> s ^ "\n" ^ t_help txt
    | exception End_of_file -> close_in txt; "\n" in
  t_help txt

let title = read_txt (open_in ("assets"^ Filename.dir_sep ^"bs.txt"))

(**[switch ()] clears the terminal and prompts the user to press 
   'Enter' once the players have switched. *)
let switch () = 
  ignore (Sys.command "clear"); 
  ignore (read_line (a_endline "Please switch and hit return."))

(* true is vertical and false is horizonta*)

(**[normal_ship (x,y) bool] is a ship of size 2 starting at the 
   coordinate (x,y) with a vertical orientation if [bool] is true. Horizontal
   if [bool] is false. *)
let normal_ship (x, y) = function
  | true -> [(x, y); (x+1, y); (x+2,y)]
  | false -> [(x, y); (x, y+1); (x,y+2)]

(**[l_ship (x,y) bool] is a ship of size 3 starting at the 
   coordinate (x,y) with a vertical orientation if [bool] is true. Horizontal
   if [bool] is false. *)
let l_ship (x,y) = function
<<<<<<< Updated upstream
  | true -> [(x, y); (x+1, y); (x+2,y); (x+3, y)]
  | false -> [(x, y); (x, y+1); (x,y+2); (x, y+3)]
=======
  | true -> [(x, y); (x+1, y); (x+2,y); (x+3,y)]
  | false -> [(x, y); (x, y+1); (x,y+2); (x,y+3)]
>>>>>>> Stashed changes

(**[dot (x,y) bool] is a ship of size 1 starting at the 
   coordinate (x,y) with a vertical orientation if [bool] is true. Horizontal
   if [bool] is false. *)
let dot (x,y) = function
  | true -> [(x,y); (x+1, y)]
  | false -> [(x,y); (x, y+1)]

let ship_list = [(dot, "2 length ship"); (normal_ship, "3 length ship"); 
                 (l_ship, "destroyer ship")]

(**[combine l1 l2] is the board string representation given the tiles [l1] and 
   tiles [l2].*)
let rec combine l1 l2 =
  match l1, l2 with
  | [], [] -> []
  | h::t, s::x -> (h ^ "          " ^ s)::combine t x
  | _, _ -> failwith "boards of different sizes"

let print_board b =
  BoardMaker.str_board b true 
  |> List.iter (fun x -> a_endline x)

let print_double b1 b2 =
  combine (BoardMaker.str_board b1 true) (BoardMaker.str_board b2 false)
  |> List.iter (fun x -> a_endline x)

(**[hit player enemy] allows player [player] to attack their [enemy] by letting
   them enter their coordinate of attack and subsequently attacking that 
   coordinate. *)
let rec hit player enemy = 
  ignore (Sys.command "clear");
  print_double (PlayerMaker.get_board player) (PlayerMaker.get_board enemy); 
  a_endline (PlayerMaker.get_name player ^ 
             "'s Turn.\nEnter target coordinates");
  try PlayerMaker.hit enemy (Command.find_coords (read_line ())) with
  | BadCoord s 
  | Missed s
  | Invalid_argument s
  | Hitted s -> 
    ignore (read_line (a_endline (s ^ "\nPress Enter to try again.")));
    hit player enemy

let rec create_general_ship f name board coord orient=
  f (Command.find_coords coord) (Command.orientation orient)
  |> BoardMaker.taken board 
  |> ShipMaker.create 
  |> BoardMaker.place_ship board

let rec create_ship f name board=
  ignore (Sys.command "clear");
  a_endline ("Place " ^ name);
  print_board (board);
  try 
    f (Command.find_coords (read_line (a_endline "Enter coordinates:"))) 
      (Command.orientation (read_line (a_endline "Enter orientation:")))
    |> BoardMaker.taken board 
    |> ShipMaker.create  
    |> BoardMaker.place_ship board 
  with
  | BadCoord s 
  | Invalid_argument s  
  | Taken s -> 
    ignore (read_line (a_endline (s ^ "\nPress Enter to try again.")));
    create_ship f name board

let rec place_ships board ships func =
  match ships with 
  | [] -> []
  | (f, name)::t -> func f name board::place_ships board t func

(**[create_player size ships] creates a player with a board size of [size] and 
   ships [ships] on the board. *)
let create_player size ships= 
  ignore (Sys.command "clear");
  a_endline title;
  let name = read_line (a_endline "Enter name for Player: ") in
  let board = BoardMaker.create size size in
  let ships = place_ships board ships create_ship in 
  ignore (Sys.command "clear");
  print_board board;
  ignore (read_line (a_endline "This is your board, press enter to continue."));
  PlayerMaker.create ships board name

(**[turn (player,enemy)] switches the turn of whos allowed to attack 
   between the [player] and the [enemy]. *)
let rec turn (player, enemy) =
  switch ();
  hit player enemy;
  print_double (PlayerMaker.get_board player) (PlayerMaker.get_board enemy); 
  ignore (read_line (a_endline "Enter to continue.")); 
  if not (PlayerMaker.alive enemy) then 
    a_endline (PlayerMaker.get_name player ^ " wins.")
  else
    turn (enemy, player)

(**[get_size] is the board size that the players will use. Asks the users to 
   input their board size. 
   Raises: Failure if the player inputs a negative number.*)
let rec get_size () = 
  ignore (Sys.command "clear");
  a_endline title;
  match read_int (a_endline "Enter size of board: ") with
  | x when x>0 -> x
  | exception Failure s  -> 
    (a_endline "Please enter integers above 0 only. ";
     ignore (read_line (a_endline "Enter to continue.")); get_size ())
  | _ -> 
    (a_endline "Please enter integers above 0 only. ";
     ignore (read_line (a_endline "Enter to continue.")); get_size ())




(**[choose_gamemode ()] allows the user to choose if they want to play
   local multiplayer or play against AI. true if local multiplayer,
    false otherwise.*)
let rec choose_gamemode () = 
  match read_line (a_endline "Choose Gamemode: Local Multiplayer or AI") with
  | "Local Multiplayer"
  | "local multiplayer" -> true
  | "ai"
  | "AI" -> false
  | _ -> a_endline "Not a valid option"; choose_gamemode ()

(**[ai_turn p1 ai] allows the player to attack the AI, which is then followed
   by the AI attacking the player. This is repeated until either the AI or the 
   player wins.
*)
let rec ai_turn (p1,ai_player,ai) = 
  hit p1 ai_player;
  print_double (PlayerMaker.get_board p1) (PlayerMaker.get_board ai_player); 

  Ai.AiMaker.hit ai (ShipMaker.get_largest (PlayerMaker.get_ships p1) 0);
  ignore (read_line (a_endline "Enter to continue.")); 
  if not (PlayerMaker.alive ai_player) then 
    a_endline (PlayerMaker.get_name p1 ^ " wins.")
  else if not (PlayerMaker.alive p1) then
    a_endline (PlayerMaker.get_name ai_player ^ " wins.")
  else 
    ai_turn (p1, ai_player,ai)



(**[ai_initializer size] is a three element tuple that contains the created AI
   with board size [board], the AI Player type, and also the player created by 
   asking the player to place down their ships with a board size of [size].*)
let ai_initializer size diff= 
  let p1 = create_player size ship_list in 
  let ai_board = BoardMaker.create size size in
  let ai_ships = place_ships ai_board ship_list Ai.AiMaker.ai_create_ship in 
  let ai = Ai.AiMaker.ai_init diff 
      (PlayerMaker.get_board p1) ai_board ai_ships in 
  let ai_player = PlayerMaker.create ai_ships ai_board "AI" in 
  p1, ai_player, ai

(**[prompt_ai_difficulty ()] is the integer which corresponds to the AI 
   difficulty that the player has chosen. *)
let rec prompt_ai_difficulty () = 
  match read_int (a_endline "Choose difficulty:
   1 - Dumb, 2- Normal, 3- Smart, 4- Expert") with 
  | k when k < 5 && k >= 0-> k
  | _ -> a_endline "Please type an appropriate int"; prompt_ai_difficulty ()

let main () =
  ignore (Sys.command "clear");
  let size = get_size () in
  let mode = choose_gamemode () in
  if mode then 
    let p1 = create_player size ship_list
    and p2 = switch (); create_player size ship_list in
    turn (p1, p2)
  else 
    prompt_ai_difficulty () |> ai_initializer size |> ai_turn 













