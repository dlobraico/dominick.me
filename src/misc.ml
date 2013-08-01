open Core.Std
open Async.Std
open Cow

let setup_logging () =
  (* TODO: Make this more elegant. *)
  let open Env in
  let current = current () in
  let filename =
    match current with
    | Production ->  "log/production.log"
    | Development -> "log/development.log"
  in
  let outputs =
    match current with
    | Production  -> [ Log.Output.file `Text ~filename ]
    | Development -> [ Log.Output.stdout (); Log.Output.file `Text ~filename ]
  in
  let level =
    match current with
    | Production -> `Info
    | Development -> `Debug
  in
  Log.Global.set_output outputs;
  Log.Global.set_level level;
;;

module Log = Log.Global

module Float = struct
  include Float
  let html_of_t t = <:html< $str:(Float.to_string t)$ >>
end

module Time = struct
  include Time
  let html_of_t t = <:html< $str:(Time.to_string t)$ >>
end

module Bool = struct
  include Bool
  let int64_of_t = function
    | true  -> Int.to_int64 1
    | false -> Int.to_int64 0
  ;;
end
