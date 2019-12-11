open Ship
open Board


module type Player = sig 
  type t 

  val empty: t

  val create : ShipMaker.t list -> BoardMaker.t -> string -> t

  val get_name: t -> string

  val alive: t -> bool

  val alive_ships: t -> int

  val get_ships: t -> ShipMaker.t list

  val get_board: t -> BoardMaker.t

  val hit : t -> int * int -> bool

end

module PlayerMaker = struct 
  type t = {ships: ShipMaker.t list;
            board: BoardMaker.t;
            name: string}

  let create ships board name = {
    ships= ships;
    board= board;
    name= name;
  }

  let empty= 
    {
      ships=[ShipMaker.create [(1,1)]];
      board= BoardMaker.create 1 1;
      name="dummy";
    }

  let alive t =
    List.exists (fun a -> ShipMaker.alive a) t.ships

  let alive_ships t =
    List.fold_left (fun acc a -> if ShipMaker.alive a then acc+1 else acc) 0
      t.ships

  let get_ships t = t.ships

  let get_board t = t.board

  let get_name t = t.name

  let hit enemy coor = (**true - prints, false - doesn't print *)
    BoardMaker.hit (enemy.board) coor
end 

