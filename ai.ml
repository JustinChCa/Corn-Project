open Player
open Random
open Board
open Ship

module type Ai = sig
  type mode = Dumb | Normal | Hard | Hax
  type t
  val dumb_hit: BoardMaker.t -> (int*int) list -> (int*int) list -> unit
  val easy_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit
  val smart_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit
  val hax_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit
end

module AiMaker = struct
  type mode = Dumb | Normal | Hard | Hax

  type t = {diff : mode; 
            missed : (int*int) list; 
            current : (int*int) list}


  let rengine = Random.self_init

  (** [find_coor_random board lst] gives a random coordinate to attack on the 
      board that is not an element of the list [lst].  *)
  let find_coor_random board lst : (int*int)= 
    failwith "unimplemented"

  (** [find_coor_cb board lst] finds a coordinate using the checkerboard 
      and the length reference strategy that is not an element of list [lst]*)
  let find_coor_cb board lst : (int*int) = 
    failwith "unimplemented"

  (** [find_coor_hit board miss hit] finds a coordinate that is most likely to
      be a ship coordinate based on existing hit ship data [hit], making inferences
      on ship orientation and edge cases.*)
  let find_coor_hit board miss hit =
    failwith "unimplemented"

  let dumb_hit b miss hit =
    failwith "unimplemented"

  let easy_hit b miss hit =
    failwith "unimplemented"

  let smart_hit b miss hit =
    failwith "unimplemented"

  let hax_hit b miss hit =
    failwith "unimplemented"


end