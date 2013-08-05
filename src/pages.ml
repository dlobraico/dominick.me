open Core.Std
open Async.Std
open Cow
open Cohttp
open Cohttp_async

open Misc

(* Helpers *)
let static file =
  Reader.file_contents file
  >>| fun c -> <:html< $Html.of_string c$ >>
;;

(* Pages *)
module Post = struct
  let index () =
    return
    <:html<
      <div class="posts" id="index">
        <header><h1>Posts</h1></header>
        $list:(List.intersperse ~sep:(<:html< <div class="break"> </div> >>)
                (List.map ~f:Post.html_of_t (Hashtbl.data Post.Db.all)))$
      </div>
    >>
  ;;

  let show id () =
    return
      begin
        match Hashtbl.find Post.Db.all id with
        | Some p -> <:html< <div id="show" class="post"> $Post.html_of_t p$ </div> >>
        | None   -> <:html< <div id="show" class="post"> <p>Sorry, couldn't find that post.</p> </div> >>
      end
  ;;

  let new_ () =
    (* CR dlobraico: Re-create in cow so that we don't have to use the weird textarea
       hack. Or, figure out why cow can't parse it as is. *)
    static "tmpl/posts/new.html"
  ;;

  let create req body () =
    if not (Request.is_form req)
    then return <:html< <div class="posts" id="create"> $Html.of_string "Failure"$ </div> >>
    else
      begin
        Pipe.read (Option.value_exn body)
        >>| (function
        (* CR dlobraico: It seems like we should be using Request.read_form here but I don't
           see how it can be used here in its current form. *)
        | `Ok form -> Uri.query_of_encoded form
        | _ -> [])
        >>= fun query ->
        let getopt_f f = Option.map ~f:List.hd_exn (List.Assoc.find query f) in
        let getf f = Option.value ~default:"" (getopt_f f) in
        let published = if getf "published" = "" then false else true in
        let post =
          let now = Time.format (Time.now ()) "%F %T" in
          Post.create
            ~created_at:now
            ~modified_at:now
            ~published
            ~link:(getopt_f "link")
            ~title:(getf "title")
            ~description:(getf "description")
        in
        Env.db_of_t (Env.current ())
        >>| (fun db ->
          let result =
            match Post.Db.save ~db post with
            | Sqlite3.Rc.DONE ->
              (ignore (Post.Db.load_all db);
               "Success")
            | _ as rc -> sprintf "Error: %s" (Sqlite3.Rc.to_string rc)
          in
          <:html< <div class="posts" id="create"> $Html.of_string result$ </div> >>)
      end
  ;;
end

let projects () = static "tmpl/pages/projects.html"
let about () = static "tmpl/pages/about.html"
