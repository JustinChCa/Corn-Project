open Graphics
open Images
open Png
open Board
open Player

(** [draw_tile x y r s] draws a tile [s] as a circle (color depending on tile)
    with center at [x, y] and radius [r], point is unchanged. *)
let draw_tile x y r = function
  | "m" -> set_color blue; 
    fill_circle x y r;
    set_color black;
    draw_circle x y r
  | "s" -> set_color green; 
    fill_circle x y r;
    set_color black;
    draw_circle x y r
  | "x" -> set_color red;
    fill_circle x y r;
    set_color black;
    draw_circle x y r
  | "n" -> set_color white; 
    fill_circle x y r;
    set_color black;
    draw_circle x y r
  | _ -> failwith "should not happen"

(** [draw_row x y side row] draws a [row] of tiles scaling by [side] with 
    first circle center at [x, y], point is unchanged. *)
let draw_row x y side row =
  List.iteri (fun i s -> draw_tile (x+(side/2)+(i*side)) y (side/3) s) row

let draw_board board self x y size =
  let board = BoardMaker.to_list board self in
  set_color (rgb 213 229 255);
  fill_rect x y (size) (size);
  set_color black;
  draw_rect x y (size-1) (size-1);
  let side = size / List.length board in
  List.iteri (fun i row -> draw_row x (y+size-(side/2)-(i*side)) side row) board

let draw_field player enemy x1 y1 x2 y2 size1 size2 =
  draw_board player true x1 y1 size1;
  draw_board enemy false x2 y2 size2

let draw_background () =
  let img = Png.load "assets/battleship.png" [] in
  let g = Graphic_image.of_image img in
  resize_window 1300 850;
  draw_image g 0 0

let draw_main_menu () = 
  let img = Png.load "assets/mainmenu.png" [] in
  let g = Graphic_image.of_image img in
  resize_window 800 570;
  draw_image g 0 0

let draw_swap () =
  let img = Png.load "assets/swap.png" [] in
  let g = Graphic_image.of_image img in
  resize_window 1300 850;
  draw_image g 0 0;
  ignore (wait_next_event [Key_pressed])

let draw_alive_ships player =
  Graphics.set_font "-*-fixed-medium-r-semicondensed--20-*-*-*-*-*-iso8859-1";
  set_color white;
  fill_rect 25 450 100 50;
  set_color black;
  draw_rect 25 450 100 100;
  let (x, y) = text_size (PlayerMaker.get_name player) in
  moveto (75 - x/2) (537-y/2);
  draw_string (PlayerMaker.get_name player);
  let (x, y) = text_size ("ships") in
  moveto (75 - x/2) (512-y/2);
  draw_string ("ships");
  let (x, y) = text_size (string_of_int (PlayerMaker.alive_ships player)) in
  moveto (75 - x/2) (475-y/2);
  draw_string (string_of_int (PlayerMaker.alive_ships player))

let draw_backboard board x y size =
  draw_background ();
  draw_board board true x y size

let draw_battlefield player enemy x1 y1 x2 y2 size1 size2 =
  draw_background ();
  draw_field (PlayerMaker.get_board player) (PlayerMaker.get_board enemy) 
    x1 y1 x2 y2 size1 size2;
  draw_alive_ships enemy

(** [endscreen ()] is unit if 'm' is pressed, draws end options and waits.
    Raises Exit if 'q' is pressed. *)
let rec endscreen () = 
  Graphics.set_font "-*-fixed-medium-r-semicondensed--50-*-*-*-*-*-iso8859-1";
  moveto 124 100;
  draw_string "(M)ain Menu      (Q)uit";
  match (wait_next_event [Key_pressed]).key with
  | 'q' -> raise Exit
  | 'm' -> ()
  | _ -> endscreen ()

let draw_victory name =
  let img = Png.load "assets/victory.png" [] in
  let g = Graphic_image.of_image img in
  resize_window 800 800;
  draw_image g 0 0;
  Graphics.set_font "-*-fixed-medium-r-semicondensed--80-*-*-*-*-*-iso8859-1";
  let (x, y) = Graphics.text_size name in
  moveto (400-x/2) 375; 
  draw_string name;
  moveto 324 250;
  draw_string "WINS";
  endscreen ()

let draw_defeat name =
  let img = Png.load "assets/defeat.png" [] in
  let g = Graphic_image.of_image img in
  resize_window 800 800;
  draw_image g 0 0;
  Graphics.set_font "-*-fixed-medium-r-semicondensed--80-*-*-*-*-*-iso8859-1";
  let (x, y) = Graphics.text_size name in
  moveto (400-x/2) 375; 
  draw_string name;
  moveto 305 250;
  draw_string "LOSES";
  endscreen ()

let draw_start () =
  open_graph " 800x570";
  set_window_title "Battleship"