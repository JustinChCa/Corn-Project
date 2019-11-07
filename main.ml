open Player
open Commands
open Ship
open Board

let normal_ship (x, y) = function
  | true -> [(x, y); (x+1, y); (x+2,y)]
  | false -> [(x, y); (x, y+1); (x+2,y+1)]

let l_ship (x,y) = function
  | true -> [(x, y); (x+1, y); (x+2,y); (x+2, y+1)]
  | false -> [(x, y); (x, y+1); (x,y+2); (x+1, y)]

let ships = [(l_ship, "L Ship"); (normal_ship, "Normal Ship")]

let rec create_ship f name board=
  print_endline ("Place " ^ name);
  match f (read_int (), read_int ()) (bool_of_string (read_line ()))
        |> BoardMaker.taken board
        |> ShipMaker.create 
  with
  | t -> BoardMaker.place_ship board t; t
  | exception Taken (x, y) -> 
    print_endline (string_of_int x ^ ", " ^ string_of_int y ^ " is taken.");
    create_ship f name board

let rec place_ships board = function
  | [] -> []
  | (f, name)::t -> create_ship f name board::place_ships board t

let start () = 
  print_endline "Welcome to battleship";
  let name1 = read_line(print_endline "Enter name for Player 1: ") in
  let name2 = read_line(print_endline "Enter name for Player 2: ") in
  let size = read_int(print_endline "Enter size of board: ") in
  let board1 = BoardMaker.create size size in
  let board2 = BoardMaker.create size size in
  let ships1 = place_ships board1 ships in 
  let ships2 = place_ships board2 ships in
  (PlayerMaker.create ships1 board1 name1, 
   PlayerMaker.create ships2 board2 name2)

let rec turn (player, enemy) =
  ignore (Sys.command "clear");
  BoardMaker.dis_board (PlayerMaker.get_board enemy) false;
  BoardMaker.dis_board (PlayerMaker.get_board player) true; 
  print_endline (PlayerMaker.get_name player ^ "'s Turn.");
  PlayerMaker.hit enemy;
  if not (PlayerMaker.alive enemy) then 
    print_endline (PlayerMaker.get_name player ^ " wins.")
  else turn (enemy, player)

let engine () =
  start ()
  |> turn

let main = engine ()











