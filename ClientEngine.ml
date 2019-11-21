open Player
open Command
open Ship
open Board

let style = [ANSITerminal.white;]
let a_endline s = ANSITerminal.print_string style (s ^ "\n")

let read_txt txt = 
  let rec t_help txt = 
    match input_line txt with
    | s -> s ^ "\n" ^ t_help txt
    | exception End_of_file -> close_in txt; "\n" in
  t_help txt

let title = read_txt (open_in "bs.txt")

(* true is vertical and false is horizonta*)

let normal_ship (x, y) = function
  | true -> [(x, y); (x+1, y); (x+2,y)]
  | false -> [(x, y); (x, y+1); (x,y+2)]

let l_ship (x,y) = function
  | true -> [(x, y); (x+1, y); (x+2,y); (x+2, y+1)]
  | false -> [(x, y); (x, y+1); (x,y+2); (x+1, y+2)]

let dot (x,y) = function
  | true -> [(x,y); (x+1, y)]
  | false -> [(x,y); (x, y+1)]

let ship_list = [(dot, "2 length ship"); (normal_ship, "3 length ship"); 
                 (l_ship, "L ship")]

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

let rec hit_controller player enemy print arg= 
  let print_boards () = 
    if print = true then
      begin
        ignore (Sys.command "clear");
        print_double (PlayerMaker.get_board player) (PlayerMaker.get_board enemy); 
        print_endline (PlayerMaker.get_name player ^ 
                       "Your Turn.\nEnter target coordinates"); 
      end 
    else () 
  in 

  try 
    begin
      let _ = print_boards () in 
      let rdln = if print = true then read_line () else arg in
      ignore (Sys.command "clear");

      match PlayerMaker.hit enemy (Command.find_coords rdln) with 
      | () -> rdln
      | exception  t ->
        ignore (read_line (print_endline ("Already hit the coordinate or Bad Coordinate" ^ "\nPress Enter to try again.")));
        hit_controller player enemy print arg
    end 
  with
  | BadCoord s 
  | Missed s
  | Hitted s -> 
    ignore (read_line (print_endline (s ^ "\nPress Enter to try again.")));
    hit_controller player enemy print arg


let hit_handler_outbound player enemy oc =
  let coord = hit_controller player enemy true "N/A" in
  print_double (PlayerMaker.get_board player) (PlayerMaker.get_board enemy); 
  print_endline "Enemy Player's Turn. Please wait...."; 
  if not (PlayerMaker.alive enemy) then
    begin
      ignore (Sys.command "clear");
      output_string oc ("winner " ^PlayerMaker.get_name player ^"\n") ;
      flush oc ; 
      print_endline ("You win!");
    end 
  else
    output_string oc ("attacked " ^ coord ^"\n") ;
  flush oc ; ()

let hit_handler_inbound player enemy arg =
  ignore (hit_controller enemy player false arg); ()


let rec create_client_ship f name board ic oc=
  ignore (Sys.command "clear");
  print_endline ("Place " ^ name);
  print_board (board);
  print_endline "Enter Coordinate and Orientation";
  let rdln = read_line () |> String.trim in 
  let lst = String.split_on_char ' ' rdln in 
  try 
    if List.length lst <> 2 then failwith "Invalid arg num" 
    else
      let ship_constructed = (f (Command.find_coords (List.hd lst)) 
                                (Command.orientation (List.hd (List.tl lst)))
                              |> BoardMaker.taken board
                              |> ShipMaker.create 
                              |> BoardMaker.place_ship board 
                             ) in


      ship_constructed,rdln

  with
  | BadCoord s 
  | Invalid_argument s  
  | Taken s -> 
    ignore (read_line (a_endline (s ^ "\nPress Enter to try again.")));
    create_client_ship f name board ic oc
  | _ -> ignore (read_line (a_endline ("Incorrect number of arguments. Make sure it's in the form'coordinate orientation '  \nPress Enter to try again.")));
    create_client_ship f name board ic oc


let rec place_client_ships board ships ic oc=
  match ships with 
  | [] -> []
  | (f, name)::t ->

    create_client_ship f name board ic oc:: place_client_ships board t ic oc 

let rec create_enemy_ship f name board coord orient=
  let ship_constructed = (f (Command.find_coords coord) 
                            (Command.orientation orient)
                          |> BoardMaker.taken board
                          |> ShipMaker.create 
                          |> BoardMaker.place_ship board 
                         ) in


  ship_constructed


let rec place_enemy_ships board ships args =
  match ships, args with 
  | [],_ -> []
  | (f,name)::t, h::j::k -> create_enemy_ship f name board h j::place_enemy_ships board t k
  | _ -> failwith "Env "

let create_enemy_player size ships args = 
  let name ="enemy" in 
  let board = BoardMaker.create size size in 
  let ships = place_enemy_ships board ships args in
  PlayerMaker.create ships board name


let create_client_player size ships ic oc= 
  let name = " " in
  let board = BoardMaker.create size size in
  let ships_tups = place_client_ships board ships ic oc in 
  let args = List.fold_left (fun accum x -> match x with | (h,t) -> accum ^ t ^" ") "" ships_tups in 
  let real_ships = List.fold_left (fun accum x -> match x with | (h,t) -> h::accum) [] ships_tups in 
  ignore (Sys.command "clear");
  print_board board;
  output_string oc ("create-enemy "^args^"\n") ;
  flush oc ;
  ignore (Sys.command "clear");
  print_endline "Waiting on Player 2...";
  PlayerMaker.create real_ships board name

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



let lobby t = 
  let disconnect_msg = "If you wish to quit the game, please do 'control-c'" in 
  ignore (Sys.command "clear");
  a_endline title; 
  print_endline disconnect_msg;
  if t= true then 
    print_endline "Please wait while others are joining..."
  else 
    print_endline "Please wait while the other player finishes setting up their board..."






