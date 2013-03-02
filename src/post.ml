open Core.Std
open Cow
open Misc

type t =
  { id        : int
  ; timestamp : Time.t
  ; title     : string
  ; body      : string
  } with html, fields

let create = Fields.create
