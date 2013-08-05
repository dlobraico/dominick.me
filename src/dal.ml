open Core.Std
open Core_extended.Std
module Core_sys = Sys
open Async.Std

open Cohttp
open Cohttp_async
open Cow

open Misc

let port = 8888

let make_net_server () =
  Server.create (Tcp.on_port port) Dispatch.go
;;

let () =
  Command.async_basic
    ~summary:"Serve the dominick.me website"
    Command.Spec.(empty
                  +> flag "-daemonize"
                    no_arg
                    ~aliases:["-d"]
                    ~doc:" Run the server in the background"
                  +> flag "-environment"
                    (optional string)
                    ~aliases:["-e"]
                    ~doc:" Set the environment (production or development)")
    (fun daemonize environment_opt () ->
      Log.debug "daemonize = %b" daemonize;
      begin
        match environment_opt with
        | Some s -> Env.current_env := Env.of_string s
        | None   ->
          begin
            match Core_sys.getenv "DAL_ENV" with
            | Some s -> Env.current_env := Env.of_string s
            | _ -> ()
          end
      end;
      Log.debug "environment = %s" (Env.to_string (Env.current ()));
      setup_logging (); (* This has to happen after the environment is set. *)
      let release_parent =
        match daemonize with
        | true -> Daemon.daemonize_wait ~cd:"."
          ~redirect_stdout:`Do_not_redirect
          ~redirect_stderr:`Do_not_redirect
          ()
        | false -> Staged.stage (fun () -> ())
      in
      let s =
        Log.info "Starting dominick.me";
        Env.db_of_t (Env.current ())
        >>> (fun db ->
          (* CR dlobraico: lol fix this pretend caching? *)
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
