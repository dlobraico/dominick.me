open Core.Std

type t = Production
       | Development
with sexp
;;

let default = Development
let current_env = ref default

let current () = !current_env

let to_string = function
  | Production -> "production"
  | Development -> "development"
;;

let of_string s =
  match String.lowercase s with
  | "production" -> Production
  | "development" -> Development
  | _ -> default

let db_of_t ?mode t =
  match t with
  | Production  -> Db.production  ?mode ()
  | Development -> Db.development ?mode ()
;;
