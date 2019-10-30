module type Ship = sig
  type t
  val empty : t
  val create : t
  val hit : string -> t -> unit
  val alive : t -> bool
end

module ShipMaker = struct
  type t = (string * bool) list

  let empty = []

  let create lst =
    List.map (fun x -> (x, true)) lst

  let rec hit coord = function
    | [] -> []
    | (s, b)::t -> if s = coord then (s, false)::t else (s, b)::hit coord t

  let rec alive = function
    | [] -> false
    | (s, b)::t -> if b then true else alive t

end