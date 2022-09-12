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
read -p "commit id filename: " input_id && commits=${afl_auto_dir}/commit_id/${input_id}
#read -p "commit date filename: " input_date && commit_dates=${afl_auto_dir}/commit_id/${input_date}

read -p "Seconds: " sec && seconds=${sec}

touch ${result_dir}/make_error.log && make_error=${result_dir}/make_error.log
touch ${result_dir}/make_error.detail && make_error_detail=${result_dir}/make_error.detail
touch ${result_dir}/make_success.log && make_success=${result_dir}/make_success.log
touch ${result_dir}/crashes_count.log && afl_crashes=${result_dir}/crashes_count.log

echo "object_id:	crashes" >> ${afl_crashes}

#echo -e "\n checkout orgin/master"
cd /home/kosuge/ctags-link
#git checkout -f origin/master

while read commit
do
	commit_id=`echo ${commit} | cut -d ' ' -f 1`	
	commit_date=`echo ${commit} | cut -d ' ' -f 2`

	echo -e "\n commit ID: ${commit_id}"
	
	echo -e "\n checkout now"
	git checkout -f ${commit_id}

	echo -e "\n make now"
	make clean
	echo ${commit_id} >> ${make_error_detail}
	make 2>> ${make_error_detail}

	if (($? != 0)); then
		echo -e "\n make failure \n"
		echo ${commit_id} >> ${make_error}
		continue
	fi

	echo ${commit_id} >> ${make_success}

	echo -e "\n make directory now"	
	mkdir ${out}/${commit_id}
	
	echo -e "\n afl-fuzz run"
	timeout ${seconds} afl-fuzz -i ${in} -o ${out}/${commit_id} -f input.c /home/kosuge/ctags-link/ctags input.c
	
	echo -e "\n crashes counting"
	crashes_count=`ls ${out}/${commit_id}/crashes | wc -l`
	#echo "${commit_id}:${crashes_count},${commit_date}" >> ${afl_crashes}
	echo "${commit_id}:${commit_date}:${crashes_count}" >> ${afl_crashes}
       	
	
done < ${commits}

echo -e "\n all finished! \n"
