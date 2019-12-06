
open Ship

module type Board = sig
  type tile = Miss | Water of ShipMaker.t option
  type t 
  val create: int -> int -> t
  val hit: t -> int*int -> unit
  val str_board: t -> bool -> string list
  val columns: t -> int
  val rows: t -> int
  val taken : t -> (int * int) list -> (int * int) list
  val place_ship: t -> ShipMaker.t -> ShipMaker.t
  val get_coor: t -> int * int -> ShipMaker.t option
end

exception Missed of string
exception Taken of string

module BoardMaker = struct
  type tile = Miss | Water of ShipMaker.t option
  type t = tile array array 

  let create x y = 
    Array.make_matrix x y (Water None)

  let hit board (y, x) = 
    match board.(y).(x) with
    | Water (None) -> print_endline "You missed"; board.(y).(x) <- Miss
    | Miss -> raise (Missed ("You have already missed this spot."))
    | Water (Some j) -> ShipMaker.hit (y, x) j

  let rec fold f arr i acc =
    match arr.(i) with
    | exception Invalid_argument e -> acc
    | s -> fold f arr (i+1) (f i s acc) 

  (** [h_partition str n] creates the horizontal partition needed for the 
      console command graphic. *)
  let rec h_partition str n = 
    if n > 0 then h_partition (str^"----") (n-1) else str

  (** [opt_to_str x] converts an [opt] to its corresponding string.*)
  let opt_to_str self coor = function
    | Miss -> "| O "
    | Water (None) -> "|   "
    | Water (Some s) -> if ShipMaker.calive coor s then
        begin if self then "| S " else "|   " end else "| X "

  (** [str_row self row y] is the [string] of [row]*)
  let str_row self row y =
    (fold (fun x s acc -> acc ^ opt_to_str self (y, x) s) row 0 "") ^ "|"

  let str_board board self=
    let part = h_partition "-" (Array.length board) in
    List.rev (fold (fun y r acc -> part::str_row self r y::acc) board 0 [part])

  let columns board = Array.length board.(0)

  let rows board = Array.length board

  let rec taken board = function
    | [] -> []
    | (y,x)::t -> match board.(y).(x) with 
      | Water (None) -> (y,x)::taken board t
      | Water (Some j) -> raise (Taken "Ship is overlapping with another.")
      | Miss -> failwith "Miss shouldn't exist yet."

  let place_ship board ship = 
    List.iter (fun (y,x) -> board.(y).(x) <- Water (Some ship)) 
      (ShipMaker.coordinates ship); ship

  let get_coor board (r, c) : ShipMaker.t option = 
    match board.(r).(c) with
    |Miss -> failwith "impossible, hit a missed location again"
    |Water (None) -> None
    |Water (Some s) -> Some s


end

