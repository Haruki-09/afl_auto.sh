#!/usr/local/bin/bash

function ctrl_c {

	echo -e "\n ctrl+C \n"
	exit
}

trap ctrl_c SIGINT

export CC=/usr/local/bin/afl-gcc

time=`date +"%Y_%m_%d_%H:%M"`
afl_auto_dir=/home/kosuge/afl-auto
result_dir=${afl_auto_dir}/result/${time}

mkdir -p ${result_dir}/Out
out=${result_dir}/Out
in=${afl_auto_dir}/In

echo -e "\n Please select commit id file \n" ; ls ${afl_auto_dir}/commit_id
read -p "commit id filename: " inputfile && commits=${afl_auto_dir}/commit_id/${inputfile}

read -p "Seconds: " sec && seconds=${sec}

touch ${result_dir}/make_error.log && make_error=${result_dir}/make_error.log
touch ${result_dir}/make_error.detail && make_error_detail=${result_dir}/make_error.detail
touch ${result_dir}/make_success.log && make_success=${result_dir}/make_success.log

#echo -e "\n checkout orgin/master"
cd /home/kosuge/ctags-link
#git checkout -f origin/master

while read commit
do	
	echo -e "\n commit ID: ${commit}"
	
	echo -e "\n checkout now"
	git checkout -f ${commit}

	echo -e "\n make now"
	make clean
	echo ${commit} >> ${make_error_detail}
	make 2>> ${make_error_detail}

	if (($? != 0)); then
		echo -e "\n make failure \n"
		echo ${commit} >> ${make_error}
		continue
	fi

	echo ${commit} >> ${make_success}

	echo -e "\n make directory now"	
	mkdir ${out}/${commit}
	
	echo -e "\n afl-fuzz run"
	timeout ${seconds} afl-fuzz -i ${in} -o ${out}/${commit} -f input.c /home/kosuge/ctags-link/ctags input.c 
	
done < ${commits}

echo -e "\n all finished! \n"
