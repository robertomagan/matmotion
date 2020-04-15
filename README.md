# matmotion

Mobile Ad hoc networks node motion generation tool. It is based on the well-known motion pattern generation [Bonnmotion framework] (https://sys.cs.uos.de/bonnmotion/index.shtml)

## Requirements
**matmotion** has been tested on Matlab R2016b and Linux Unbuntu 18 LTS 64 bits
**bonmotion**: last version of this framework 3.0.1 is used here. Additionally, it is has been compiled with JRE 1.8.0_201. Depending on the platform and the used JRE you should compile again the framework. For that, remove ```bonnmotion-3.0.1``` folder, extract again ```bonnmotion-3.0.1.zip``` file, go inside the recent created folder and execute ```./install``` script.

## How to generate new node motion patterns with bonnmotion?
1. Go to ```setup/motion/``` 
2. Set up a new configuration file for one of the wide variety of motion patterns available (see official documentation on [Bonnmotion framework] (https://sys.cs.uos.de/bonnmotion/index.shtml)). **bonnmotion** framework uses \*.params to configure some parameters depending on the chosen pattern. You can see some examples for ```RandomWaypoint``` and ```RPGM``` movements by inspecting ```bonnmotion_RandomWaypoint.params``` and ```bonnmotion_RPGM.params``` files respectively.
3. Execute ```genmotion.sh``` script as following:
```
$ ./genmotion.sh 1 2 50UN_6AN RandomWaypoint
```
This example generates 2 different RandomWaypoint movement patterns sequence (repetitions) for 56 nodes that are saved on 50UN_6AN folder. Go inside it to see more details.

## Running a simulation with different repetitions
1. Be sure that the previous step has been done before continue.
2. **matmotion.m** engine set up. Next table shows correspondence between params you can foun in ```matmotion.m`` and ``bonnmotion_<movtype>.params```. We have been follow the generated example mentioned before.

| **matmotion.m** | value          | **bonnmotion**   | value        | Description |
|:---------------:|:--------------:|:----------------:|:------------:|:-----------:|
|usernodes        |50              |nn                |56            |# of normal nodes             |  
|agentnodes       |6               |                  |              |# of AP nodes             | 
|un_vmax          |0.1             |minspeed, maxspeed|0.1,0.1       |normal nodes velocity (m/sim_time_step)             |
|orig_AN          |vector          |                  |              |initial/static position of APs             |
|R                |1               |                  |              |Coverage range (m)           |
|xmax             |6.6             |x                 |6.6           |X axis max area (m)           |
|ymax             |5.4             |y                 |5.4           |Y axis max area (m)           |
|sim_time         |600             |duration          |600           |Total number of generate positions           |
|rep_time         |2               |                  |              |Total number of repetitions          |
|type_movement    |'RandomWaypoint'|model             |RandomWaypoint|Motion pattern selected          |

**matmotion.m** header where all the set up params can be found.

```
%% NETWORK ----------------------------------------------------------------
% num of user nodes (UN) it must be 
nusernodes = 50; 

% UN velocity
un_vmax = 0.1; % m/s 
% num of agent nodes (AN) == number of APs
% An agent node is equivalent to a relay node
nagentnodes = 6;

% Initial location of the relays nodes
switch nagentnodes,
    case 0,
        orig_AN = [];%CON RAND HAY QUE PONERLO A VAC�?O
    case 1,
        orig_AN = [0 0];
    case 2,
        orig_AN = [0 0; 1 0];
    case 3,
        orig_AN = [0 0; 1 0; 1 1];
        % TODO: to remove
        %orig_AN = [];
    case 4,
        orig_AN = [0 0; 1 0; 1 1; 0 1];
    case 5,
        orig_AN = [0 0; 1 0; 1 1; 0 1; 2 0];
    case 6,
        orig_AN = [0 0; 1 0; 1 1; 0 1; 2 0; 0 2];

    otherwise,
        disp('Select a correct number of RNs ...'), return;
end

% Coverage range
R = 1;

%% EXPERIMENT SETUP ------------------------------------------------------
% Square area
xmax = 6.6;
ymax = 5.4;

% simulation steps.
sim_time = 600;

% # of repetitions. Each repetition corresponds with a different scenario.
% At the end the optimizationi routine will be called rep_time x sim_time
rep_time = 2;

% Different kinds of movements
type_movement = 'RandomWaypoint';
%type_movement = 'RPGM';
%type_movement = 'MRWP';
%type_movement = 'RAND';
```
**bonnmotion_RandomWaypoint.params** configuration params
```
model=RandomWaypoint
ignore=0.0
randomSeed=12345
x=6.6
y=5.4
duration=600.0
nn=56
circular=false
minspeed=0.1
maxspeed=0.1
maxpause=0.0
```
3. Run **matmotion.m** script from Matlab environment




