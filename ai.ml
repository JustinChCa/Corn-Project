open Player
open Random
open Board
open Ship
open Command

module type Ai = sig
  type t
  val ai_init: int -> BoardMaker.t -> BoardMaker.t -> ShipMaker.t list-> t
  val hit: t -> int -> unit
  val get_board: t -> BoardMaker.t 
  val get_ships: t -> ShipMaker.t list
  val alive: t -> bool
  val ai_create_ship: (int * int) list -> Board.BoardMaker.t -> Ship.ShipMaker.t
  val ai_player_init: Player.PlayerMaker.t -> int -> 
    ((int * int) list * 'a) list -> int -> 
    Player.PlayerMaker.t * t
end

module AiMaker = struct


  type t = {diff : int; 
            mutable missed : (int*int) list; 
            mutable current : (int*int) list;
            mutable avail : (int*int) list;
            b: BoardMaker.t;
            self: BoardMaker.t;
            ships:ShipMaker.t list}

  (* This initiates the Random seed that is used in this module.*)
  let init_random () = Random.self_init ()

  (** [init_avail board r c lst] creates the list of all coordinates in [board]
      ordered from left to right for each row starting with the top left 
      coordinate (0,0). *)
  let rec init_avail board r c lst : (int*int) list = 
    if r > (-1) then 
      if c > (-1) then init_avail board r (c-1) ((r,c)::lst) else
        init_avail board (r-1) (BoardMaker.columns board -1) lst
    else lst

  (** [skip_first board r c lst] skips the last coordinate of a row and takes
      every other coordinate in front of it until it reaches the edge. 
      [skip_second board r c lst] takes the last coordinate of a row and takes
      every other coordinate in front of it until it reaches the edge. *)
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

  (** [init_avail_cb board r c] initiates the avail list for the ai based on
      the checkerboard strategy. Used by smart and expert ai.*)
  let init_avail_cb board r c : (int*int) list=
    if r mod 2 = c mod 2 then 
      skip_first board (BoardMaker.rows board -1) 
        (BoardMaker.columns board -1) []
    else
      skip_second board (BoardMaker.rows board -1) 
        (BoardMaker.columns board -1) []

  (** [remove_index lst index acc] removes the [index]th element from the list
      [list]. Retains the order of the list after removal. *)
  let rec remove_index lst index acc: (int*int) * (int*int) list = 
    if index > 0 then 
      match lst with
      | h :: t -> remove_index t (index-1) (h::acc)
      | [] -> failwith "bad index uncaught" 
    else 
      match lst with 
      | h :: t -> (h, List.rev acc @ t)
      | [] -> failwith "bad index uncaught"

  (** [remove_coor lst coor acc] removes the coordinate [coor] from the list
      [lst]. Retains the order of the list after removal. For the checkerboard 
      strategy, the [coor] might not be in [lst] so it will return the [coor]
      and an unaugmented [lst]*)
  let rec remove_coor lst coor acc: (int*int) * (int*int) list = 
    match lst with 
    | [] -> (coor, List.rev acc)
    | h::t -> if h = coor then (h, List.rev acc @ t) else
        remove_coor t coor (h :: acc)

  (** [get_last lst coor] gets the largest element of a list *)
  let rec get_last lst coor = 
    match lst with
    | [] -> coor
    |(r,c) :: t -> if (r > (fst coor)) || (c > (snd coor)) then 
        get_last t (r,c) else get_last t coor

  (** [get_first lst coor] gets the smallest element of a list *)
  let rec get_first lst coor = 
    match lst with
    | [] -> coor
    |(r,c) :: t -> if (r < (fst coor)) || (c < (snd coor)) then
        get_first t (r,c) else get_first t coor

  (** [find_orientation lst] looks through the lst and figures out if the
      coordinates are horizontally or vertically orientated. [true] is vertical
      and [false] is horizontal. *)
  let find_orientation (lst:(int*int) list) : (int*int) * (int*int) * bool =
    let (ar, ac) = get_first (List.tl lst) (List.hd lst) in
    match get_last (List.tl lst) (List.hd lst) with 
    | (lr, lc) -> begin
        if (ar < lr) && (ac = lc) then ((ar,ac),(lr,lc), true) else
        if (ar > lr) && (ac = lc) then ((lr,lc),(ar,ac), true) else
        if (ar = lr) && (ac < lc) then ((ar,ac),(lr,lc), false) else
        if (ar = lr) && (ac > lc) then ((lr,lc),(ar,ac), false) else
          failwith "wtf man"
      end

  (** [ai_init d board] creates an ai with the difficulty [d] with the board
      [board]. References the difficulty to determine what kind of avail to 
      initialize. The lower two difficulties will use the entire board for
      avail. The higher two difficulties will use a minimized checkerboard
      section of the board as avail.     
      1 is dumb
      2 is normal
      3 is smart
      4 is expert *)
  let ai_init d enemyb selfb shiplst=
    match d with
    | d when d = 1 || d = 2 -> 
      {diff = d; missed = []; current = [];
       avail = init_avail enemyb (BoardMaker.rows enemyb - 1) 
           (BoardMaker.columns enemyb - 1) [];
       b = enemyb;
       self = selfb;
       ships = shiplst}
    | d when d = 3 || d = 4 -> 
      {diff = d; missed = []; current = [];
       avail = init_avail_cb enemyb (BoardMaker.rows enemyb - 1) 
           (BoardMaker.columns enemyb - 1);
       b = enemyb;
       self = selfb;
       ships = shiplst}
    | d -> failwith "invalid difficulty"

  (** [find_coor_r lst] gives a random coordinate to attack that is an
      element of the list [lst].  *)
  let find_coor_r lst : (int*int) * (int*int) list= 
    remove_index lst (Random.int (List.length lst)) []

  (** [up lst coor size acc] searches the left side of [coor] to see
      how many unattacked spaces there are. Ends the search if it finds the
      edge of the board or reaches the size of the largest alive ship or 
      reaches a coordinate that's already been attacked. *)
  let rec up lst (r,c) size acc: int = 
    if r < 0 || acc = size then acc else 
    if List.mem (r,c) lst then acc else
      up lst (r-1,c) size (acc +1)

  (** [down limit lst coor size acc] searches the right side of [coor] to see
      how many unattacked spaces there are. Ends the search if it finds the
      edge of the board or reaches the size of the largest alive ship or 
      reaches a coordinate that's already been attacked. *)
  let rec down limit lst (r,c) size acc: int = 
    if r > limit || acc = size then acc else
    if List.mem (r,c) lst then acc else
      down limit lst (r+1, c) size (acc+1)

  (** [check_vert limit lst (r,c) size] checks if a size of length [size] will
      be able to fit vertically in the space between two already hit points
      and/or the border that contains the point [(r,c)] *)
  let check_vert limit lst (r,c) size : int = 
    (up lst (r-1,c) size 0) + 1 + (down limit lst (r+1,c) size 0)

  (** [left lst coor size acc] searches the left side of [coor] to see
      how many unattacked spaces there are. Ends the search if it finds the
      edge of the board or reaches the size of the largest alive ship or 
      reaches a coordinate that's already been attacked. *)
  let rec left lst (r,c) size acc: int = 
    if c < 0 || acc = size then acc else
    if List.mem (r,c) lst then acc else
      left lst (r,c+1) size (acc+1)

  (** [right limit lst coor size acc] searches the right side of [coor] to see
      how many unattacked spaces there are. Ends the search if it finds the
      edge of the board or reaches the size of the largest alive ship or 
      reaches a coordinate that's already been attacked. *)
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
    let coornewlst = remove_index avail 
        (Random.int (List.length avail)) [] in
    let rlimit = BoardMaker.rows board -1 in
    let climit = BoardMaker.columns board -1 in
    if (check_horz climit missed (fst coornewlst) (int-1)) >= int 
    || (check_vert rlimit missed (fst coornewlst) (int-1)) >= int
    then coornewlst else
      find_coor_cb board (snd coornewlst) missed int 

  (* true is vertical and false is horizontal *)

  let special_case ai int = 
    ai.missed <- ai.current @ ai.missed;
    ai.current <- [];
    if ai.diff <= 2 then find_coor_r ai.avail else 
      find_coor_cb ai.b ai.avail ai.missed int

  (** [island ai coor] finds an unhit coordinate around the coordinate [coor]
      to hit.*)
  let island ai (r,c) int =
    if not (List.mem (r-1,c) ai.missed) && (r-1 >= 0) then 
      remove_coor ai.avail (r-1,c) [] else 
    if not (List.mem (r,c+1) ai.missed) && 
       (c+1 <= BoardMaker.columns ai.b -1) then 
      remove_coor ai.avail (r,c+1) [] else 
    if not (List.mem (r+1,c) ai.missed) && 
       (r+1 <= BoardMaker.rows ai.b -1) then 
      remove_coor ai.avail (r+1,c) [] else 
    if not (List.mem (r, c-1) ai.missed) && (c-1 >= 0) then 
      remove_coor ai.avail (r,c-1) []
    else special_case ai int



  (** [find_coor_hit ai] finds a coordinate that is most likely to be a ship
       coordinate based on existing hit ship data, making inferences on ship 
       orientation and edge cases.*)
  let find_coor_hit ai int : (int*int) * (int*int) list  =
    match ai.current with 
    | (r,c)::[] -> island ai (r,c) int
    | _ -> match find_orientation ai.current with 
      | ( (ri, ci), (rf, cf), true ) -> begin
          if not(List.mem (ri-1,ci) ai.missed) && (ri-1 >= 0) then 
            remove_coor ai.avail (ri-1,ci) [] else 
          if not(List.mem (rf+1,cf) ai.missed) 
          && (rf+1 <= BoardMaker.rows ai.b -1) then
            remove_coor ai.avail (rf+1,cf) [] else 
            special_case ai int
        end
      | ( (ri, ci), (rf, cf), false ) -> begin
          if not(List.mem (ri,ci-1) ai.missed) && (ci-1 >= 0) then
            remove_coor ai.avail (ri,ci-1) [] else
          if not(List.mem (rf,cf+1) ai.missed) 
          && (cf+1 <= BoardMaker.columns ai.b -1)then
            remove_coor ai.avail (rf,cf+1) [] else 
            special_case ai int
        end

  (** [dumb_hit ai] is the function used to make a turn on the easiest
      difficulty. Makes a random choice for the coordinate to attack. *)
  let dumb_hit ai =
    let coornewlst = find_coor_r ai.avail in
    ai.avail <- snd coornewlst;
    ai.missed <- (fst coornewlst):: ai.missed;
    ignore (BoardMaker.hit ai.b (fst coornewlst))

  (** [determinant2 ai] chooses the right function to use based on whether or
      not the ai has hit a ship and is still hunting it. This is the helper
      function for normal ai. *)
  let rec determinant2 ai int = 
    match ai.current with 
    | [] -> find_coor_r ai.avail
    |_::_ -> find_coor_hit ai int

  (** [determinant3 ai int] chooses the right function to use based on whether
      or not the ai has just successfully hit a ship and hasn't sunk it yet.
      Uses the size of the largest alive ship [int] to use for the smart ai.
      This is the helper function for smart ai. *)
  let rec determinant3 ai int =
    match ai.current with 
    | [] -> find_coor_cb ai.b ai.avail ai.missed int
    | _::_ -> find_coor_hit ai int

  (** [find_ship board lst acc] finds a coordinate from avail with an enemy 
      ship and returns that coordinate and the remaining avail list without
      that coordinate. Used for the expert ai. *)
  let rec find_ship board lst acc = 
    let coor = List.hd lst in 
    match BoardMaker.get_coor board coor with
    |None -> find_ship board (List.tl lst) (coor::[])
    |Some s -> (coor, List.rev acc @ List.tl lst)

  (** [determinant4 ai int] chooses the right function to use based on whether
      or not the ai had previously hit a ship and hasn't sunk it yet. It takes
      the size of the largest alive ship [int] to use for the expert ai. This 
      is a helper function for the expert ai.*)
  let rec determinant4 ai int =
    match ai.current with 
    | [] -> begin if List.length ai.missed mod 7 = 0 then 
          find_ship ai.b ai.avail [] else 
          find_coor_cb ai.b ai.avail ai.missed int
      end 
    | _::_ -> find_coor_hit ai int

  (** [super_determinant ai int] determines which determinant to use using the
      ai's difficulty. *)
  let super_determinant ai int = 
    match ai.diff with
    |2 -> determinant2 ai int
    |3 -> determinant3 ai int
    |4 -> determinant4 ai int
    |_ -> failwith "not a valid difficulty"

  (** [hit ai int] calls the ai to play a turn determined by the difficulty of
      of the ai. [int] is the size of the largest enemy ship which must be
      positive.
      Dumb: ai chooses a random spot on the board to attack.
      Normal: ai chooses a random spot on the board to attack if it has not 
        successfully hit any thing. Once it has hit a ship, it will use logic
        to find out the rest of the ship using proximity and orientation 
        reference.
      Smart: ai references existing hit data and the length of the largest 
        alive enemy ship to make a decision on where to hit. Uses the 
        checkerboard strategy to minimize the number of turns needed to hit 
        a ship successfully. 
      Expert: ai does the same thing as the smart ai but for every 7 
        unsuccessful attacks, it references enemy data to automatically find
        a ship location and attacks it. It's cheap but effective.
  *)
  let hit ai int =
    init_random ();
    if ai.diff = 1 then dumb_hit ai else
      let coornewlst = super_determinant ai int in 
      ai.avail <- snd coornewlst;
      match BoardMaker.get_coor ai.b (fst coornewlst) with
      | None -> ai.missed <- (fst coornewlst):: ai.missed;
        ignore (BoardMaker.hit ai.b (fst coornewlst))
      | Some s -> begin match ShipMaker.health s with 
          | 0 -> failwith "impossible, hitting sunken ship"
          | 1 -> ai.missed <- ((fst coornewlst)::ai.current) @ ai.missed;
            ai.current <- []; ignore (BoardMaker.hit ai.b (fst coornewlst))
          | _ -> ai.current <- (fst coornewlst):: ai.current;
            ignore (BoardMaker.hit ai.b (fst coornewlst))
        end

  let random_ori () = init_random (); if Random.int 2 = 0 then true else false

  (* infinite loop possible here...*)
  let rec ai_create_ship ship board =
    init_random ();
    try 
      ShipMaker.ship_pos ship 
        (Random.int (BoardMaker.rows board - List.length ship),
         Random.int (BoardMaker.columns board - List.length ship))
        (random_ori ())
      |> BoardMaker.taken board
      |> ShipMaker.create 
      |> BoardMaker.place_ship board
    with
    | BadCoord s 
    | Invalid_argument s  
    | Taken s -> 
      ai_create_ship ship board

  let get_board ai = ai.self

  let get_ships ai = ai.ships

  let alive ai = List.exists (fun a -> ShipMaker.alive a) ai.ships

  let ai_player_init player size ships diff= 
    let board = BoardMaker.create size size in
    let ships = List.map (fun (s,n) -> ai_create_ship s board) ships in 
    let ai = ai_init diff 
        (PlayerMaker.get_board player) board ships in 
    let ai_player = PlayerMaker.create ships board "AI" in 
    ai_player, ai
end