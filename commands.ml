type command = 
  | Attack of (int *int)
  | Place of (int * int) * string
  | Quit

exception Malformed 

exception Out_of_Bounds

exception Bad_Cordinates

exception Illegal



let parse_attack args =
  let regex= Str.regexp "^[A-Z][0-9]$\\|^[A-Z][0-9][0-9]$" in 
  let head = List.hd args in 
  match Str.search_forward regex head 0 with 
  | exception Not_found -> raise Bad_Cordinates 
  | t -> match Str.matched_string head with
    | k -> let numle = (int_of_char (String.get (String.sub k 0 1) 0)-65) in 
      let num = int_of_string (String.sub k 1 ((String.length k)-1))-1 in
      if num > 25 then raise Out_of_Bounds else 
        Attack (numle, num)


let parse command =
  let str_lst = String.split_on_char ' ' command in 
  match List.hd str_lst with 
  | "attack" -> parse_attack (List.tl str_lst)
  | "quit" -> Quit
  | _ -> raise Malformed

