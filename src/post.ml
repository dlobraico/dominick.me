open Core.Std
open Cow

module S = Sqlite3

open Misc

type t =
  (* sqlite uses strings for timestamps anyway. *)
  { created_at  : string
  ; modified_at : string
  ; published   : bool
  ; link        : string
  ; title       : string
  ; description : string
  } with html, fields
;;

let html_of_t t =
  <:html<
    <article class="post">
      <header>
        <a href=$str:link t$>
          <h1>$str:title t$</h1>
        </a>
        <h2>$str:created_at t$</h2>
      </header>
      <div class="description">$str:description t$</div>
    </article>
    >>
;;

let create ~created_at ~modified_at ~published ~link ~title ~description =
  (* let created_at = Time.to_string created_at in *)
  (* let modified_at = Time.to_string modified_at in *)
  Fields.create ~created_at ~modified_at ~published ~link ~title ~description
;;

module Db = struct
  let all = Int.Table.create () ;;

  let load_all db =
    let sql = "SELECT * FROM Posts" in
    S.exec db sql ~cb:(fun row _headers ->
      let id          = Int.of_string (Option.value_exn (Array.get row 0)) in
      let title       = Option.value_exn (Array.get row 1) in
      let link        = Option.value_exn (Array.get row 2) in
      let description = Option.value_exn (Array.get row 3) in
      let created_at  = Option.value_exn (Array.get row 4) in
      let modified_at = Option.value_exn (Array.get row 5) in
      let published   =
        match Option.value_exn (Array.get row 6) with
        | "0" -> false
        | "1" | _ -> true
      in

      let post = create ~title ~link ~description ~created_at ~modified_at ~published in
      Hashtbl.replace all ~key:id ~data:post)
  ;;
end
