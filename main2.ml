open Gui
open Graphics
open Player
open Ship
open Board
open Ai


(* (y,x)*)
let normal_ship = ([(0,0);(0,1);(0,2)], "normal ship")
let square_ship = ([(0,0);(0,1);(1,0);(1,1)], "square ship")
let l_ship = ([(0,0);(0,1);(0,2);(1,2)], "L ship")

let ship_list = [normal_ship; square_ship; l_ship]
let ai_list = ([normal_ship;normal_ship;normal_ship;])


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

let rec get_int string l h lim= 
  draw_background ();
  match int_of_string (enter_string 25 700 string 30 lim) with
  | i when i > l && i < h -> i
  | i -> get_int string l h lim
  | exception Failure s -> get_int string l h lim

let continue x y line ts=
  ignore (enter_string x y line ts 0);
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
  | Taken s -> continue 25 650 (s ^ " Press any key to continue.") 15;
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
  continue 25 700 "This is your board, press any key to continue." 15;
  PlayerMaker.create sl board name

let rec hit player enemy x1 y1 x2 y2 size1 size2 bsize = 
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
    continue 25 700 s 15
  with
  | Missed s
  | Invalid_argument s
  | Hitted s -> 
    continue 25 650 (s ^ " Press any key to continue.") 15;
    hit player enemy x1 y1 x2 y2 size1 size2 bsize

let rec turn player enemy x1 y1 x2 y2 size1 size2 bsize=
  hit player enemy x1 y1 x2 y2 size1 size2 bsize;
  if not (PlayerMaker.alive enemy) 
  then 
    PlayerMaker.get_name player |> draw_victory
  else 
    draw_swap (); 
  turn enemy player x1 y1 x2 y2 size1 size2 bsize

let rec ai_turn p aip ai x1 y1 x2 y2 size1 size2 bsize = 
  hit p aip x1 y1 x2 y2 size1 size2 bsize;
  Ai.AiMaker.hit ai (ShipMaker.get_largest (PlayerMaker.get_ships p) 0);
  if not (PlayerMaker.alive aip) then 
    PlayerMaker.get_name p |> draw_victory
  else if not (PlayerMaker.alive p) then
    PlayerMaker.get_name p |> draw_defeat
  else 
    ai_turn p aip ai x1 y1 x2 y2 size1 size2 bsize

let local () = 
  let size = get_int "Enter size (10-26): " 9 27 2 in
  let player1 = create_player 25 700 475 25 800 size ship_list in
  draw_swap ();
  let player2 = create_player 25 700 475 25 800 size ship_list in 
  draw_swap ();
  turn player1 player2 25 25 475 25 400 800 size

let aigame () =
  let diff = get_int "Enter AI difficulty (1-4): " 0 5 1 in 
  let size = get_int "Enter size (10-26): " 9 27 2 in
  let player = create_player 25 700 475 25 800 size ai_list in
  let (aip, ai) = AiMaker.ai_player_init player size ai_list diff in
  ai_turn player aip ai 25 25 475 25 400 800 size

let rec mainmenu () = 
  draw_main_menu ();
  match read_key () with
  | 'w' -> local () 
  | 'a' -> aigame () 
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

let _ = 0
