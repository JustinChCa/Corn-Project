
open Ship

module type Board = sig
  type tile = Miss | Water of ShipMaker.t option
  type t 
  val create: int -> int -> t
  val hit: t -> int*int -> unit
  val dis_board: t -> bool -> unit
  val columns: t -> int
  val rows: t -> int
  val taken : t -> (int * int) list -> (int * int) list
  val place_ship: t -> ShipMaker.t -> unit
end

exception Missed of int * int
exception Taken of int * int

module BoardMaker = struct
  type tile = Miss | Water of ShipMaker.t option
  type t = tile array array 

  let create x y = 
    Array.make_matrix x y (Water None)

  let hit board (x, y) = 
    match board.(x).(y) with
    | Water (None) -> print_endline "You missed"; board.(x).(y) <- Miss
    | Miss -> raise (Missed (x, y))
    | Water (Some j) -> ShipMaker.hit (x, y) j

  (** [h_partition str n] creates the horizontal partition needed for the 
      console command graphic. *)
  let rec h_partition str n = 
    if n > 0 then h_partition (str^"==") (n-1) else str

  (** [opt_to_str x] converts an [opt] to its corresponding string for the 
      console command graphic.*)
  let opt_to_str self (rint:int) (cint:int) x = 
    match x with
    |Miss -> print_string "|o"
    |Water None -> print_string "| "
    |Water Some s -> if ShipMaker.calive (rint,cint) s then 
        if self then print_string "|s" else print_string "| " 
      else print_string "|x"

  (** [dis_row str r] displays the console command graphic of a row [r].*)
  let dis_row self str (rint:int) r  =
    Array.iteri (opt_to_str self rint) r;
    print_endline "|";
    print_endline str;;

<<<<<<< HEAD
  let dis_board board self = 
    let partition = h_partition "-" (Array.length board.(0)) in
=======
  (* (TODO) display the coordinates on the top and left of the board. *)

  let dis_board (b:t) self = 
    let partition = h_partition "=" (Array.length b.(1)) in
>>>>>>> 6415c48b2a48871eb8af84df9194873bedd736cd
    print_endline partition;
    Array.iteri (dis_row self partition) board;;

  let columns board = Array.length board.(0)

  let rows board = Array.length board

  let rec taken board = function
    | [] -> []
    | (x,y)::t -> match board.(x).(y) with 
      | Water (None) -> (x,y)::taken board t
      | Water (Some j) -> raise (Taken (x, y))
      | Miss -> failwith "Miss shouldn't exist yet."

  let place_ship board ship = 
    List.iter (fun (x,y) -> board.(x).(y) <- Water (Some ship)) 
      (ShipMaker.coordinates ship)

end