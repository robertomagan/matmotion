#!/bin/bash


if [ $# -lt 3 ];then
	#echo "Use: ./bonnmotiongen.sh <#repetitions> <movement type> <seed> <generated_files_path>"
	echo "Use: ./bonnmotiongen.sh  <movement type> <seed> <generated_files_path>"
	exit 1
fi


#nrep=$1;
movtype=$1;
#nnodes=$3;
seed=$2;
destination=$3;

iter=1
	#while [  $iter -le $nrep ]; do
             echo "Generating the scenario ..."
             bm -f ${destination}bonnmotion -I bonnmotion.params ${movtype} -R ${seed} 
             #let iter=iter+1;
    	#done

gunzip -f ${destination}*.gz
