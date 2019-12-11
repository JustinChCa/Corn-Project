(** The [ClientEngine] module for running the online version of battleship. *)

(**[create_enemy_player size ships args] creates an enemy player with a board 
   size of [size] and a ships list of [ships] at coordinate positions [args] *)
val create_enemy_player: int -> ((int * int) list * 'a) list -> string list -> 
  Player.PlayerMaker.t

(**[create_client_player size ships ic oc] creates the client's player using a
   board size of [size] with a list of ships [ships]. The client's ships 
   arragnements are then transmitted to the server on the out channel [oc]*)
val create_client_player: int -> ((int * int) list * string) list -> 
  out_channel -> Player.PlayerMaker.t

(**[hit_handler_outbound player enemy oc] lets the current player [player] 
   attack the enemy player enemy. Outputs the coordinate that the player
   attacked to the server on the out_channel [oc]. *)
val hit_handler_outbound: Player.PlayerMaker.t -> Player.PlayerMaker.t 
  -> out_channel -> unit

(**[hit_handler_inbound player enemy arg] updates the local client
   game of the player [player]  *)
val hit_handler_inbound: Player.PlayerMaker.t -> Player.PlayerMaker.t 
  -> string -> unit

(**[fail_condition ()] triggers the failure screen when a player loses. 
   Disconnects from the server.*)
val fail_condition: unit -> 'a

(**[lobby t] displays either the lobby waiting message for waiting for more
   users to connect to the server if [t] is true or for waiting until the other
   person finishes their turn is [t] is false. *)
val lobby: bool -> unit