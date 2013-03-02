open Core.Std
open Async.Std
open Cow
open Misc

let main_tmpl = "tmpl/main.html"

let t ?extra_header title content =
  let templates = [ "TITLE"       , <:html< $str:title$ >>
                  ; "EXTRA_HEADER", <:html< $opt:extra_header$ >>
                  ; "CONTENT"     , <:html< $content$ >> ]
  in
  Reader.file_contents main_tmpl
  >>| Html.of_string ~templates
;;
