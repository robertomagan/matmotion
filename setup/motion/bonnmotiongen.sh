#!/bin/bash


if [ $# -lt 3 ];then
	echo "Use: ./bonnmotiongen.sh  <movement type> <seed> <generated_files_path>"
	exit 1
fi

movtype=$1;
seed=$2;
destination=$3;

../../bonnmotion-3.0.1/bin/bm -f ${destination}bonnmotion -I bonnmotion_${movtype}.params ${movtype} -R ${seed} 

gunzip -f ${destination}bonnmotion.movements.gz
