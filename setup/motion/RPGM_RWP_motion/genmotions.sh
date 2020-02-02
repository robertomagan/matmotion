#!/bin/bash

rep=${1}

COUNTER=1
         while [  $COUNTER -le ${1} ]; do
             echo ESCENARIO -> $COUNTER

	     ./bonnmotiongen.sh ${2} ${RANDOM} ${3}
	     
	     mv ${3}/bonnmotion.movements ${3}/bonnmotion.movements_${COUNTER}	

             let COUNTER=COUNTER+1 
         done
