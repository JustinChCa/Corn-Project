(**[orientation] represents the orientation of the desired ship*)
type orientation =
  | Vertical
  | Horizontal

(**[command] represents the types of valid commands in the game engine. *)
type command = 
  | Attack of (int *int)
  | Place of string * (int * int) * orientation
  | Quit
  | Play

(**Raised when a given cordinate cannot be numericaly represented. *)
exception BadCoord of string
let error_bad_coord = "Bad coordinates, must be in the form of L.#."


let chars = Str.regexp "[A-Z]+"
let numbers = Str.regexp "[0-9]+"

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
      | t -> (int_of_string (Str.matched_string line) - 1, 
              int_of_l x (String.length x) - 1)
      | exception Not_found -> raise (BadCoord error_bad_coord) end
  | exception Not_found -> raise (BadCoord error_bad_coord)


let orientation line =
  match String.lowercase_ascii line with 
  | "v"
  | "vertical" -> true
  | "h"
  | "horizontal" -> false
  | _ -> raise (Invalid_argument "Vertical or Horizontal only.")
