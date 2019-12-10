
module type Ship = sig
  type t
  val size : t -> int
  val create : (int * int) list -> t
  val hit : (int * int) -> t -> bool -> unit
  val calive : (int * int) -> t -> bool
  val alive : t -> bool
  val coordinates : t -> (int * int) list
  val health: t -> int
  val get_largest: t list -> int -> int 
end

exception Hitted of string

module ShipMaker = struct
  type t = ((int * int) * bool) list ref

  let size ship =
    List.length !ship

  let create coor =
    ref (List.map (fun a -> (a, true)) coor)

  (**[print_hit_msg bool] prints a hit message if [bool] is true, else does not
     print out anything. *)
  let print_hit_msg bool = 
    match bool with 
    | true -> print_endline "You Hit."
    | false -> ()

  let rec hit coor ship bool=
    let rec hit_helper = function
      | [] -> []
      | (c, b)::t -> 
        if c = coor then 
          begin if b then (print_hit_msg bool; (c, false)::t) 
            else raise (Hitted "You have already hit this spot.") end
        else (c,b)::hit_helper t in
    ship := hit_helper !ship

  let rec calive coor ship =
    let rec coor_helper = function
      | [] -> failwith "Empty List Failure."
      | (c, b)::t -> if c = coor then b else coor_helper t in
    coor_helper !ship

  let alive ship =
    List.exists (fun (c,b) -> b) !ship

  let coordinates ship =
    List.map (fun ((y, x), b) -> (y, x)) !ship

  let rec health ship = 
    let rec health_helper lst acc =
      match lst with
      |[] -> acc
      |(_,b) :: t -> if b = true then
          health_helper t (acc+1) else
          health_helper t acc
    in 
    health_helper !ship 0

  let rec get_largest (lst:t list) int =
    match lst with
    | [] -> int
    | h :: t -> 
      if alive h then 
        if size h > int then get_largest t (size h) else get_largest t int
      else get_largest t int

end

