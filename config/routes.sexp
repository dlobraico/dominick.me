(("/" (Html Post_index))
 ;; ("/post/:id" (Html (Post_show 0)))
 ("/posts/new" (Html Post_new))
 ("/posts/create" (Html Post_create))
 ("/projects" (Html Projects))
 ("/about" (Html About))
 ("/css/main.css" (Css Main))
 ("/css/reset.css" (Css Reset))
 ("/img/*" (Image "/img/*"))
 ("/fonts/*" (File "/fonts/*")))
