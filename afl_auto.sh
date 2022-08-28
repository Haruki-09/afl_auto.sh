#!/usr/local/bin/bash

function ctrl_c {

	echo 'ctrl+C'
	exit
}

trap ctrl_c SIGINT

export CC=/usr/local/bin/afl-gcc

ls /home/kosuge/afl-auto/commit_id/
read -p "commit id filename: " inputfile
commits=/home/kosuge/afl-auto/commit_id/${inputfile}
in=/home/kosuge/afl-auto/In/
out=/home/kosuge/afl-auto/Out/
make_error=/home/kosuge/afl-auto/make_error.log
seconds=30

echo -e "\n checkout origin/master now"
cd /home/kosuge/ctags-link
git checkout origin/master

while read commit
do	
	echo -e "\n commit ID: ${commit}"
	
	echo -e "\n checkout now"
	git checkout ${commit}

	echo -e "\n make now"
	make clean	
	make

	if (($? != 0)); then
		echo -e "\n make failure \n"
		echo ${commit} >> ${make_error}
		continue
	fi

	echo -e "\n make directory now"	
	mkdir ${out}/${commit}
	
	echo -e "\n afl-fuzz run"
	timeout ${seconds} afl-fuzz -i ${in} -o ${out}/${commit} -f input.c /home/kosuge/ctags-link/ctags input.c 
		

done < ${commits}

echo -e "all finished! \n"
