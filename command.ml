type orientation =
  | Vertical
  | Horizontal

type command = 
  | Attack of (int *int)
  | Place of string * (int * int) * orientation
  | Quit
  | Play

exception BadCoord of string
let error_bad_coord = "Bad coordinates, must be in the form of L.#."


let chars = Str.regexp "[A-Z]+"
let numbers = Str.regexp "[0-9]+"

(**[int_of_l s c] is the integer coordinate corresponding to the string [s]
   and int [c] in our battleship game *)
let rec int_of_l s c =
  if c = 0 then 0 else
    int_of_float 
      ((float_of_int (Char.code (s.[c-1]) - 64)) *. 
       (26.0 ** float_of_int (String.length s - c))) + int_of_l s (c-1)

let find_coords line = 
  let line = String.uppercase_ascii line in
  match Str.search_forward chars line 0 with
  | t -> let x = Str.matched_string line in begin
      match Str.search_forward numbers line (Str.match_end ()) with
      | t -> (int_of_l x (String.length x) - 1,
              int_of_string (Str.matched_string line) - 1)
      | exception Not_found -> raise (BadCoord error_bad_coord) end
  | exception Not_found -> raise (BadCoord error_bad_coord)


let orientation line =
  match String.trim (String.lowercase_ascii line) with 
  | "v"
  | "vertical" -> true
  | "h"
  | "horizontal" -> false
  | _ -> raise (Invalid_argument "Vertical or Horizontal only.")


(**[convert_coordinate (a,b)] is the string representation of the tuple int
   coordinate [(a,b)].
   Example: (1,2) -> "b3" *)
let convert_coordinate (a,b) = 
  let ascii_char = Char.chr (a+65) |> Char.escaped in 
  let board_num = b+1 in 
  ""^ascii_char^string_of_int board_num


