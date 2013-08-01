open Core.Std
open Core_extended.Std
open Async.Std
open Misc

module Controller = struct
  module Page = struct
    type t = Post_index
           (* | Post_create *)
           | Post_show of int
           | Post_new
           | Projects
           | About
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
         | Image of Path.t
         | File of Path.t
  with sexp
  ;;
end

module Route = struct
  type t = ( Path.t * Handler.t ) with sexp
end

type t = Route.t list with sexp

(* CR dlobraico: We should manually define t_of_sexp and sexp_of_t for Routes so we can do
   some custom parsing. *)
(* let t_of_sexp sexp =
 *   let open Sexp in
 *   let parse_entry = function
 *     | Atom _ -> failwith "expected a list"
 *     | List [ path; handler ] ->
 *       begin
 *         let path = match path with | Atom a -> a | _ -> failwith "expected an Atom" in
 *         (path, Handler.t_of_sexp handler)
 *       end
 *     | List _ -> failwith "expected a list of length 2"
 *   in
 *   match sexp with
 *   | Atom _ -> failwith "expected a list"
 *   | List ls -> List.map ~f:parse_entry ls
 * ;;
 *
 * let sexp_of_t t =
 *   ...
 * ;; *)

let default_path = "config/routes.sexp"

let default = []

let resolve_globs routes =
  let find_route filepath =
    let dirname = "public" ^/ (Filename.dirname filepath) in
    let basename = Filename.basename filepath in
    Shell.run_lines "find"
      [dirname ; "-name" ; basename ; "-mindepth" ; "1" ; "-maxdepth" ; "1"]
  in
  List.fold ~init:[]
    ~f:(fun acc (path, handler) ->
      match Filename.basename path with
      | "*" ->
        begin
          let p = Filename.dirname path in
          match handler with
          | Handler.File filepath ->
            List.fold ~init:acc (find_route filepath)
              ~f:(fun acc filepath ->
                let path =
                  p ^/ (Filename.basename filepath)
                in
                (path, Handler.File filepath) :: acc)
          | Handler.Image imagepath ->
            List.fold ~init:acc (find_route imagepath)
              ~f:(fun acc imagepath ->
                let path =
                  p ^/ (Filename.basename imagepath)
                in
                (path, Handler.Image imagepath) :: acc)
          | _ -> (path, handler) :: acc
        end
      | _ -> (path, handler) :: acc)
    routes
;;

let load_all () =
  (Unix.access default_path [`Exists] >>= function
  | Ok ()   -> Reader.load_sexp_exn default_path t_of_sexp
  | Error _ -> return default)
  >>| (fun routes -> resolve_globs routes)
;;

let load = Memo.unit load_all

let resolve t path =
  List.Assoc.find t path
;;
