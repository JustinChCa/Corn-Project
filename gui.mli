(** [draw_board board self x y size] draws [board] with lower left corner at
    [x, y] and [width = height = size]. *)
val draw_board : Board.BoardMaker.t -> bool -> int -> int -> int -> unit

(** [draw_field player enemy x1 y1 x2 y2 size1 size2] draws [player] with 
    lower left corner at [x1, y1] and [width = height = size1] and same for
    [enemy] using [x2, y2 and size2]*)
val draw_field : Board.BoardMaker.t -> Board.BoardMaker.t -> int -> int -> 
  int -> int -> int -> int -> unit

(** [draw_background ()] resizes the window and draws the game background.*)
val draw_background : unit -> unit

(** [draw_main_menu ()] resizes the window and draws the game menu.*)
val draw_main_menu : unit -> unit

(** [draw_swap ()] resizes the window and draws the swapping screen.*)
val draw_swap: unit -> unit

(** [draw_alives_ships player] draws a scoreboard showing how many of [player]'s
    ships are alive.*)
val draw_alive_ships : Player.PlayerMaker.t -> unit

(** [draw_backboard board x y size] draws the background and [board] at
    llc [x, y] and width and height of [size].*)
val draw_backboard: Board.BoardMaker.t -> int -> int -> int -> unit

(** [draw_battlefield player enemy x1 y1 x2 y2 size1 size2] draws [player] and
    [enemy] boards using [x1, y1, size1] and [x2, y2, size2] respectively with 
    [bsize] as a guide.*)
val draw_battlefield : Player.PlayerMaker.t -> Player.PlayerMaker.t -> int -> 
  int -> int -> int -> int -> int -> unit

(** [draw_victory name] resizes the window and draws the game victory screen
    for [name] then waits for any menu key to be pressed.*)
val draw_victory : string -> unit

(** [draw_defeat name] resizes the window and draws the game defeat screen for 
    [name] then waits for any menu key to be pressed.*)
val draw_defeat : string -> unit

(** [draw_start ()] shows the graphics window and sets the title to 
    "Battleship".*)
val draw_start: unit -> unit