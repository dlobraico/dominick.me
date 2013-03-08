open Core.Std
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
    | Error _ -> return default)
  ;;

  let load = Memo.unit load

end

let production ?mode () =
  let config = load in
  db_open ?mode (production config)
;;

let development ?mode () =
  let config = load in
  db_open ?mode (development config)
;;
