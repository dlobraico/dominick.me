open Core.Std
open Misc

type t = Production
       | Development
with sexp
;;

let current =
  match Option.map ~f:String.lowercase (Sys.getenv "DAL_ENV") with
  | Some "production" -> Production
  | Some "development" -> Development
;;

let db_of_t ?mode t =
  match t with
  | Production  -> Db.Config.production  ?mode ()
  | Development -> Db.Config.development ?mode ()
;;
