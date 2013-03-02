open Core.Std
open Cow

module List = struct
  (* Core.List doesn't include the flatten function which causes problems with Cow's
     quoting mechanism. *)
  include List
  let flatten = concat
end

module Time = struct
  include Time
  let html_of_t t = <:html< $str:to_string t$ >>
end
