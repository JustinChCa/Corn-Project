type order = LT | GT | EQ

module type Comparable = sig
  type t
  val compare: t -> t -> order
end

module type Formattable = sig
  type t
  val format: Format.formatter -> t -> unit
end

module type Ship = sig
  type t
  val yes: int
end

module ShipMaker