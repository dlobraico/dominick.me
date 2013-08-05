PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE posts (
id INTEGER,
title TEXT,
url   TEXT,
description TEXT,
created_at DATETIME,
modified_at DATETIME,
published BOOLEAN,
PRIMARY KEY (id)
);
INSERT INTO "posts" VALUES(0,'My first post','http://dj.lobraico.com','This is the first post to my new Clojure-powered linkblog! Here is some more text just to fill space and see what a longer post looks like.','2012-11-20T05:51:08','2012-11-20 05:51:08',1);
INSERT INTO "posts" VALUES(1,'Another post','http://google.com','Google is an awesome new search engine brought to you by some dudes from Stanford. In my early testing every search result is exactly what I was looking for.','2012-12-28T12:00:00','2012-12-28T12:00:00',1);
INSERT INTO "posts" VALUES(3,'Test post without a URL',NULL,'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis convallis nulla in nulla vestibulum non rhoncus tellus vehicula. Morbi auctor massa et ipsum commodo nec elementum felis tincidunt. Cras elementum dapibus sem in vehicula. Cras lobortis lobortis cursus. Nunc vel lacus nec justo bibendum lobortis et a tortor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Fusce in erat id tellus dictum interdum. Integer eget quam nec erat pellentesque ornare at ac lorem. Mauris blandit velit eros, pharetra ultricies justo. Maecenas egestas condimentum mi, sit amet blandit lacus vulputate in. Nulla facilisi. Cras quis nibh orci, sed tempor turpis. Nunc enim mi, varius eu fermentum eget, porta non lacus. Etiam lorem nibh, malesuada sit amet convallis convallis, rhoncus ut lacus. Proin scelerisque diam vel est gravida vel bibendum nisi consectetur. Sed ac consectetur elit.','2013-05-12 22:33:57','2013-05-12 22:34:03',1);
INSERT INTO "posts" VALUES(4,'Another test post without a URL',NULL,'This post also has no URL.','2013-05-12 22:56:17','2013-05-12 22:56:12',1);
INSERT INTO "posts" VALUES(5,'Another another test post without a URL',NULL,'This post is also a post that has no URL.','2013-05-12 23:26:10','2013-05-12 23:26:10',1);
COMMIT;
