
type coor = (int * int)

module type Ship = sig
  type t
  val size : t -> int
  val create : coor list -> t
  val hit : coor -> t -> unit
  val calive : coor -> t -> bool
  val alive : t -> bool
  val coordinates : t -> coor list
end

exception Hitted of string

module ShipMaker = struct
  type t = (coor * bool) list ref

  let size ship =
    List.length !ship

  let create coor =
    ref (List.map (fun a -> (a, true)) coor)

  let rec hit coor ship =
    let rec hit_helper = function
      | [] -> []
      | (c, b)::t -> 
        if c = coor then 
          begin if b then (print_endline "You Hit."; (c, false)::t) 
            else raise (Hitted "You have already hit this spot.") end
        else (c,b)::hit_helper t in
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

  let coordinates ship =
    List.map (fun ((x,y), b) -> (x,y)) !ship
end

