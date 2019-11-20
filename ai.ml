open Player
open Random
open Board
open Ship

module type Ai = sig
  type t
  val dumb_hit: BoardMaker.t -> (int*int) list -> (int*int) list -> unit
  val easy_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit
  val smart_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit
  val hax_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit
end

module AiMaker = struct

  type t = {diff : int; 
            mutable missed : (int*int) list; 
            mutable current : (int*int) list;
            mutable avail : (int*int) list;
            b: BoardMaker.t}


  let _ = Random.self_init ()


  (** [init_avail board r c lst] creates the list of all coordinates in [board]
      ordered from left to right for each row starting with the top left coordinate
      (0,0). *)
  let rec init_avail board r c lst : (int*int) list= 
    if r > (-1) then 
      if c > (-1) then init_avail board r (c-1) ((r,c)::lst) else
        init_avail board (r-1) (BoardMaker.columns board -1) lst
    else lst


  let init_avail_cb board r c lst : (int*int) list=
    failwith "unimplemented"

  (* if index > List.length avail then failwith "bad index" else remove_index avail index []*)
  let rec remove_index lst index acc: (int*int) * (int*int) list = 
    if index > 0 then 
      match lst with
      | h :: t -> remove_index t (index-1) (h::acc)
      | [] -> failwith "bad index uncaught" 
    else 
      match lst with 
      | h :: t -> (h, List.rev acc @ t)
      | [] -> failwith "bad index uncaught"


  let ai_init d board =
    match d with
    | d when d = 1 || d = 2 -> 
      {diff = d; missed = []; current = []; 
       avail = init_avail board (BoardMaker.rows board - 1) (BoardMaker.columns board - 1) [];
       b = board}
    | d when d = 3 || d = 4 -> 
      {diff = d; missed = []; current = []; 
       avail = init_avail_cb board (BoardMaker.rows board - 1) (BoardMaker.columns board - 1) [];
       b = board }
    | d -> failwith "invalid difficulty"

  (** [find_coor_r lst] gives a random coordinate to attack that is an
      element of the list [lst].  *)
  let find_coor_r lst : (int*int) * (int*int) list= 
    remove_index lst (Random.int (List.length lst-1)) []

  (** [find_coor_cb ai lst] finds a coordinate using the checkerboard 
      and the length reference strategy that is not an element of list [lst]*)
  let find_coor_cb ai lst : (int*int) = 
    failwith "unimplemented"

  (** [find_coor_hit ai] finds a coordinate that is most likely to be a ship
       coordinate based on existing hit ship data, making inferences on ship 
       orientation and edge cases.*)
  let find_coor_hit ai =
    failwith "unimplemented"

  let dumb_hit (ai:t) =
    match ai with
    |{diff = d; missed = miss; current = curr; avail = aval; b = board} -> 
      let coornewlst = find_coor_r aval in
      failwith "unimplemented"
  (* avail <- snd coornewlst 
     then deal with where fst coornewlst goes
     BoardMaker.hit board (fst coornewlst)*)

  let easy_hit ai =
    failwith "unimplemented"

  let smart_hit ai =
    failwith "unimplemented"

  let hax_hit ai =
    failwith "unimplemented"


end