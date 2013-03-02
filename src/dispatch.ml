open Core.Std
open Async.Std
open Cow
open Cohttp
open Cohttp_async

open Misc

module Content_types = struct
  let html =
    [("content-type", "text/html")]
  ;;

  let css =
    [("content-type", "text/css")]
  ;;
end

module Handler = struct
  let dynamic ?(headers=[]) request body =
    let status = `OK in
    let headers = Header.of_list headers in
    Server.respond_string ~headers ~status ~body ()
  ;;

  let css request path =
    let body =
      match path with
      | ["css"; "main.css"] -> <:css< html, body { color: blue; } >>
      | _ -> failwith "Not found"
    in
    dynamic ~headers:Content_types.css request (Css.to_string body)
  ;;

  let html request path =
    let content =
      match path with
      | [] -> <:html< <h1>Hi!</h1> >>
      | _  -> failwith "Not found"
    in
    Tmpl.t "main" content
    >>= fun body ->
    dynamic ~headers:Content_types.html request (Html.to_string body)
  ;;

  let file request path =
    Reader.file_contents (String.concat ~sep:"/" (List.cons "public" path))
    >>= dynamic request
  ;;

  let not_found request path =
    Server.respond_string ~status:`Not_found ~body:"Not found." ()
  ;;

  let exn exn =
    let body = Exn.to_string exn in
    eprintf "HTTP Error: %s\n%!" body;
    return ()
  ;;
end

let go conn_id ?body request =
  let path = List.drop (Filename.parts (Request.path request)) 1 in
  let handle =
    match List.hd path with
    | Some "css" | Some "styles"  -> Handler.css
    (* | Some "js"  | Some "scripts" -> Handler.js *)
    | Some "img" | Some "images"  -> Handler.file
    | Some _ -> Handler.html
    | None -> Handler.not_found
  in
  handle request path
;;
