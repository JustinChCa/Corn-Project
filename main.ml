open Player
open Command
open Ship
open Board

let style = [ANSITerminal.white; ANSITerminal.Blink]
let a_endline s = ANSITerminal.print_string style (s ^ "\n")
let read_txt txt = 
  let rec t_help txt = 
    match input_line txt with
    | s -> s ^ "\n" ^ t_help txt
    | exception End_of_file -> close_in txt; "\n" in
  t_help txt

let title = read_txt (open_in "bs.txt")

let switch () = 
  ignore (Sys.command "clear"); 
  ignore (read_line (a_endline "Please switch and hit return."));
  ignore (Sys.command "clear")

let normal_ship (x, y) = function
  | false -> [(x, y); (x+1, y); (x+2,y)]
  | true -> [(x, y); (x, y+1); (x,y+2)]

let l_ship (x,y) = function
  | false -> [(x, y); (x+1, y); (x+2,y); (x+2, y+1)]
  | true -> [(x, y); (x, y+1); (x,y+2); (x+1, y+2)]

let ship (x,y) = function
  | true -> [(x,y)]
  | false -> [(x,y)]

let ships = [(ship, "ship")]

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

let rec hit enemy = 
  try PlayerMaker.hit enemy (Command.find_coords (read_line ())) with
  | BadCoord s 
  | Missed s
  | Hitted s -> a_endline (s ^ "\nPress Enter to try again.");
    hit enemy


let rec create_ship f name board=
  ignore (Sys.command "clear");
  a_endline ("Place " ^ name);
  print_board (board);
  match f (Command.find_coords (read_line())) 
          (Command.orientation (read_line ()))
        |> BoardMaker.taken board
        |> ShipMaker.create 
  with
  | t -> BoardMaker.place_ship board t; t
  | exception BadCoord s 
  | exception Invalid_argument s  
  | exception Taken s ->
    ignore (read_line (a_endline (s ^ "\nPress Enter to try again.")));
    create_ship f name board

let rec place_ships board = function
  | [] -> []
  | (f, name)::t -> create_ship f name board::place_ships board t

let create_player size = 
  ignore (Sys.command "clear");
  a_endline title;
  let name = read_line (a_endline "Enter name for Player: ") in
  let board = BoardMaker.create size size in
  let ships = place_ships board ships in 
  ignore (Sys.command "clear");
  print_board board;
  ignore (read_line (a_endline "This is your board, press enter to continue."));
  Player.PlayerMaker.create ships board name

let start () = 
  ignore (Sys.command "clear");
  a_endline title;
  let size = read_int (a_endline "Enter size of board: ") in
  let p1 = create_player size and p2 = switch (); create_player size in
  switch (); (p1, p2)

let rec turn (player, enemy) =
  let () = 
    (ignore (Sys.command "clear");
     print_double (PlayerMaker.get_board player) (PlayerMaker.get_board enemy); 
     a_endline (PlayerMaker.get_name player ^ "'s Turn.")) in
  ignore (Sys.command "clear");
  hit enemy;
  print_double (PlayerMaker.get_board player) (PlayerMaker.get_board enemy); 
  ignore (read_line (a_endline "Enter to continue.")); 
  if not (PlayerMaker.alive enemy) then 
    a_endline (PlayerMaker.get_name player ^ " wins.")
  else
    (switch (); turn (enemy, player))

let engine () =
  start ()
  |> turn

let main = engine ()











