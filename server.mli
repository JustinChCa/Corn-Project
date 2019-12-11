(**Represents an in_channel and an out_channel *)
type socket

(**Player representation in the server module *)
type player

(**Represents a server. *)
type server

(**State represents the different game states that the battleship game 
   could be in. *)
type state

(**[run_server ()] starts up the server with the hosts local ip address 
   and with a port of 8080.  *)
val run_server: unit -> unit

(**[configure_server ()] is a server record that contains all the important
    server information such as the server's ip address, port, and socket addr.
*)
val configure_server: unit -> server 


(**[issue_command ()] is the current state of the game in string form *)
val issue_command: unit -> string

(**[create_player_connn socc] is a record of a player type when given 
   a socket address [socc]. *)
val create_player_conn: Unix.file_descr -> string -> player

(**[establish_connections sock_addr] waits until two players have joined
    the server with the socket address [sock_addr]. Records the in_channel and
    out_channel connections for each person who connects to the server. *)  
val establish_connections: Unix.file_descr -> unit

