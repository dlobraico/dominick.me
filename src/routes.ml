open Core.Std
open Async.Std
open Misc

module Controller = struct
  module Page = struct
    type t = Post_index
             | Post_show
    with sexp
  end

  module Style = struct
    type t = Main | Reset
    with sexp
  end
end

module Path = struct
  type t = string
  with sexp
end

module Handler = struct
  type t = Html of Controller.Page.t
         | Css of Controller.Style.t
         | File of Path.t
  with sexp
  ;;
end

module Route = struct
  type t = ( Path.t * Handler.t ) with sexp
end

type t = Route.t list with sexp

let default_path = "config/routes.sexp"

let default = []

let load_all () =
  Unix.access default_path [`Exists] >>= function
  | Ok ()   -> Reader.load_sexp_exn default_path t_of_sexp
  | Error _ -> return default
;;

let load = Memo.unit load_all

let resolve t path = List.Assoc.find t path
