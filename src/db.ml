open Core.Std
open Async.Std
open Sqlite3

module Config = struct
  type t =
    { production  : string
    ; development : string }
  with sexp, fields
  ;;

  let default_path = "config/db.sexp"

  let default =
    { production  = "db/production.db"
    ; development = "db/development.db" }
  ;;

  let load () =
    (Unix.access default_path [`Exists] >>= function
    | Ok ()   -> Reader.load_sexp_exn default_path t_of_sexp
    | _ -> return default)
  ;;

  let load = Memo.unit load

end

let production ?mode () =
  Config.load ()
  >>| fun config ->
  db_open ?mode (Config.production config)
;;

let development ?mode () =
  Config.load ()
  >>| fun config ->
  db_open ?mode (Config.development config)
;;
