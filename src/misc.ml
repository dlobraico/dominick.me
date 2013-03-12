open Core.Std
open Async.Std
open Cow

let setup_logging =
  (* Log.Global.set_output [ Log.Output.screen ]; *)
  let filename =
    let open Env in
    match current with
    | Production -> "log/production.log"
    | Development -> "log/development.log"
  in
  Log.Global.set_output [ Log.Output.screen; Log.Output.file `Text ~filename ];
  Log.Global.set_level  `Debug;
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
