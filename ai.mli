open Player
open Random
open Board
open Ship

module type ai = sig
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

  (** [ai_init d board] creates the ai corresponding to the difficulty [d] and
      the board [board]*)
  val ai_init: int -> BoardMaker.t -> t

  (** [hit ai int] calls the ai to play a turn. The ai's action is determined
      by the difficulty of the ai. [int] is the size of the largest enemy ship, 
      which must be positive. *)
  val hit: t -> int -> unit
end

