open Core.Std
open Core_extended.Std
open Async.Std
open Cohttp_async
open Cow

open Misc

let setup_logging =
  Log.Global.set_output [ Log.Output.screen ];
  Log.Global.set_level  `Debug;
;;

module Log = Log.Global

let port = 8888;;

let callback conn_id ?body request =
  ignore conn_id;
  ignore body;
  ignore request;
  let body = "Hello world." in
  let response = Server.respond_string ~status:`OK ~body () in
  response
;;

let main port =
  let config =
    { Server.callback = callback
    ; port }
  in
  Server.main config
;;

let () =
  let post = Post.create ~id:0 ~timestamp:(Time.now ()) ~title:"Test" ~body:"This is a post!" in
  let content = Post.html_of_t post in
  Tmpl.t "main" content >>> (fun t -> Log.info "%s" (Html.to_string t));
  let s =
    Log.info "Starting dominick.me";
    main port
    >>| fun _server ->
    Log.info "Server started on port %d" port
  in
  don't_wait_for s;
  never_returns (Scheduler.go ())
;;
