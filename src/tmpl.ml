open Core.Std
open Async.Std
open Pcre
open Cow

open Misc

let main_tmpl = "tmpl/layouts/application.html"

let substitute vars template =
  List.fold vars ~init:template ~f:(fun tmpl (k, v) ->
    replace ~pat:("{" ^ k ^ "}") ~templ:(Html.to_string v) tmpl)
;;


let t ?extra_header title content =
  let vars = [ "TITLE"        , <:html< $str:title$ >>
             ; "EXTRA_HEADER" , <:html< $opt:extra_header$ >>
             ; "CONTENT"      , <:html< $content$ >> ]
  in
  Reader.file_contents main_tmpl
  >>| substitute vars
  >>| Html.of_string
;;
