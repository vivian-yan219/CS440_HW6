#!/bin/bash

rm -rf ./checkpoint_topk

rm ./result/global_top.txt
touch ./result/global_top.txt
rm ./result/window_top.txt
touch ./result/window_top.txt

rm ./result/windowDiff
rm ./result/globalDiff
touch ./result/windowDiff
touch ./result/globalDiff

python3 main.py &
sleep 6
serverPID=$!
echo $serverPID
./input/read_file.sh | nc -l -p 9009 &

ncPID=$!

declare -i timeCount=0
ln=`wc -l < './result/window_top.txt'`
while [ $ln -lt 10 ]
do
	timeCount+=1
	if [ $timeCount -eq 40 ];
	then
		break
	fi

	ln=`wc -l < './result/window_top.txt'`
	sleep 1
done


echo "task complete"
kill -s 9 $serverPID
kill -s 9 $ncPID

sleep 1
clear

diff <(head -n 10 ./result/window_top.txt) <(head -n 10 ./result/expected_window.txt) > windowDiff
diff <(head -n 10 ./result/global_top.txt) <(head -n 10 ./result/expected_global.txt) > globalDiff

windowDiffExist=`wc -l < './result/windowDiff'`
globalDiffExist=`wc -l < './result/globalDiff'`

echo "Result:"

if [ $windowDiffExist -eq 0 ] ;
then
		echo "Task 1: PASS!"
else
		echo "Task 1: Failed."
fi

if [ $globalDiffExist -eq 0 ] ;
then
		echo "Task 2: PASS!"
else
		echo "Task 2: Failed."
fi
