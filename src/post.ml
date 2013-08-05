open Core.Std
open Cow

module S = Sqlite3

open Misc

type t =
  (* sqlite uses strings for timestamps anyway. *)
  { created_at  : string
  ; modified_at : string
  ; published   : bool
  ; link        : string option
  ; title       : string
  ; description : string
  } with html, fields
;;

let html_of_t t =
  let title : Html.t =
    match link t with
    | Some l -> <:html< <a href="$str:l$">$str:title t$</a> >>
    | None   -> <:html< $str:title t$ >>
  in
  <:html<
    <article class="post">
      <header>
        <h1 class="title">$title$</h1>
        <h2 class="created_at">$str:created_at t$</h2>
      </header>
      <div class="description">$Html.of_string (description t)$</div>
    </article>
    >>
;;

(* CR dlobraico: Create a html_form_of_t function (or similar) *)

let create = Fields.create

module Db = struct
  let all = Int.Table.create () ;;

  let load_all db =
    let sql = "SELECT * FROM Posts" in
    S.exec db sql ~cb:(fun row _headers ->
      let id          = Int.of_string (Option.value_exn (Array.get row 0)) in
      let title       = Option.value ~default:"" (Array.get row 1) in
      let link        = Array.get row 2 in
      let description = Option.value ~default:"" (Array.get row 3) in
      let created_at  = Time.of_string (Option.value_exn (Array.get row 4)) in
      let modified_at = Time.of_string (Option.value_exn (Array.get row 5)) in
      let published   =
        match Option.value_exn (Array.get row 6) with
        | "0" -> false
        | "1" | _ -> true
      in
      match Hashtbl.mem all id with
      | true -> ()
      | _ ->
        let fmt = "%l:%M %p, %d %B %Y" in
        let created_at  = Time.format created_at fmt in
        let modified_at = Time.format modified_at fmt in
        let post =
          create ~title ~link ~description ~created_at ~modified_at ~published
        in
        Hashtbl.replace all ~key:id ~data:post)
  ;;

  let save ~db t =
    (* CR-soon dlobraico: Why aren't times being written to db? *)
    let title = S.Data.TEXT (title t) in
    let link =
      match link t with
      | Some l -> S.Data.TEXT l
      | None -> S.Data.NULL
    in
    let description = S.Data.TEXT (description t) in
    let published = S.Data.INT (Bool.int64_of_t (published t)) in
    let created_at = S.Data.TEXT (created_at t) in
    let modified_at = S.Data.TEXT (modified_at t) in
    let sql =
      "INSERT INTO Posts (title, url, description, published, created_at, modified_at)
       VALUES (?, ?, ?, ?, ?, ?)"
    in
    let pstmt = S.prepare db sql in
    let _ =
      List.iteri
        ~f:(fun idx value -> ignore (S.bind pstmt (idx + 1) value))
        [title; link; description; published; created_at; modified_at]
    in
    S.step pstmt
  ;;
end
