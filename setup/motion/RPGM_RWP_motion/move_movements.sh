#!/bin/bash

init_rep=${1}
fin_rep=${2}

reps=$(seq ${1} 1 ${2})

for rep in ${reps}
do
	cp ${3}bonnmotion.movements_${rep} ${4}${rep}
	mv ${4}${rep}/bonnmotion.movements_${rep} ${4}${rep}/bonnmotion.movements
done
