
type coor = string

module type Ship = sig
  type t
  val taken : string list ref
  val empty : t
  val is_empty: t -> bool
  val size : t -> int
  val insert: coor -> t -> t
  val remove: coor -> t -> t
  val create : coor list -> t
  val hit : coor -> t -> t
  val alive : t -> bool
end

module ShipMaker = struct
  type t = (coor * bool) list

  let taken = ref []

  let empty = []

  let is_empty s =
    s = []

  let size s =
    List.length s

  let rec insert coor = function
    | [] -> [(coor, true)]
    | (c,b)::t -> 
      match Stdlib.compare c coor with
      | 0 -> (c,b)::t
      | x when x>0 -> (c,b)::insert coor t
      | _ -> (coor, true)::(c,b)::t

  let rec remove coor = function
    | [] -> []
    | (c,b)::t ->
      match Stdlib.compare c coor with
      | 0 -> t
      | x when x>0 -> (c,b)::remove coor t
      | _ -> (c,b)::t

  let create (lst:coor list) =
    List.map (fun x -> (x, true)) lst

  let rec hit coord = function
    | [] -> []
    | (s, b)::t -> if s = coord then (s, false)::t else (s, b)::hit coord t

  let rec alive = function
    | [] -> false
    | (s, b)::t -> if b then true else alive t
end