
open Ship

module type Board = sig
  type opt = Miss | Hit | Water of ShipMaker.t option
  exception Overlap
  exception OutOfBounds
  type t 
  val make_board: int -> int -> t
  val hit: t -> int*int -> unit
  val dis_board: t -> unit
  val columns: t -> int
  val rows: t -> int
  val place_ship_h: t -> ShipMaker.t -> unit
  val place_ship_v: t -> ShipMaker.t -> unit
end

module BoardMaker = struct


  type opt = Miss| Water of ShipMaker.t option

  exception Overlap
  exception OutOfBounds


  type t = opt array array 

  let make_board x y : t= Array.make_matrix x y (Water None)


  (*  let hit (b:t) (pair:int*int) : unit = 
      match pair with
      |(r, c) -> begin
          match (b.(r)).(c) with 
          | Miss
          | Hit -> print_endline "You have already attacked here"
          (*TODO: go to the next player's turn *)
          | Water op -> begin
              match op with 
              | None -> (b.(r)).(c) <- Miss
              | Some ship -> (b.(r)).(c) <- Hit
            end
        end *)

  (** [h_partition str n] creates the horizontal partition needed for the 
      console command graphic. *)
  let rec h_partition str n = 
    if n > 0 then h_partition (str^"==") (n-1) else str

  (** [opt_to_str x] converts an [opt] to its corresponding string for the 
      console command graphic.*)
  let opt_to_str (rint:int) (cint:int) x = 
    match x with
    |Miss -> print_string "|x"
    |Water None -> print_string "| "
    |Water Some s -> if ShipMaker.calive (rint,cint) s then 
        print_string "|s" else print_string "|o"


  (** [dis_row str r] displays the console command graphic of a row [r].*)
  let dis_row str (rint:int) r  =
    Array.iteri (opt_to_str rint) r;
    print_endline "|";
    print_endline str;;

  (** [dis_board b] gives a console command graphic of the board.*)
  let dis_board (b:t) = 
    let partition = h_partition "=" (Array.length b.(1)) in
    print_endline partition;
    Array.iteri (dis_row partition) b;;

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
        if a+1+(List.length !ship) > (columns b) then 
          raise OutOfBounds else (
          List.iter (check_overlap b) !ship;
          List.iter (place_pair b ship) !ship;)
      end
    |_ -> raise (Invalid_argument "ship is bad")

  let place_ship_v (b:t) (ship:ShipMaker.t) =     
    match !ship with
    | ((a,_),_)::_ -> begin
        if a+1+(List.length !ship) > (rows b) then 
          raise OutOfBounds else (
          List.iter (check_overlap b) !ship;
          List.iter (place_pair b ship) !ship;)
      end
    |_ -> raise (Invalid_argument "ship is bad")

end