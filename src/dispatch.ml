open Core.Std
open Async.Std
open Cow
open Cohttp
open Cohttp_async

open Misc

module Content_type = struct
  let html = [ ("content-type", "text/html") ]
  let css =  [ ("content-type", "text/css") ]
end

module Handler = struct
  let hlog handler path =
    let path = String.concat ~sep:"/" (Option.value ~default:[] (List.tl path)) in
    Log.debug "entering %s handler with path %s" handler path
  ;;

  let dynamic ?(headers=[]) request body =
    let status = `OK in
    let headers = Header.of_list headers in
    Server.respond_string ~headers ~status ~body ()
  ;;

  let not_found request path =
    hlog "not_found" path;
    Server.respond_string ~status:`Not_found ~body:"Not found." ()
  ;;

  let css request controller =
    (* TODO: Currently, we are using actual CSS files here instead of using Cow to write
       them in OCaml. *)
    Log.debug "entering css handler with controller %s"
      (Sexp.to_string (Routes.Controller.Style.sexp_of_t controller));
    let body =
      let open Routes.Controller.Style in
      match controller with
      | Main -> Reader.file_contents "public/css/main.css"
      | Reset -> Reader.file_contents "public/css/reset.css"
    in
    body
    >>= (fun body ->
    dynamic ~headers:Content_type.css request body)
  ;;

  let html request controller =
    Log.debug "entering html handler with controller %s"
      (Sexp.to_string (Routes.Controller.Page.sexp_of_t controller));
    let content = <:html< <h1>Hi!</h1> >> in
    Tmpl.t "main" content
    >>= fun body ->
    dynamic ~headers:Content_type.html request (Html.to_string body)
  ;;

  let file request path =
    hlog "file" path;
    Reader.file_contents (String.concat ~sep:"/" path)
    >>= dynamic request
  ;;

  let exn exn =
    let body = Exn.to_string exn in
    eprintf "HTTP Error: %s\n%!" body;
    return ()
  ;;
end

let go conn_id ?body request =
  Routes.load ()
  >>= fun routes ->
  let path  = Request.path request in
  let route = Routes.resolve routes path in
  let open Routes.Handler in
  match route with
  | Some (Css controller)  -> Handler.css request controller
  | Some (File path) -> Handler.file request (Filename.parts path)
  | Some (Html controller) -> Handler.html request controller
  | _ -> Handler.not_found request (Filename.parts path)
;;
