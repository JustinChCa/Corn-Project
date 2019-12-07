open Graphics
open Images
open Png
open Board

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
  | _ ->   set_color white; 
    fill_circle x y r;
    set_color black;
    draw_circle x y r

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

let draw_background () =
  let img = Png.load "assets/battleship.png" [] in
  let g = Graphic_image.of_image img in
  resize_window 1300 850;
  draw_image g 0 0

let draw_main_menu () = 
  let img = Png.load "assets/mainmenu.png" [] in
  let g = Graphic_image.of_image img in
  resize_window 800 800;
  draw_image g 0 0

let draw_start () =
  open_graph " 800x800";
  set_window_title "Battleship";
  draw_main_menu ();
