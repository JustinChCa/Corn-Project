open Ship

module type Board = sig

  (** type [opt] is the possible types of each space in the board. *)
  type opt = Miss | Water of ShipMaker.t option

  exception Overlap
  exception OutOfBounds

  (**AF: The array [| r1; r2; r3; r4;... |] is the array of the row arrays
     ri = [|ai1; ai2; ai3; ai4; ... |] which represents the elements in left to 
     right order of the elements in that row. aij is the element in the ith row
     and the jth column of a matrix of dimensions ixj.
     RI: All rows are the same size and all columns are the same size. Every
     element of the array must contain an element of type opt.*)
  type t 

  (** [make_board x y] makes a matrix with [x] rows and [y] columns with every 
      element in the matrix being [Water None]. *)
  val make_board: int -> int -> t

  (* (** [hit b pair] augments the board [b] based on an attack on the
      coordinates [pair]. Returns a message that the player has already
      attacked an area if they input that coordinate; the player will not get 
      another turn if they do. *)
     val hit: t -> int*int -> unit *)

  (** [dis_board b] displays the board in graphical form in the console command
      window. *)
  val dis_board: t -> unit

  (** [columns b] gives the number of columns in the board [b]. This is equal to
      the size of each row in [b] *)
  val columns: t -> int

  (** [rows b] gives the number of rows in the board [b]. This is equal to the
      size of each column in [b]  *)
  val rows: t -> int

  (** [place_ship_h b ship] puts ship horizontally into the board [b].
      Raises: OutOfBounds if the ship exceeds the bounds of the board.
          Overlap if the ship will overlap with an existing ship on the board.*)
  val place_ship_h: t -> ShipMaker.t -> unit


  (** [place_ship_h b ship] puts ship vertically into the board [b].
      Raises: OutOfBounds if the ship exceeds the bounds of the board.
          Overlap if the ship will overlap with an existing ship on the board.*)
  val place_ship_v: t -> ShipMaker.t -> unit

end

module BoardMaker : Board 
