
type coor = int*int

type compare = | EQ | GL


module type Ship = sig
  type t
  val taken : coor list ref
  val empty : unit -> t
  val is_empty: t -> bool
  val size : t -> int
  val insert: coor -> t -> unit
  val remove: coor -> t -> unit
  val create : coor list -> t
  val hit : coor -> t -> unit
  val calive : coor -> t -> bool
  val alive : t -> bool
  val compare : t -> t -> compare
end

module ShipMaker = struct
  type t = (coor * bool) list ref

  let taken = ref []

  let empty () = ref []

  let is_empty ship =
    !ship = []

  let size ship =
    List.length !ship

  let rec insert coor ship =
    let rec ins_helper = function
      | [] -> [(coor, true)]
      | (c,b)::t -> 
        match Stdlib.compare c coor with
        | 0 -> (c,b)::t
        | x when x<0 -> (c,b)::ins_helper t
        | _ -> (coor, true)::(c,b)::t in
    ship := ins_helper !ship

  let rec remove coor ship =
    let rec rem_helper = function
      | [] -> []
      | (c,b)::t ->
        match Stdlib.compare c coor with
        | 0 -> t
        | x when x<0 -> (c,b)::rem_helper t
        | _ -> (c,b)::t in
    ship := rem_helper !ship

  let create (lst:coor list) =
    ref (List.map (fun x -> (x, true)) lst)

  let rec hit coor ship =
    let rec hit_helper = function
      | [] -> []
      | (c, b)::t -> 
        match Stdlib.compare c coor with
        | 0 -> (c, false)::t
        | x when x<0 -> (c,b)::hit_helper t
        | _ -> (c,b)::t in
    ship := hit_helper !ship

  let rec calive coor ship =
    let rec coor_helper = function
      | [] -> failwith "Empty List Failure."
      | (c, b)::t -> 
        match Stdlib.compare c coor with
        | 0 -> b
        | x when x<0 -> coor_helper t
        | _ -> failwith "Comparison Failure." in
    coor_helper !ship

  let alive ship =
    List.exists (fun (c,b) -> b) !ship

  let compare s1 s2 = 
    (**Sort s1 && s2 first to avoid any potential issues...OR make rep_ok *)
    match fst (List.hd !s1), fst (List.hd !s2) with 
    | (s1x, s1y), (s2x,s2y) -> if s1x = s2x && s1y= s2y then EQ else GL

end

