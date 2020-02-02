#!/bin/bash

if [ $# -lt 4  ]
then

	echo "use: ./genmotion_mix.sh <initial rep. sequence> <final rep. sequence> <root destination folder> <mix>"
	echo "example: ./genmotion_mix.sh 1 25 3UN_3AN 1 -> for generating from 1 to 25 repetitions of RPGM+RWP mixed movements"
	echo "mix -> 1 RPGM+RWP movements, mix -> 0 RWP movements only"
	exit 1

fi

rep=$(seq ${1} 1 ${2})

mix=${4}


if [ ${mix} == 1 ]
then

	for i in ${rep}
	do
		mkdir -p ${3}/RPGM/${i}
		./bonnmotiongen.sh RandomWaypoint ${RANDOM} ${3}/RPGM/${i}/
		mv ${3}/RPGM/${i}/bonnmotion.movements ${3}/RPGM/${i}/bonnmotion.movements_RandomWaypoint

	done

	for i in ${rep}
	do
 		#mkdir -p ${3}/RPGM/${i}
		./bonnmotiongen.sh RPGM ${RANDOM} ${3}/RPGM/${i}/
 		mv ${3}/RPGM/${i}/bonnmotion.movements ${3}/RPGM/${i}/bonnmotion.movements_RPGM

	done

	#Concat files
	for i in ${rep}
	do
 
 	cat  ${3}/RPGM/${i}/bonnmotion.movements_RPGM ${3}/RPGM/${i}/bonnmotion.movements_RandomWaypoint > ${3}/RPGM/${i}/bonnmotion.movements

	done
else
	for i in ${rep}
	do
 		mkdir -p ${3}/RandomWaypoint/${i}/
		./bonnmotiongen.sh RandomWaypoint ${RANDOM} ${3}/RandomWaypoint/${i}/

	done

fi

