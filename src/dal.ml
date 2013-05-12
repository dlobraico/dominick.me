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
  Command.async_basic ~summary:"Serve the dominick.me website"
    Command.Spec.(empty
                  +> flag "-daemonize"
                    no_arg
                    ~aliases:["-d"]
                    ~doc:" Run the server in the background")
    (fun daemonize () ->
      let release =
        match daemonize with
        | true -> Daemon.daemonize_wait ()
        | false -> Staged.stage (fun () -> ())
      in
      let s =
        Log.info "Ignoring daemonize setting";
        Log.info "Starting dominick.me";
        Env.db_of_t Env.current
        >>> (fun db ->
          Clock.every
            (Time.Span.of_min 2.0)
            (fun () -> ignore (Post.Db.load_all db)));
        main port
        >>| fun _server ->
        Log.info "Server started on port %d" port
      in
      don't_wait_for s;
      Staged.unstage release ();
      never_returns (Scheduler.go ()))
  |! Command.run
;;
