#!/bin/bash

if [ $# -lt 4  ]
then

	echo "use: ./genmotion.sh <initial rep. sequence> <final rep. sequence> <root destination folder> <mov_type>"
	echo "example: ./genmotion.sh 1 25 3UN_3AN RandomWaypoint -> for generating from 1 to 25 repetitions of RandonWaypoint based movements"
	echo ""
	echo "Remember to set up the bonnmotion_<mov_type>.params before running this script."
	exit 1

fi

# Number of repetitions of the simulation
rep=$(seq ${1} 1 ${2})
# Bonnmotion movement type
mov_type=${4}
# Destinantion folder to save the generated movements (bonnmotion.movements file) according to the bonnmotion_RandomWaypoint.params configuration file.
dest_path=${3}

for i in ${rep}
do
	echo ""
	echo "[+] Generating scenario for ${mov_type} in ${dest_path}/${mov_type}/${i}/"
	echo ""
	mkdir -p ${dest_path}/${mov_type}/${i}/
	./bonnmotiongen.sh ${mov_type} ${RANDOM} ${dest_path}/${mov_type}/${i}/
	echo ""
	echo "-------------------------------------------------------------------"

done


