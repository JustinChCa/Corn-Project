open Player
open Commands
open Ship
open Board

module type Engine = sig
  type t
  val start : unit -> unit
  val run : unit -> unit
  val update : unit -> unit
  val draw : unit -> unit
end

module Engined = struct
  type t = int
end

