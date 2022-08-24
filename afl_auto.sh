#!/usr/local/bin/bash

export CC=/usr/local/bin/afl-gcc

commits=/home/kosuge/afl-auto/commit_id/log5.txt
in=/home/kosuge/afl-auto/In/
out=/home/kosuge/afl-auto/Out/
seconds=30

echo -e "checkout origin/master now"
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

	echo -e "\n make directory now"	
	mkdir ${out}/${commit}
	
	echo -e "\n afl-fuzz run"
	timeout ${seconds} afl-fuzz -i ${in} -o ${out}/${commit} -f input.c /home/kosuge/ctags-link/ctags input.c 
	

done < ${commits}

echo -e "all finished! \n"
