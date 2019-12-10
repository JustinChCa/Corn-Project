open Gui
open Graphics
open Player
open Ship
open Board
open Ai


(* (y,x)*)
let normal_ship = ([(0,0);(0,1);(0,2)], "normal ship")
let square_ship = ([(0,0);(0,1);(1,0);(1,1)], "square ship")
let l_ship = ([(0,0);(0,1);(0,2);(1,2)], "square ship")

let ship_list = [normal_ship; square_ship; l_ship]

let enter_string x y line ts limit =
  let rec build x =
    if x < limit then
      match read_key () with
      | '\r' -> ""
      | s -> draw_char s; Char.escaped s ^ build (x+1) 
    else "" in

  set_font 
    ("-*-fixed-medium-r-semicondensed--"^
     string_of_int ts^ "-*-*-*-*-*-iso8859-1");
  moveto x y;
  draw_string line;
  build 0

let rec get_coord x y wsize bsize =
  ignore (wait_next_event [Button_down]);
  match mouse_pos () with
  | (a, b) when a-x > 0 && a-x < wsize && b-y > 0 && b-y < wsize ->
    print_int(b);
    bsize - ((b-y) * bsize/wsize) - 1, (a-x) * bsize/wsize
  | _ -> get_coord x y wsize bsize

let rec get_ori () = 
  match read_key () with
  | 'h' -> true
  | 'v' -> false
  | _ -> get_ori () 

let rec get_size () = 
  draw_background ();
  match int_of_string (enter_string 25 700 "Enter size (10-26): " 40 2) with
  | i when i > 9 && i < 27 -> i
  | i -> get_size ()
  | exception Failure s -> get_size ()

let continue x y line =
  ignore (enter_string x y line 20 0);
  ignore (wait_next_event [Key_pressed])

let cs_helper ship board coor orient =
  ShipMaker.ship_pos ship coor orient
  |> BoardMaker.taken board
  |> ShipMaker.create 
  |> BoardMaker.place_ship board

let rec create_ship (ship, name) board x y wsize bsize =
  draw_background ();
  draw_board board true x y wsize;
  ignore (enter_string 25 700 ("Click a spot to to place " ^ name) 20 0);
  let coord = get_coord x y wsize bsize in
  draw_background ();
  draw_board board true x y wsize;
  ignore (enter_string 25 700 "'v' for vertical, 'h' for horizontal" 20 0);
  let orient = get_ori () in
  try cs_helper ship board coord orient with 
  | Invalid_argument s
  | Taken s -> continue 25 650 (s ^ " Press any key to continue.");
    create_ship (ship, name) board x y wsize bsize

let create_player nx ny bx by wsize bsize ships =
  let board = BoardMaker.create bsize bsize in
  draw_background ();
  draw_board board true bx by wsize;
  let name = enter_string nx ny "Enter name: " 30 16 in 
  draw_background ();
  draw_board board true bx by wsize;
  let sl = List.map (fun sn -> create_ship sn board bx by wsize bsize) ships in
  draw_background ();
  draw_board board true bx by wsize;
  continue 25 700 "This is your board, press any key to continue.";
  PlayerMaker.create sl board name

let rec hit player enemy x1 y1 x2 y2 size1 size2 bsize= 
  draw_background ();
  draw_field (PlayerMaker.get_board player) (PlayerMaker.get_board enemy) 
    x1 y1 x2 y2 size1 size2;
  ignore (enter_string 25 700 ((PlayerMaker.get_name player) 
                               ^ "'s turn. Click a spot to to hit.") 20 0);
  let coord = get_coord x2 y2 size2 bsize in
  try 
    let s = match PlayerMaker.hit enemy coord with
      | true -> "You hit. Press any key to continue."
      | false -> "You missed. Press any key to continue." in
    draw_background ();
    draw_field (PlayerMaker.get_board player) (PlayerMaker.get_board enemy) 
      x1 y1 x2 y2 size1 size2;
    continue 25 700 s
  with
  | Missed s
  | Invalid_argument s
  | Hitted s -> 
    continue 25 650 (s ^ " Press any key to continue.");
    hit player enemy x1 y1 x2 y2 size1 size2 bsize

let rec turn player enemy x1 y1 x2 y2 size1 size2 bsize=
  hit player enemy x1 y1 x2 y2 size1 size2 bsize;
  ignore (wait_next_event [Key_pressed]);
  if not (PlayerMaker.alive enemy) 
  then 
    player
  else 
    (draw_swap (); 
     turn enemy player x1 y1 x2 y2 size1 size2 bsize)

let local () = 
  let size = get_size () in
  let player1 = create_player 25 700 475 25 800 size ship_list in
  draw_swap ();
  let player2 = create_player 25 700 475 25 800 size ship_list in 
  draw_swap ();
  turn player1 player2 25 25 475 25 400 800 size

let rec mainmenu () = 
  draw_main_menu ();
  match read_key () with
  | 'w' -> local () |> PlayerMaker.get_name |> draw_victory 
  | 'a' -> failwith "not implemented"
  | 's' -> failwith "not implemented"
  | _ -> mainmenu ()

let main () = 
  draw_start ();
  try
    while true do
      mainmenu ()
    done
  with
  | Exit -> close_graph ()
  | Graphic_failure s -> close_graph ()

let _ = main ()
