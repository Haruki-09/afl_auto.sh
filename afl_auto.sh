#!/usr/local/bin/bash

function ctrl_c {

	echo -e "\n ctrl+C \n"
	exit
}

trap ctrl_c SIGINT

export CC=/usr/local/bin/afl-gcc

echo -e "\n ls commit_id \n"
ls /home/kosuge/afl-auto/commit_id/
read -p "commit id filename: " inputfile
commits=/home/kosuge/afl-auto/commit_id/${inputfile}
in=/home/kosuge/afl-auto/In/
out=/home/kosuge/afl-auto/Out/
make_error=/home/kosuge/afl-auto/make_error.log
seconds=30

echo -e "\n checkout afl official commit"
cd /home/kosuge/ctags-link
git checkout afl_official_commit

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

echo -e "\n all finished! \n"
