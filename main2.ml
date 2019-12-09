open Gui
open Graphics
open Player
open Ship
open Board
open Command
open Ai


let normal_ship (y, x) = function
  | true -> [(y,x);(y, x+1); (y, x+2)]
  | false -> [(y,x);(y+1,x);(y+2,x)]

let ship_list = [(normal_ship, "normal")]

let rec get_coord x y wsize bsize =
  ignore (wait_next_event [Button_down]);
  match mouse_pos () with
  | (a, b) when a-x >= 0 && b-y >= 0 -> 
    ((bsize - ((b-y) * bsize)/wsize) - 1 ,((a-x) * bsize)/wsize)
  | _ -> get_coord x y wsize bsize

let enter_string x y line ts limit =
  (let rec build x =
     if x < limit then
       match read_key () with
       | '\r' -> ""
       | s -> draw_char s; Char.escaped s ^ build (x+1) 
     else "" in

   set_text_size 100;
   moveto x y;
   draw_string line;
   build 0)

let create_general_ship f name board coord orient =
  f coord orient
  |> BoardMaker.taken board
  |> ShipMaker.create 
  |> BoardMaker.place_ship board

let rec create_ship f name board x y wsize bsize =
  let rec orientation () = 
    match read_key () with
    | 'h' -> true
    | 'v' -> false
    | _ -> orientation () in
  draw_background ();
  draw_board board true x y wsize;
  ignore (enter_string 25 700 ("Click a spot to to place " ^ name) 30 0);
  let coord = get_coord x y wsize bsize in
  draw_background ();
  draw_board board true x y wsize;
  ignore (enter_string 25 700 "'v' for vertical, 'h' for horizontal" 30 0);
  let orient = orientation () in
  create_general_ship f name board coord orient

let place_ships board ships x y wsize bsize =
  List.map (fun (f, name) -> create_ship f name board x y wsize bsize) ships

let create_player nx ny bx by wsize bsize ships =
  let board = BoardMaker.create bsize bsize in
  draw_background ();
  draw_board board true bx by wsize;
  let name = enter_string nx ny "Enter name: " 20 16 in 
  draw_background ();
  draw_board board true bx by wsize;
  let slist = place_ships board ships bx by wsize bsize in
  draw_background ();
  draw_board board true bx by wsize;
  ignore (wait_next_event [Key_pressed]);
  PlayerMaker.create slist board name

let rec hit player enemy x1 y1 x2 y2 size1 size2 bsize= 
  draw_background ();
  draw_field (PlayerMaker.get_board player) (PlayerMaker.get_board enemy) 
    x1 y1 x2 y2 size1 size2;
  ignore (enter_string 25 700 ("Click a spot to to hit.") 30 0);
  let coord = get_coord x2 y2 size2 bsize in
  try PlayerMaker.hit enemy coord with
  | BadCoord s 
  | Missed s
  | Invalid_argument s
  | Hitted s -> 
    ignore (enter_string 25 650 (s ^ "\nPress any key to continue.") 30 0);
    ignore (wait_next_event [Key_pressed]);
    hit player enemy x1 y1 x2 y2 size1 size2 bsize

let rec turn player enemy x1 y1 x2 y2 size1 size2 bsize=
  hit player enemy x1 y1 x2 y2 size1 size2 bsize;
  draw_background ();
  draw_field (PlayerMaker.get_board player) (PlayerMaker.get_board enemy) 
    x1 y1 x2 y2 size1 size2;
  ignore (wait_next_event [Key_pressed]);
  if not (PlayerMaker.alive enemy) then raise Exit else 
    draw_swap (); turn enemy player x1 y1 x2 y2 size1 size2 bsize

let rec get_size () = 
  match int_of_string (enter_string 25 700 "Enter size (10-26): " 20 2) with
  | i when i > 9 && i < 27 -> i
  | i -> get_size ()
  | exception Failure s -> get_size ()

let local () = 
  draw_background ();
  let size = get_size () in
  let player1 = create_player 25 700 475 25 800 size ship_list in
  draw_swap ();
  let player2 = create_player 25 700 475 25 800 size ship_list in 
  draw_swap ();
  try turn player1 player2 25 25 475 25 400 800 size with
  | Exit -> ()

let rec mainmenu () = 
  match read_key () with
  | 'w' -> local ()
  | 'a' -> failwith "not implemented"
  | 's' -> failwith "not implemented"
  | _ -> mainmenu ()

let main () = 
  try
    draw_start ();
    draw_main_menu ();
    mainmenu ();
    close_graph ()
  with
  | Graphic_failure s -> close_graph ()