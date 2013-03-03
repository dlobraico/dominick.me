open Core.Std
open Core_extended.Std
open Async.Std
open Cohttp
open Cohttp_async
open Cow

open Misc

let port = 8888;;

let main port =
  let config =
    { Server.callback = Dispatch.go
    ; port }
  in
  Server.main config
;;

let () =
  let query = Post.Db.all () in
  Log.info "%s" (List.to_string ~f:(Fn.id) query);
  let s =
    Log.info "Starting dominick.me";
    main port
    >>| fun _server ->
    Log.info "Server started on port %d" port
  in
  don't_wait_for s;
  never_returns (Scheduler.go ())
;;
