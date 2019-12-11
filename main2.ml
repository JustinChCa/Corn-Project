open Gui
open Graphics
open Player
open Ship
open Board
open Ai


(** [normal_ship] is a list of coordinates and its name.*)
let normal_ship = ([(0,0);(0,1);(0,2)], "normal ship")
(** [square_ship] is a list of coordinates and its name.*)
let square_ship = ([(0,0);(0,1);(1,0);(1,1)], "square ship")
(** [l_ship] is a list of coordinates and its name.*)
let l_ship = ([(0,0);(0,1);(0,2);(1,2)], "L ship")
(** [ship_list] is a list of ships to use in game.*)
let ship_list = [normal_ship; square_ship; l_ship]
(** [ai_list] is a list of ships to use in vs ai game.*)
let ai_list = ([normal_ship;normal_ship;normal_ship;])


(** [enter_string x y line ts limit] draws a string with [ts] size and [limit]-1
    character inputed and returns a string.*)
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

(** [get_coord x y wsize bsize] senses and return a coordinate pair (y, x)
    based on lower left corner of [x, y] and window and board sizes of 
    [wsize] and [bsize] respectively.*)
let rec get_coord x y wsize bsize =
  ignore (wait_next_event [Button_down]);
  match mouse_pos () with
  | (a, b) when a-x > 0 && a-x < wsize && b-y > 0 && b-y < wsize ->
    print_int(b);
    bsize - ((b-y) * bsize/wsize) - 1, (a-x) * bsize/wsize
  | _ -> get_coord x y wsize bsize

(** [get_ori ()] is true if 'h' is pressed and false when 'v' is pressed.*)
let rec get_ori () = 
  match read_key () with
  | 'h' -> true
  | 'v' -> false
  | _ -> get_ori () 

(** [get_int string l h lim] is between [l] and [h] and total spots less than
    [lim] and draws [string] for input.*)
let rec get_int string l h lim= 
  draw_background ();
  match int_of_string (enter_string 25 700 string 30 lim) with
  | i when i > l && i < h -> i
  | i -> get_int string l h lim
  | exception Failure s -> get_int string l h lim

(** [continue x y line ts] draws [line] with lower left corner at [x,y] and
    text size [ts], waiting for key input.*)
let continue x y line ts=
  ignore (enter_string x y line ts 0);
  ignore (wait_next_event [Key_pressed])

(** [cs_helper ship board coor orient] creates a ship and places it into [board]
    using coordinate list [ship], [board], coordinate pair [coor] and [orient].
*)
let cs_helper ship board coor orient =
  ShipMaker.ship_pos ship coor orient
  |> BoardMaker.taken board
  |> ShipMaker.create 
  |> BoardMaker.place_ship board

(** [create_ship (ship, name) board x y wsize bsize] draws the shipmaking 
    process at lower left corner [x,y] and sides of [wsize] and [board] using
    [bsize] creating and placing ship into [board]. *)
let rec create_ship (ship, name) board x y wsize bsize =
  draw_backboard board x y wsize;
  ignore (enter_string 25 700 ("Click a spot to to place " ^ name) 20 0);
  let coord = get_coord x y wsize bsize in
  draw_backboard board x y wsize;
  ignore (enter_string 25 700 "'v' for vertical, 'h' for horizontal" 20 0);
  let orient = get_ori () in
  try cs_helper ship board coord orient with 
  | Invalid_argument s
  | Taken s -> continue 25 650 (s ^ " Press any key to continue.") 15;
    create_ship (ship, name) board x y wsize bsize

(** [create_player nx ny bx by wsize bsize ships] draws and returns player 
    creation with name and board input using [nx, ny, bx, by, bsize, ships]. *)
let create_player nx ny bx by wsize bsize ships =
  let board = BoardMaker.create bsize bsize in
  draw_backboard board bx by wsize;
  let name = enter_string nx ny "Enter name: " 30 10 in 
  draw_backboard board bx by wsize;
  let sl = List.map (fun sn -> create_ship sn board bx by wsize bsize) ships in
  draw_backboard board bx by wsize;
  continue 25 700 "This is your board, press any key to continue." 15;
  PlayerMaker.create sl board name

(** [hit player enemy x1 y1 x2 y2 size1 size2 bsize] modifies [player] and 
    [enemy] and draws their boards using [x1, y1, size1] and [x2, y2, size2]
    respectively with [bsize] as a guide. *)
let rec hit player enemy x1 y1 x2 y2 size1 size2 bsize = 
  draw_battlefield player enemy x1 y1 x2 y2 size1 size2;
  ignore (enter_string 25 700 ((PlayerMaker.get_name player) 
                               ^ "'s turn. Click a spot to to hit.") 20 0);
  let coord = get_coord x2 y2 size2 bsize in
  try 
    let s = match PlayerMaker.hit enemy coord with
      | true -> "You hit. Press any key to continue."
      | false -> "You missed. Press any key to continue." in
    draw_battlefield player enemy x1 y1 x2 y2 size1 size2;
    continue 25 700 s 15
  with
  | Missed s
  | Invalid_argument s
  | Hitted s -> 
    continue 25 650 (s ^ " Press any key to continue.") 15;
    hit player enemy x1 y1 x2 y2 size1 size2 bsize

(** [hit player enemy x1 y1 x2 y2 size1 size2 bsize] modifies [player] and 
    [enemy] and draws their boards using [x1, y1, size1] and [x2, y2, size2]
    respectively with [bsize] as a guide, also drawing the result screen
    once the game ends. *)
let rec turn player enemy x1 y1 x2 y2 size1 size2 bsize=
  hit player enemy x1 y1 x2 y2 size1 size2 bsize;
  if not (PlayerMaker.alive enemy) 
  then 
    PlayerMaker.get_name player |> draw_victory
  else 
    (draw_swap (); 
     turn enemy player x1 y1 x2 y2 size1 size2 bsize)

(** [hit player enemy x1 y1 x2 y2 size1 size2 bsize] modifies [player] and 
    [ai and aip] and draws their boards using [x1, y1, size1] and [x2, y2, size2]
    respectively with [bsize] as a guide, also drawing the result screen
    once the game ends. *)
let rec ai_turn p aip ai x1 y1 x2 y2 size1 size2 bsize = 
  hit p aip x1 y1 x2 y2 size1 size2 bsize;
  Ai.AiMaker.hit ai (ShipMaker.get_largest (PlayerMaker.get_ships p) 0);
  if not (PlayerMaker.alive aip) then 
    PlayerMaker.get_name p |> draw_victory
  else if not (PlayerMaker.alive p) then
    PlayerMaker.get_name p |> draw_defeat
  else 
    ai_turn p aip ai x1 y1 x2 y2 size1 size2 bsize

(** [local ()] creates a game between 2 human players.*)
let local () = 
  let size = get_int "Enter size (10-26): " 9 27 2 in
  let player1 = create_player 25 700 475 25 800 size ship_list in
  draw_swap ();
  let player2 = create_player 25 700 475 25 800 size ship_list in 
  draw_swap ();
  turn player1 player2 25 25 475 25 400 800 size

(** [aigame ()] creates a game vs an AI.*)
let aigame () =
  let diff = get_int "Enter AI difficulty (1-4): " 0 5 1 in 
  let size = get_int "Enter size (10-26): " 9 27 2 in
  let player = create_player 25 700 475 25 800 size ai_list in
  let (aip, ai) = AiMaker.ai_player_init player size ai_list diff in
  ai_turn player aip ai 25 25 475 25 400 800 size

(** [mainmenu ()] draws the mainmenu for the game.*)
let rec mainmenu () = 
  draw_main_menu ();
  match read_key () with
  | 'w' -> local () 
  | 'a' -> aigame () 
  | 's' -> failwith "not implemented"
  | _ -> mainmenu ()

(** [main ()] runs the mainloop of the game.*)
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
