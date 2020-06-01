if [ $# -eq 0 ]
then
	echo "please provide a commit message"
else
	git add . 
	git commit -m "$1"
	git pull origin master
	git push origin master 
fi
