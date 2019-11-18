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

  (** type [mode] is the possible types of difficulty for the ai. *)
  type mode = Dumb | Normal | Hard | Hax
  type t

  (** [dumb_hit b miss hit] hits a random spot that is not in lst [miss] nor 
      in lst [hit]. Has no consideration for strategy.*)
  val dumb_hit: BoardMaker.t -> (int*int) list -> (int*int) list -> unit

  (** [easy_hit b miss hit] hits a random spot if there is no other spot that 
      has been hit but the ship there is not yet sunk, e.g. the lst [hit] is 
      nonempty. This continues to search for the unsunken ship until it is sunk. *)
  val easy_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit

  (** [smart_hit b miss hit] uses a checkerboard and space checking strategy to 
      attack spots if there is no other spot that has been hit but the ship there
      is not yet sunk, e.g. the lst [hit] is nonempty. This continues to search
      for the unsunken ship until it is sunk.*)
  val smart_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit

  (** [hax_hit] uses the same ai as the hard difficulty but it is able to 
      magically find an enemy ship coordinate with 100% certainty every 7 turns. *)
  val hax_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit
end

