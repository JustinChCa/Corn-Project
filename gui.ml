open Graphics
open Images
open Png

let draw_board (size) =
  set_color black;
  moveto 0 0;
  let counter = ref size in
  let move = size_y () / size in
  while !counter > 0 do
    lineto (size_x ()) (current_y ());
    moveto 0 (current_y () + move);
    counter := !counter - 1;
  done 


let main =
  open_graph " 1000x700";
  let img = Png.load "line.png" [] in
  let g = Graphic_image.of_image img in
  draw_image g 0 0;