module type Coordinates = sig
  type t
  val empty : t
  val is_empty : t -> bool
  val insert : t -> int -> int -> t
  val remove : t -> int -> int -> t
  val create : t -> (int * int -> (int * int) list)
end

module CMaker = struct
  type t = int * int list

  let empty = []

  let is_empty t = t = []

  let rec insert t x y = 
    match t with
    | [] -> [(x, y)]
    | (x,y)::e as s -> if x = x && y = y then s else insert e x y

  let create t =
    fun (x, y) -> List.map (fun (a, b) -> (x+a, y+b)) t

end