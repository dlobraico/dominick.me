open Core.Std
open Cow

open Misc

type t =
  { id        : int
  (* sqlite uses strings for timestamps anyway. Also, orm doesn't support Time.t or
     Float.t yet. *)
  ; timestamp : string
  ; title     : string
  ; body      : string
  } with html, fields
;;

let create ~id ~timestamp ~title ~body =
  let timestamp = Time.to_string timestamp in
  Fields.create ~id ~timestamp ~title ~body
;;

module Db = struct
  (*let all db = t_get db*)
  let all db = []
end
