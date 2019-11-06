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



(**Raised when given an invalid command.*)
exception Malformed 

(**Raised when a given cordinate is out of the Board's bounds *)
exception Out_of_Bounds

(**Raised when a given cordinate cannot be numericaly represented. *)
exception Bad_Cordinates

(**Raised when an illegal argument is given. *)
exception Illegal

(**Raised when a desired ship does not exist. *)
exception DNE


(**[find_cordinates args] is the numerical tuple representation of a given string 
   coordinate representation
   Example: "A5" -> "(0,4)"*)
let find_cordinates args = 
  let regex= Str.regexp "^[A-Z][0-9]$\\|^[A-Z][0-9][0-9]$" in 
  let head = args in 
  match Str.search_forward regex head 0 with 
  | exception Not_found -> raise Bad_Cordinates 
  | t -> match Str.matched_string head with
    | k -> let numle = (int_of_char (String.get (String.sub k 0 1) 0)-65) in 
      let num = int_of_string (String.sub k 1 ((String.length k)-1))-1 in
      if num > 25 then raise Out_of_Bounds else (numle, num)


let parse_attack args =
  Attack (find_cordinates (List.hd args))


let parse_place args =
  let get_ship ship = 
    match ship with 
    | "battleship" -> "battleship"
    | "carrier" -> "carrier"
    | "destroyer" -> "destroyer"
    | "sub" -> "sub"
    | "patrol" -> "patrol"
    | _ -> raise DNE
  in 
  let get_orientation org =
    match org with 
    | "vertical" -> Vertical
    | "horizontal" -> Horizontal
    | _ -> raise Malformed
  in 
  let cords = find_cordinates (List.hd args) in 
  let ship = get_ship (args |> List.tl |> List.hd) in
  let orientation = get_orientation (args |> List.tl |> List.tl |> List.hd) in 
  Place (ship,cords,orientation)

(**[parse command] is the command that the user wants to execute given a string
   [command]
   Raises: [Malformed] if the string [command] cannot be parsed to a valid command *)
let parse command =
  let str_lst = String.split_on_char ' ' command in 
  match List.hd str_lst with 
  | "attack" -> if List.length str_lst < 2 then raise Malformed 
    else parse_attack (List.tl str_lst)
  | "quit" -> Quit
  | "play" -> Play
  | "place" -> if List.length str_lst < 4 then raise Malformed else parse_place (List.tl str_lst)
  | _ -> raise Malformed

