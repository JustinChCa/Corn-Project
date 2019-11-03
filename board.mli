open Ship

module type Board = sig

  (** type [opt] is the possible types of each space in the board. *)
  type opt = Miss | Hit | Water of ShipMaker.t option

  exception Overlap
  exception Out_of_Bounds

  (** the type implementation of the board, an opt array array. *)
  type t 

  val make_board: int -> int -> opt array array

  (** [hit b pair] changes the board [b] after a coordinate 
      [pair] is attacked. *)
  val hit: t -> int*int -> unit

  (** [dis_board b] displays the board in graphical form in the console command
      window. *)
  val dis_board: opt array array -> unit

  (** [columns b] gives the number of columns in board [b] *)
  val columns: opt array array -> int

  (** [rows b] give the number of rows in board [b] *)
  val rows: opt array array -> int

  val place_ship_h: opt array array -> (int*int)*bool list -> unit

  val place_ship_v: opt array array -> (int*int)*bool list -> unit

end

module BoardMaker : Board 
