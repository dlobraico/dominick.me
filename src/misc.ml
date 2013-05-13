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
    | Development -> [ Log.Output.screen; Log.Output.file `Text ~filename ]
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

module List = struct
  (* Core.List doesn't include the flatten function which apparently causes problems with
     Cow's quoting mechanism. *)
  include List
  let flatten = concat
end

module Float = struct
  include Float
  let html_of_t t = <:html< $str:(Float.to_string t)$ >>
end

module Time = struct
  include Time
  let html_of_t t = <:html< $str:(Time.to_string t)$ >>
end
