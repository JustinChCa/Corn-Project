open Player
open Random
open Board
open Ship

module type Ai = sig
  type t
  val dumb_hit: BoardMaker.t -> (int*int) list -> (int*int) list -> unit
  val normal_hit: BoardMaker.t -> (int*int) list -> (int*int) list-> unit
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
  let rec init_avail board r c lst : (int*int) list = 
    if r > (-1) then 
      if c > (-1) then init_avail board r (c-1) ((r,c)::lst) else
        init_avail board (r-1) (BoardMaker.columns board -1) lst
    else lst

  let rec skip_first board r c lst : (int*int) list =
    if r > (-1) then 
      if c > 0 then skip_first board r (c-2) ((r,c-1)::lst) else
        skip_second board (r-1) (BoardMaker.columns board -1) lst
    else lst
  and skip_second board r c lst =
    if r > (-1) then 
      if c > (-1) then skip_second board r (c-2) ((r,c)::lst) else
        skip_first board (r-1) (BoardMaker.columns board -1) lst
    else lst

  let init_avail_cb board r c : (int*int) list=
    if r mod 2 = c mod 2 then 
      skip_first board (BoardMaker.rows board -1) (BoardMaker.columns board -1) []
    else
      skip_second board (BoardMaker.rows board -1) (BoardMaker.columns board -1) []

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

  let rec remove_coor lst coor acc: (int*int) * (int*int) list = 
    match lst with 
    | [] -> failwith "no such coordinate in list"
    | h::t -> if h = coor then (h, List.rev acc @ t) else
        remove_coor t coor (h :: acc)

  let rec get_last = function
    | [] -> failwith "empty list has no last element"
    | h::[] -> h
    | h::t -> get_last t

  (* true is vertical and false is horizontal *)
  let find_orientation (lst:(int*int) list) : (int*int) * (int*int) * bool =
    match lst with
    |(ar, ac)::b:: _ -> begin
        match get_last lst with 
        | (lr, lc) -> begin
            if (ar < lr) && (ac = lc) then ((ar,ac),(lr,lc), true) else
            if (ar > lr) && (ac = lc) then ((lr,lc),(ar,ac), true) else
            if (ar = lr) && (ac < lc) then ((ar,ac),(lr,lc), false) else
            if (ar = lr) && (ac > lc) then ((lr,lc),(ar,ac), false) else
              failwith "wtf man"
          end
      end
    |_ -> failwith "not enough elements in list for find orientation"

  (* 1 is dumb
     2 is normal
     3 is smart
     4 is expert *)

  let ai_init d board =
    match d with
    | d when d = 1 || d = 2 -> 
      {diff = d; missed = []; current = []; 
       avail = init_avail board (BoardMaker.rows board - 1) (BoardMaker.columns board - 1) [];
       b = board}
    | d when d = 3 || d = 4 -> 
      {diff = d; missed = []; current = []; 
       avail = init_avail_cb board (BoardMaker.rows board - 1) (BoardMaker.columns board - 1);
       b = board }
    | d -> failwith "invalid difficulty"

  (** [find_coor_r lst] gives a random coordinate to attack that is an
      element of the list [lst].  *)
  let find_coor_r lst : (int*int) * (int*int) list= 
    remove_index lst (Random.int (List.length lst-1)) []

  let rec up lst (r,c) size acc: int = 
    if r < 0 || acc = size then acc else 
    if List.mem (r,c) lst then acc else
      up lst (r-1,c) size (acc +1)

  let rec down limit lst (r,c) size acc: int = 
    if r > limit || acc = size then acc else
    if List.mem (r,c) lst then acc else
      down limit lst (r+1, c) size (acc+1)

  (** [check_vert limit lst (r,c) size] checks if a size of length [size] will
      be able to fit vertically in the space between two already hit points
      and/or the border that contains the point [(r,c)] *)
  let check_vert limit lst (r,c) size : int = 
    (up lst (r-1,c) size 0) + 1 + (down limit lst (r+1,c) size 0)

  let rec left lst (r,c) size acc: int = 
    if c < 0 || acc = size then acc else
    if List.mem (r,c) lst then acc else
      left lst (r,c+1) size (acc+1)

  let rec right limit lst (r,c) size acc: int = 
    if c > limit || acc = size then acc else
    if List.mem (r,c) lst then acc else
      right limit lst (r,c+1) size (acc+1)

  (** [check_horz limit lst (r,c) size] checks if a size of length [size] will
      be able to fit horizontally in the space between two already hit points
      and/or the border that contains the point [(r,c)] *)
  let check_horz limit lst (r,c) size : int = 
    (left lst (r,c-1) size 0) + 1 + (right limit lst (r,c+1) size 0)

  (** [find_coor_cb ai lst] finds a coordinate using the checkerboard 
      and the length reference strategy.*)
  let rec find_coor_cb board avail missed int : (int*int) * (int*int) list = 
    let coor = List.hd avail in
    let rlimit = BoardMaker.rows board -1 in
    let climit = BoardMaker.columns board -1 in
    if (check_horz climit missed coor (int-1)) >= int 
    || (check_vert rlimit missed coor (int-1)) >= int
    then (coor, List.tl avail) else
      find_coor_cb board (List.tl avail) missed int 

  (* true is vertical and false is horizontal *)

  (** [find_coor_hit ai] finds a coordinate that is most likely to be a ship
       coordinate based on existing hit ship data, making inferences on ship 
       orientation and edge cases.*)
  let find_coor_hit ai : (int*int) * (int*int) list  =
    match ai.current with 
    | (r,c)::[] -> begin
        if not (List.mem (r-1,c) ai.missed) then remove_coor ai.avail (r-1,c) [] 
        else if not (List.mem (r,c+1) ai.missed) then remove_coor ai.avail (r,c+1) [] 
        else if not (List.mem (r+1,c) ai.missed) then remove_coor ai.avail (r+1,c) [] 
        else if not (List.mem (r, c-1) ai.missed) then remove_coor ai.avail (r,c-1) []
        else failwith "isolated one ship"
      end
    | _ -> match find_orientation ai.current with 
      | ( (ri, ci), (rf, cf), b ) -> begin
          if b = true then 
            if not(List.mem (ri-1,ci) ai.missed) then 
              remove_coor ai.avail (ri-1,ci) [] else 
            if not(List.mem (rf+1,cf) ai.missed) then
              remove_coor ai.avail (rf+1,cf) [] else failwith "wtf 1"
          else 
          if not(List.mem (ri,ci-1) ai.missed) then
            remove_coor ai.avail (ri,ci-1) [] else
          if not(List.mem (rf,cf+1) ai.missed) then
            remove_coor ai.avail (rf,cf+1) [] else failwith "wtf 2"
        end
  (* call function to find orientation and test the two sides*)

  let dumb_hit (ai:t) =
    let coornewlst = find_coor_r ai.avail in
    ai.avail <- snd coornewlst;
    ai.missed <- (fst coornewlst):: ai.missed;
    BoardMaker.hit ai.b (fst coornewlst)

  let determinant2 ai = 
    match ai.current with 
    | [] -> find_coor_r ai.avail
    |_::_ -> find_coor_hit ai 

  let determinant3 ai int =
    match ai.current with 
    | [] -> find_coor_cb ai.b ai.avail ai.missed int
    | _::_ -> find_coor_hit ai 

  let rec find_ship board lst acc = 
    let coor = List.hd lst in 
    match BoardMaker.get_coor board coor with
    |None -> find_ship board (List.tl lst) (coor::[])
    |Some s -> (coor, List.rev acc @ List.tl lst)

  let determinant4 ai int =
    match ai.current with 
    | [] -> if List.length ai.missed mod 7 = 0 then 
        find_ship ai.b ai.avail [] else 
        find_coor_cb ai.b ai.avail ai.missed int
    | _::_ -> find_coor_hit ai 

  let super_determinant ai int = 
    match ai.diff with
    |2 -> determinant2 ai
    |3 -> determinant3 ai int
    |4 -> determinant4 ai int
    |_ -> failwith "not a valid difficulty"

  let hit ai int =
    if ai.diff = 1 then dumb_hit ai else
      let coornewlst = super_determinant ai int in 
      ai.avail <- snd coornewlst;
      match BoardMaker.get_coor ai.b (fst coornewlst) with
      | None -> ai.missed <- (fst coornewlst):: ai.missed;
        BoardMaker.hit ai.b (fst coornewlst)
      | Some s -> begin match ShipMaker.health s with 
          | 0 -> failwith "impossible, hitting sunken ship"
          | 1 -> ai.missed <- ((fst coornewlst)::ai.current) @ ai.missed;
            ai.current <- []; BoardMaker.hit ai.b (fst coornewlst)
          | _ -> ai.current <- (fst coornewlst):: ai.current;
            BoardMaker.hit ai.b (fst coornewlst)
        end


end