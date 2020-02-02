#!/bin/bash
clear

if [ $# -lt 8 ]
then
	echo "Use: ./runexperiments.sh <experiment_type> <movement type> <local IP> <optitrack IP> <shiftx> <shifty> <mobile> "movementfilepath""
	#echo "<experiment_type> available values: real or simulated"
	echo "<movement type> available values: RandomWaypoint or RPGM"
	#echo "<local IP>: Local IP for the tracker inferface"
	#echo "<optitrack IP>: IP of the optitrack engine"
	echo "<shiftx>: X shift added to (0,0) point in bonnmotion movements"
	echo "<shifty>: Y shift added to (0,0) point in bonnmotion movements"
	echo "<mobile> available values: static or dynamic "
	echo "<#UNs> # of user nodes"
	echo "<#ANs> # of agent nodes"
	echo "<experiment  ID> experiment ID"
	echo "<experiment duration> experiment duration"
	echo "movementfilepath: path of the bonnmotion file previosly generated. With no value a bonnmotion movement file is automatically generated"
	
	exit 1
fi

exptype='simulated'
movtype=$1
#localIP=$3
#serverIP=$4
shiftx=$2
shifty=$3
mobile=$4
uns=$5
ans=$6
expID=$7
expDuration=$8

die(){
  echo "Killing python processes ..."
  #kill -9 ${waypointPID}
  killall python

  #echo "Killing tracker interface ..."
  #kill -9 ${pidTrackerInterface}

  echo "Killing imotion logger ..."
  kill -9 ${pidImotionlogger}

  echo "Killing argos ..."
  kill -9 $(pgrep argos)

  echo "Killing MARS engine ..."
  kill -9 ${pidMarsengine}

  #echo "Modifiyng tracker interface logs ..."
  #head -n 500 < trackerinterface_${timestamp}.log > tracker_${timestamp}.log 

}


trap 'die' SIGINT

echo "EXPERIMENT TYPE: ${exptype}"

timestamp=$(date +"%d%m%Y_%H%M")
basedir=/home/roberto/RMAGAN/Dropbox/THESIS/ESTANCIA/experiments_test/
argosdir=/home/roberto/RMAGAN/Dropbox/THESIS/ESTANCIA/C++/workspace/idsiaprojectARGoS/


rm README_*
echo "experiment type: ${exptype}" >> README_${timestamp}.txt
echo "movement pattern: ${movtype}" >> README_${timestamp}.txt
echo "type of experiment mobile: ${mobile}" >> README_${timestamp}.txt
echo "shiftyng X to : ${shiftx}" >> README_${timestamp}.txt
echo "shiftyng Y to : ${shifty}" >> README_${timestamp}.txt

if [ ${exptype} == 'real' ] || [ ${exptype} == 'simulated' ]
then
	echo "Running ${exptype} experiment. "
else
	echo "You must select a valid type of experiment: real or simulated ..."
	exit 1
fi

if [ $movtype == 'RandomWaypoint' ] || [ $movtype == 'RPGM' ]
then
        echo "Movement type ${movtype} ..."
else
        echo "You must select a valid type of bonnmotion movement: RandomWaypoint or RPGM ..."
        exit 1
fi

if [ $mobile == 'dynamic' ] || [ $mobile == 'static' ]
then
        echo "Mobile type ${mobile} ..."
else
        echo "You must select a valid type of bonnmotion movement: RandomWaypoint or RPGM ..."
        exit 1
fi

expdir=${basedir}${exptype}/${mobile}/${uns}UN/${movtype}/${uns}UN_${ans}AN/${expID}_${timestamp}

if [ ! -d ${expdir} ]
then
	echo "Creating $expdir ..."
	mkdir -p ${expdir}
fi


#copy scenario_real.xml or scenarion_simulated.xml to expdir
cp ${basedir}setup/motion/scenario_${exptype}.xml ${expdir}

currentdir=$(pwd)

if [ $# -eq 9 ]
then
	# We will use a previously generated movements file
        movementsfilepath=$9
	cp ${movementsfilepath}/bonnmotion.movements ${expdir}
	cp ${movementsfilepath}/bonnmotion.params ${expdir}

	echo "bonnmotion file path: ${movementsfilepath}" >> README_${timestamp}.txt

else
	#run and generate the movements
	echo "Running bonnmotion for ${movtype} ..."
	cd ${basedir}setup/motion/
	./bonnmotiongen.sh ${movtype} ${RANDOM} ${expdir}/ 2>&1 | tee -a ${expdir}/bonnmotion_${timestamp}.log
	cd $currentdir
	echo " "
fi

if [ ${exptype} == 'real' ];then
	#run trackerinterface
	echo "Running trackerinterface ..."
	cd ${basedir}setup/
	./trackerinterface -l ${localIP} -s ${serverIP} > ${expdir}/trackerinterface_${timestamp}.log 2>&1 &
        pidTrackerInterface=$!
	echo "PID Tracker interface: $!"
	cd $currentdir
	
	echo "tracker interface local IP: ${localIP}" >> README_${timestamp}.txt
	echo "tracker interface server IP: ${serverIP}" >> README_${timestamp}.txt
else

	#run ARGoS
        echo "Running ARGoS"
        cd ${argosdir}
        launch_argos -nc xml/${uns}UN_${ans}AN.xml > ${expdir}/argos_${timestamp}.log 2>&1 &
        pidARGoS=$!
        echo "PID ARGoS: $!"
        cd $currentdir

        echo "ARGoS scenario: ${uns}UN_${ans}AN.xml" >> README_${timestamp}.txt

fi

#run INIT motion controller
echo "Running INIT motion controller for ${movtype} ..."
cd ${basedir}setup/
./waypoint_scenario_bm_INIT.py motion/scenario_${exptype}.xml ${expdir}/bonnmotion.movements ${shiftx} ${shifty} 2>&1 | tee -a ${expdir}/motioncontroller_INIT_${timestamp}.log &
cd $currentdir
echo " "

echo "WARNING: nodes are moving to their initial positions. Push [ENTER] when ready!"
# Temptative time for waiting while the UNs are reaching their initial positions
#sleep 90

# run MARS engine
echo "Running MARS engine  ..."

anIDsinit=200
ansIDs=$(seq $((${anIDsinit} + 1)) 1 $((${anIDsinit} + ${ans})))

unIDsinit=0
unsIDs=$(seq $((${unIDsinit} + 1)) 1 $((${unIDsinit} + ${uns})))

cd ${basedir}setup/
echo "./marsengine TRACK TARGET 4 0 0 ${ans} ${ansIDs} ${unsIDs}"
./marsengine TRACK TARGET 4 0 0 ${ans} ${ansIDs} ${unsIDs} > ${expdir}/marsengine_${timestamp}.log 2>&1 &
pidMarsengine=$!
cd $currentdir
echo " "

if [ ${mobile} == 'dynamic' ];then
	#run motion controller
	echo "Running motion controller for ${movtype} ..."
	cd ${basedir}setup/
	./waypoint_scenario_bm.py motion/scenario_${exptype}.xml ${expdir}/bonnmotion.movements ${shiftx} ${shifty} 2>&1 | tee -a ${expdir}/motioncontroller_${timestamp}.log & 
	cd $currentdir
	echo " "
fi

#run logger
echo "Running imotion logger  ..."
cd ${basedir}setup/
./imotionlogger 0 ${expdir}/ TRACK TARGET > /dev/null &
pidImotionlogger=$!
cd $currentdir
echo " "

echo "[CTRL + C to finish]"

waypointPID=$(pgrep python)

# Wait for the experiment time
echo "Experiment duration: ${expDuration} (s)" >> README_${timestamp}.txt
echo "WAITING FOR ${expDuration} seconds .."
count=1
while [ ${count} -le ${expDuration} ]
do
        echo -ne "TIME-> ${count} s.\r"
        sleep 1
        count=$((count + 1))
done

echo "Experiment elapsed time: ${count} (s)" >> README_${timestamp}.txt

#Copy README to the experiment directory
cp README_${timestamp}.txt ${expdir}

die








