#require "graphics";;
open Graphics

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


let main () =
  try 
    while true do
      open_graph " 600x600";
      set_window_title "Battleship";
      draw_board (25)

let _ = main ()