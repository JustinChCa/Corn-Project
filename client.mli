
(**[start] initalizes the server when a user types make server in
    the terminal. *)
val start: unit -> unit

(**[create_socket_connection ip port] creates a client side socket connection 
    to the server with an ip address of [ip] and port [port]*)
val create_socket_connection: string -> int -> Unix.sockaddr


