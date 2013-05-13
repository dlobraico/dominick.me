#!/bin/sh

cd /home/deployer/apps/personal
git pull git@git.pyg8.com:dominick.me.git master
echo "recompiling scss"
sass --update tmpl/sass:public/css
echo "stopping server"
pkill -9 dal.native
echo "rebuilding"
ocamlbuild -use-ocamlfind src/dal.native
echo "starting server"
nohup /home/deployer/apps/personal/dal.native -daemonize -environment production
