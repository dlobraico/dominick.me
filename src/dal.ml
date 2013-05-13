open Core.Std
open Core_extended.Std
open Async.Std
open Cohttp
open Cohttp_async
open Cow

open Misc

let port = 8888;;

let make_net_server () =
  Server.create (Tcp.on_port port) Dispatch.go
;;

let () =
  Command.async_basic ~summary:"Serve the dominick.me website"
    Command.Spec.(empty
                  +> flag "-daemonize"
                    no_arg
                    ~aliases:["-d"]
                    ~doc:" Run the server in the background")
    (fun daemonize () ->
      Log.debug "daemonize = %b" daemonize;
      let release_parent =
        match daemonize with
        | true -> Daemon.daemonize_wait ~cd:"."
          ~redirect_stdout:`Do_not_redirect
          ~redirect_stderr:`Do_not_redirect
          ()
        | false -> Staged.stage (fun () -> ())
      in
      let s =
        (*Log.info "Ignoring daemonize setting";*)
        Log.info "Starting dominick.me";
        Env.db_of_t Env.current
        >>> (fun db ->
          Clock.every
            (Time.Span.of_min 2.0)
            (fun () -> ignore (Post.Db.load_all db)));
        make_net_server ()
        >>| fun _server ->
        Log.info "Server started on port %d" port
      in
      don't_wait_for s;
      let release_parent = Staged.unstage release_parent in
      release_parent ();
      never_returns (Scheduler.go ()))
  |! Command.run
;;
