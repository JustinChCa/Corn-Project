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
  *)

  type t

  (** [ai_init d board] creates the ai corresponding to the difficulty [d] and
      the board [board]*)
  val ai_init: int -> BoardMaker.t -> t

  (** [dumb_hit b miss hit] hits a random spot that is not in lst [miss] nor 
      in lst [hit]. Has no consideration for strategy.*)
  val dumb_hit: t -> unit

  (** [easy_hit b miss hit] hits a random spot if there is no other spot that 
      has been hit but the ship there is not yet sunk, e.g. the lst [hit] is 
      nonempty. This continues to search for the unsunken ship until it is sunk. *)
  val easy_hit: t -> unit

  (** [smart_hit b miss hit] uses a checkerboard and space checking strategy to 
      attack spots if there is no other spot that has been hit but the ship there
      is not yet sunk, e.g. the lst [hit] is nonempty. This continues to search
      for the unsunken ship until it is sunk.*)
  val smart_hit: t -> unit

  (** [hax_hit] uses the same ai as the hard difficulty but every 7 turns it
      gets lucky and hits an enemy ship with 100% reliability. *)
  val hax_hit: t -> unit
end

