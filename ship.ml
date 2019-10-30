module type Ship = sig
  type t
  val empty : t
  val create : t
  val hit : string -> t -> unit
  val alive : t -> bool
end

type coor = string

module ShipMaker = struct
  type t = (coor * bool) list

  let empty = []

  let create (lst:coor list) =
    List.map (fun x -> (x, true)) lst

  let rec hit coord = function
    | [] -> []
    | (s, b)::t -> if s = coord then (s, false)::t else (s, b)::hit coord t

  let rec alive = function
    | [] -> false
    | (s, b)::t -> if b then true else alive t
end

let bigShip = ShipMaker.create ["A1"; "B1"]