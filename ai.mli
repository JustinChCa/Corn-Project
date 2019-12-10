open Player
open Random
open Board
open Ship

module type Ai = sig
  (** AF: the type represents the difficulty of the ai with the list of 
      coordinates the ai has missed or sunk ships and the list of coordinates 
      attacked ships that have not sunk yet. 
      RI: 
      [missed] contains coordinates attacked and missed and the coordinates
      of attacked and sunken ships.
      [current] contains attacked and unsunken ship coordinates.
      [avail] contains coordinates that have not been attacked.
  *)

  type t

  (** [ai_init d board] creates an ai with the difficulty [d] with the board
      [board]. References the difficulty to determine what kind of avail to 
      initialize. The lower two difficulties will use the entire board for
      avail. The higher two difficulties will use a minimized checkerboard
      section of the board as avail.     
      1 is dumb
      2 is normal
      3 is smart
      4 is expert *)
  val ai_init: int -> BoardMaker.t -> BoardMaker.t -> ShipMaker.t list-> t

  (** [hit ai int] calls the ai to play a turn. The ai's action is determined
      by the difficulty of the ai. [int] is the size of the largest enemy ship, 
      which must be positive. *)
  val hit: t -> int -> unit

  (** [get_board ai] returns the ai's own board.*)
  val get_board: t -> BoardMaker.t 

  (** [get_ships ai] returns the ai's own list of ships.*)
  val get_ships: t -> ShipMaker.t list

  (** [alive ai] is true iff at least one of ai's ships is alive.*)
  val alive: t -> bool

  (** TO SPECIFY TO SPECIFY TO SPECIFY TO SPECIFY !!!!!!!!!!!!!!!!!!!!!!!!!!!!*)
  val ai_create_ship: (int * int) list -> Board.BoardMaker.t -> Ship.ShipMaker.t
end

module AiMaker : Ai 
