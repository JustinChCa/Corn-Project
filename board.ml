
open Ship

module Board = struct

  type opt = Miss | Hit | Water of ShipMaker.t option

  (**AF: The array [| r1; r2; r3; r4;... |] is the array of the row arrays
     ri = [|ai1; ai2; ai3; ai4; ... |] which represents the elements in left to 
     right order of the elements in that row. aij is the element in the ith row
     and the jth column of a matrix of dimensions ixj.
     RI: All rows are the same size and all columns are the same size. Every
     element of the array must contain an element of type opt.*)
  type t = (opt array) array 

  (** [make_board x y] makes a matrix with [x] rows and [y] columns with every 
      element in the matrix being [Water None]. *)
  let make_board x y = Array.make_matrix x y (Water None)

  (** [hit b pair] augments the board [b] based on an attack on the
      coordinates [pair]. Returns a message that the player has already
      attacked an area if they input that coordinate; the plyaer will not get 
      another turn if they do. *)
  let hit (b:t) (pair:int*int) : unit = 
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
      end

  (** [h_partition str n] creates the horizontal partition needed for the 
      console command graphic. *)
  let rec h_partition str n = 
    if n > 0 then h_partition (str^"==") (n-1) else str

  (** [opt_to_str x] converts an [opt] to its corresponding string for the 
      console command graphic.*)
  let opt_to_str x = 
    match x with
    |Miss -> print_string "|x"
    |Hit -> print_string "|o"
    |Water None -> print_string "| "
    |Water Some _ -> print_string "|s"

  (** [dis_row str r] displays the console command graphic of a row [r].*)
  let dis_row str r =
    Array.iter opt_to_str r;
    print_endline "|";
    print_endline str;;

  (** [dis_board b] gives a console command graphic of the board.*)
  let dis_board b = 
    let partition = h_partition "" (Array.length b.(1)) in
    print_string partition;
    Array.iter (dis_row partition) b;;



  (** [columns b] gives the number of columns in the board [b]. This is equal to
      the size of each row in [b] *)
  let columns b = Array.length b.(1)


  (** [rows b] gives the number of rows in the board [b]. This is equal to the
      size of each column in [b]  *)
  let rows b = Array.length b



  let place_ship b ship = failwith "unimplemented"


end