if [ $(ps ax | grep -v grep | grep "dal.native" | wc -l) -eq 0 ]
then
	echo "dal.native not running, starting now"
	nohup /home/deployer/apps/personal/dal.native -daemonize -environment production
fi
