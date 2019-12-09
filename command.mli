(**[orientation] represents the orientation of the desired ship*)
type orientation

(**[command] represents the types of valid commands in the game engine. *)
type command

(**Raised when a given cordinate cannot be numericaly represented. *)
exception BadCoord of string

(**[find_coords str] is the tuple integer representation of the string 
   coordinate [str].
   Example: "a5" -> (0,4)
   Raises: BadCoord if the string is not a coordinate. *)
val find_coords: string -> (int*int)

(**[orientation str] is true if [str] represents a valid vertical string or
   false if [str] represents a valid horizontal string. 
   Example: "v" -> true, "vertical" -> true
   Raises: Invalid_argument if [str] is not a valid orientation. *)
val orientation: string -> bool

(**[convert_coordinate (a,b)] is the string representation of the tuple int
   coordinate [(a,b)].
   Example: (1,2) -> "b3" *)
val convert_coordinate: int * int -> string