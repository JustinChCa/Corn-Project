
(**[print_double b1 b2] displays the player's current board [b1] and the
   hits/misses made to the enemy's board [b2] *)
val print_double: Board.BoardMaker.t -> Board.BoardMaker.t -> unit

(**[a_endline str] prints the string [str] with special white formatting. *)
val a_endline: string -> unit

(**[read_txt ic] is a string that contains all of characters inside of the file
   given by the file in_channel [ic] *)
val read_txt: in_channel -> string

(**[print_board b] prints the board [b] *)
val print_board: Board.BoardMaker.t -> unit

(**[create_general_ship] creates a ship [f] with a name [name] on the board
   [board] at coord [coord] with orientation [orient] *)
val create_general_ship: (int * int -> bool -> (int * int) list) ->
  'a -> Board.BoardMaker.t -> string -> string -> Ship.ShipMaker.t

(**[place_ships board ships func] places the ships [ships] on the [board] using
   the function [func]. *)
val place_ships: 'a -> ('b * 'c) list -> ('b -> 'c -> 'a -> 'd) -> 'd list

(**[title] is the title of the game in a string *)
val title: string

(**[ships_list] is the list of the default ships in the game. *)
val ship_list: ((int * int -> bool -> (int * int) list) * string) list

(**[main] starts the singleplayer version of the battleship game *)
val main: unit -> unit