
close all;
clc;
clear;

%% NETWORK ----------------------------------------------------------------
% num of user nodes (UN)
nusernodes = 50;

% UN velocity
un_vmax = 0.1;% m/s -> metros recorridos en cada time step
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
        orig_AN = [2.5 2.5; 2 2; 3 3; 1 1; 4 4; 3.5 3.5];

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
sim_time = 300;

% # of repetitions. Each repetition corresponds with a different scenario.
% At the end the optimizationi routine will be called rep_time x sim_time
rep_time = 2;

%% Network node motion setup --------------------------------------------
% Path of movement generated files
base_path_movements = ['.' filesep 'setup' filesep 'motion' filesep];

% Different kinds of movements
type_movement = 'RandomWaypoint';
%type_movement = 'RPGM';
%type_movement = 'MRWP';
%type_movement = 'RAND';
path_movements = [base_path_movements num2str(nusernodes) 'UN_' num2str(nagentnodes) 'AN' filesep type_movement filesep];

% debug flag:
% 0 -> Disable figures
% 1 -> Enable figures
global debug;
debug = 1;

% Simulation of static scenarions
% 0 -> disabled
% 1 -> enabled
global stop_motion;
stop_motion = 0;
% Simulation time to depicting purposes
global sim_time_progress;
sim_time_progress = 1;

% Type of experiment
% NONE -> without RNs
% DRNS -> RNs DRNS
% RAND -> RN RANDOM
experiment_type = 'DRNS';


%PATH to save the results
%base_path_results = pwd; %only for linux
root_path_results = '.'
%experiment path results
experiment_path_results = 'test_elena'
%Create automatic results dir
path = [root_path_results  filesep experiment_path_results filesep num2str(nusernodes) 'UN' filesep num2str(nusernodes) 'UN_' num2str(nagentnodes) 'RN_' experiment_type filesep type_movement filesep];

% Simlation parameters display
disp(['SIMULATION R = ' num2str(R) ', UN = ' num2str(nusernodes) ', AP = ' num2str(nagentnodes)])

% Time elapsed
init_time = tic;

% Total nodes including malicious nodes and agent nodes.
totalnodes = nusernodes + nagentnodes;

% To see all the locations of ANs and UNs at each time step and repetition
node_locations = cell(sim_time - 1,3,rep_time);

s1 = RandStream('mt19937ar','seed',6);
s = RandStream('mt19937ar','seed',5);
    
    % Loop for several repetitions of different setups
    for rep=1:rep_time,
        RandStream.setGlobalStream(s);
        
        % ------ INITIALIZATION ------
        % Set number of user nodes IDs for each repetition
        user_nodes_ids = 1:nusernodes;
        
        % Elapsed time for every repetition
        init_rep_time = tic;
        
        % All node positions
        vit_all = [];
        
        % Initialization of the movements of the user nodes during the
        % overall simulation time               
        
        if (strcmp(type_movement,'MRWP')) % 
            % Weight factor for the current motion direction
            alfa = 0.95;
            % Probability of a direction change
            p = 0.1;
            % vmin, min velocity that user node can reach.
            vmin = 0.02;
            % vmax, max velocity that user node can reach.
            %vmax = 0.0005;
            % Minimun distante to reach the destination. When the distance between
            % the node and destination is lower or equal than this the node is stopped.
            D_final = 0.05;
            
            [orig_NU, dest_NU] = init_NU(xmax,ymax,nusernodes);
            
            vit_all = mod_rwp_motion( nusernodes, vmin, un_vmax, alfa, p, orig_NU, dest_NU, D_final, sim_time);
        else
            % bonnmotion.movements previously generated for RPGM or
            % RandomWaypoint
            mov_file = [path_movements num2str(rep)  filesep 'bonnmotion.movements'];
            
            if(strcmp(experiment_type,'RAND'))
                vit_all = rpgm_movements(nusernodes + nagentnodes,mov_file,sim_time, un_vmax);
            else
                vit_all = rpgm_movements(nusernodes,mov_file,sim_time, un_vmax);
            end
        end
        
        % Initialization of whole network
        orig_NU = vit_all(:,1:2); % Get the initial positions of the UN
        N_init = [orig_NU;orig_AN]; % Build the whole network initial positions
                
        % Form MANET topology G(to)
        network = makenetwork(N_init,R);
        network = network + network';
        
        if debug
            h = plot_G_2(network, N_init, orig_NU,1:nusernodes, [],[],[],[],...
                ['G init - R = ' num2str(R) ' UN = ' num2str(nusernodes) ' AN = ' num2str(nagentnodes) ],1,0,0,0,1,R);
        end
        
        
        
               
        %% ------  CORE SYSTEM OPTIMIZATION ---
        
        RandStream.setGlobalStream(s1);
        
        % Simulation time steps
        for t=1:sim_time - 1,
            
            % Elapsed time of each simulation
            init_sim_time = tic;
                        
            % For depicting purposes.
            sim_time_progress = t;            
            
                    if(stop_motion)
                        %Stop motion
                        vi_t1 = orig_NU;
                    else
                        % Read the UN positions at t + 1
                        vi_t1 = vit_all(:,2*t + 1:2*t + 2);
                    end
                    
                    % Create G(t+1)
                    N_1 = [vi_t1; orig_AN];
                    
                    network_1 = makenetwork(N_1,R);
                    network_1 = network_1 + network_1';
                    
                    %Save locations of all nodes
                    node_locations(t,1,rep) = {network_1};
                    node_locations(t,2,rep) = {N_1};
                    node_locations(t,3,rep) = {vi_t1};

                    % Plotting Network
                    if debug
                        plot_G_2(network_1, N_1,vi_t1,1:nusernodes,[],[], [], [], ...
                            ['G - R = ' num2str(R) ' UN = ' num2str(nusernodes) ' AN = ' num2str(nagentnodes) ],1,0,1,1,1,R,h);
                        %close all;
                    end
                
            disp(['REP -> ' num2str(rep) ', t. sim. -> ' num2str(t) ', duration -> ' num2str(toc(init_sim_time)) ' (s)']);
            
            % For depicting purposes
            pause(0.5)
            
        end
        
        % Finish time
        finish_rep_time = toc(init_rep_time);
        disp(['REP #' num2str(rep) ' -> duration: ' num2str(finish_rep_time) ' (s).'])
        
        
        
        %%% breakpoint
    end

% Creates the path to save the results
mkdir(path); 

nombre4 = [path 'node_locations_RN_' num2str(nagentnodes) '_UN_' num2str(nusernodes)  '_' datestr(now, 'ddmmyyyyHHMM') '.mat'];


save(nombre4,'node_locations');

% Finish time
finish_time = toc(init_time);
disp(['TOTAL ELAPSEP TIME: ' num2str(finish_time) ' (s).'])

