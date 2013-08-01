open Core.Std
open Async.Std
open Cow

open Misc

let static file =
  Reader.file_contents file
  >>| fun c -> <:html< $Html.of_string c$ >>
;;

module Post = struct
  let new_ () = static "tmpl/posts/new.html"

  let show id () =
    return
      begin
        match Hashtbl.find Post.Db.all id with
        | Some p -> <:html< <div id="show" class="post"> $Post.html_of_t p$ </div> >>
        | None   -> <:html< <div id="show" class="post"> <p>Sorry, couldn't find that post.</p> </div> >>
      end
  ;;

  let create () =
    (* let x = Request.read_form request (Pipe.init (fun w -> Pipe.write w request)) in
     * Log.debug x; *)
    return <:html< <div class="posts" id="create"> $Html.of_string "Success"$ </div> >>
    ;;
end

let projects () = static "tmpl/pages/projects.html"
let about () = static "tmpl/pages/about.html"
