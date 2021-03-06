open Core.Std
open Async.Std
open Cow
open Cohttp
open Cohttp_async

open Misc

module Content_type = struct
  let html = [ ("content-type", "text/html") ]
  let css =  [ ("content-type", "text/css") ]
  let image_t =  [ ("svg",  [ ("content-type", "image/svg+xml") ])
                 ; ("png",  [ ("content-type", "image/png") ])
                 ; ("jpg",  [ ("content-type", "image/jpg") ])
                 ; ("gif",  [ ("content-type", "image/gif") ])
                 ; ("tiff", [ ("content-type", "image/tiff") ]) ]

  let image_t_of_filename f =
    let (_, e) = Filename.split_extension f in
    match e with
    | Some ext -> List.Assoc.find image_t ext
    | None -> None
  ;;
end

module Handler = struct
  let hlog handler path =
    let path = String.concat ~sep:"/" (Option.value ~default:[] (List.tl path)) in
    Log.debug "entering %s handler with path %s" handler path
  ;;

  let dynamic ?(headers=[]) request body =
    let code = `OK in
    let headers = Header.of_list headers in
    Server.respond_with_string ~headers ~code body
  ;;

  let not_found request path =
    hlog "not_found" path;
    Server.respond_with_string ~code:`Not_found "Not found."
  ;;

  let css request controller =
    (* CR dlobraico: Currently, we are using actual CSS files here instead of using Cow to
       write them in OCaml. *)
    Log.debug "entering css handler with controller %s"
      (Sexp.to_string (Routes.Controller.Style.sexp_of_t controller));
    (let open Routes.Controller.Style in
     match controller with
     | Main ->  "public/css/main.css"
     | Reset -> "public/css/reset.css")
    |> Server.respond_with_file ~headers:(Header.of_list Content_type.css)
  ;;

  let html request body controller =
    Log.debug "entering html handler with controller %s"
      (Sexp.to_string (Routes.Controller.Page.sexp_of_t controller));
    begin
      let open Routes.Controller.Page in
      match controller with
      | Post_index -> Pages.Post.index ()
      | Post_create -> Pages.Post.create request body ()
      | Post_new -> Pages.Post.new_ ()
      (* CR dlobraico: Add support for routes with parameters. *)
      | Post_show id -> Pages.Post.show id ()
      | Projects -> Pages.projects ()
      | About    -> Pages.about ()
    end
    >>= fun c -> Tmpl.t "main" c
    >>= fun body ->
    dynamic ~headers:Content_type.html request (Html.to_string body)
  ;;

  let image request path =
    hlog "image" (Filename.parts path);
    let headers =
      Option.map ~f:Header.of_list (Content_type.image_t_of_filename path)
    in
    Server.respond_with_file ?headers path
  ;;

  let file request path =
    hlog "file" (Filename.parts path);
    Server.respond_with_file path
  ;;

  let exn exn =
    let body = Exn.to_string exn in
    eprintf "HTTP Error: %s\n%!" body;
    return ()
  ;;
end

let go ~body sock request =
  Routes.load ()
  >>= fun routes ->
  let uri  = Request.uri request in
  let path = Uri.path uri in
  let route = Routes.resolve routes path in
  let open Routes.Handler in
  match route with
  | Some (Css controller)  -> Handler.css request controller
  | Some (File path) -> Handler.file request path
  | Some (Image path) -> Handler.image request path
  | Some (Html controller) -> Handler.html request body controller
  | _ -> Handler.not_found request (Filename.parts path)
;;
