#!/bin/sh
p="$HOME/pnote.md"

cat ${p} | while read line
do
	if [ ${line:0:1} == "," ];then
		continue
	fi
	echo $line | fold -w 30
done
