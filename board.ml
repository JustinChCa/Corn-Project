
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
end

exception Missed of string
exception Taken of string

module BoardMaker = struct
  type tile = Miss | Water of ShipMaker.t option
  type t = tile array array 

  let create x y = 
    Array.make_matrix x y (Water None)

  let hit board (x, y) = 
    match board.(y).(x) with
    | Water (None) -> print_endline "You missed"; board.(y).(x) <- Miss
    | Miss -> raise (Missed ("You have already missed this spot."))
    | Water (Some j) -> ShipMaker.hit (x, y) j

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
    (fold (fun x s acc -> acc ^ opt_to_str self (x, y) s) row 0 "") ^ "|"

  let str_board board self=
    let part = h_partition "-" (Array.length board) in
    List.rev (fold (fun y r acc -> part::str_row self r y::acc) board 0 [part])

  let columns board = Array.length board.(0)

<<<<<<< HEAD
  (* let rec top_axis str n acc = 
     if acc < then top_axis (str^"|"^"") (n-1) else str  *)

  (** [h_partition str n] creates the horizontal partition needed for the 
      console command graphic. *)
  let rec h_partition str n = 
    if n > 0 then h_partition (str^"==") (n-1) else str

  (** [opt_to_str x] converts an [opt] to its corresponding string for the 
      console command graphic.*)
  let opt_to_str self (rint:int) (cint:int) x = 
    match x with
    |Miss -> print_string "|x"
    |Water None -> print_string "| "
    |Water Some s -> if ShipMaker.calive (rint,cint) s then 
        if self then print_string "|s" else print_string "| " 
      else print_string "|o"

  (** [dis_row str r] displays the console command graphic of a row [r].*)
  let dis_row self str (rint:int) r  =
    Array.iteri (opt_to_str self rint) r;
    print_endline "|";
    print_endline str;;

  (* (TODO) display the coordinates on the top and left of the board. *)

  let dis_board (b:t) self = 
    let partition = h_partition "=" (Array.length b.(1)) in
    print_endline partition;
    Array.iteri (dis_row self partition) b;;


  let columns (b:t) = Array.length b.(1)

  let rows (b:t) = Array.length b

  (** [check_overlap b ship pair] checks if there is an overlap between the
      ships in board [b].
      Raises: Overlap if the ship [ship] will overlap with existing ship. *)
  let check_overlap b pair = 
    match b.(fst(fst pair)).(snd (fst pair)) with
    |Water None -> ()
    | _ -> raise Overlap

  (** [place_pair b ship pair] places the ship [ship] into the coordinate
      [pair] in the board [b].
      Raises: Overlap if the ship will overlap with another ship. *)
  let place_pair b ship pair = 
    match b.(fst(fst pair)).(snd (fst pair)) with
    |Water None -> b.(fst(fst pair)).(snd (fst pair)) <- Water (Some ship)
    | _ -> failwith "impossible, check_overlap failed"

  let place_ship_h (b:t) (ship:ShipMaker.t) =
    match !ship with
    | ((_,a),_)::_ -> begin
        if a+(List.length !ship) > (columns b) then 
          raise OutOfBounds else (
          List.iter (check_overlap b) !ship;
          List.iter (place_pair b ship) !ship;)
      end
    |_ -> raise (Invalid_argument "ship is bad")

  let place_ship_v (b:t) (ship:ShipMaker.t) =     
    match !ship with
    | ((a,_),_)::_ -> begin
        if a+(List.length !ship) > (rows b) then 
          raise OutOfBounds else (
          List.iter (check_overlap b) !ship;
          List.iter (place_pair b ship) !ship;)
      end
    |_ -> raise (Invalid_argument "ship is bad")

end
=======
  let rows board = Array.length board

  let rec taken board = function
    | [] -> []
    | (x,y)::t -> match board.(y).(x) with 
      | Water (None) -> (x,y)::taken board t
      | Water (Some j) -> raise (Taken "Ship is overlapping with another.")
      | Miss -> failwith "Miss shouldn't exist yet."

  let place_ship board ship = 
    List.iter (fun (x,y) -> board.(y).(x) <- Water (Some ship)) 
      (ShipMaker.coordinates ship); ship
end

>>>>>>> 0cda0c3d32427f27c55a6fe7b67b8e6773d1e1b5
