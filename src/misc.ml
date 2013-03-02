open Core.Std
open Cow

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
