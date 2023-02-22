#### SET #####

set VERTEX ordered;
set EDGE within VERTEX cross VERTEX;
set AGENT ordered;

### PARAMETER ###

param Source{AGENT} symbolic in VERTEX;
param Destination{n in AGENT} symbolic in VERTEX, != Source[n];
param k := card(VERTEX);
param M := k + 1;

### VARIABLE ###

var used {EDGE, AGENT} binary; #edge (i,j) is used by agent a
var flow{VERTEX, AGENT} binary; #vertex i is used by agent a
var in_time{VERTEX, AGENT} >= 0, integer; #timestemp in which agent a enters vertex i
var out_time {VERTEX, AGENT} >= 0, integer; #timestemp in which agent a leaves vertex i
var different_nodes{VERTEX, AGENT, AGENT} binary;
var different_edges {EDGE, AGENT, AGENT} binary;
var different_in_time{VERTEX, VERTEX, AGENT} binary;
var different_out_time{VERTEX, VERTEX, AGENT} binary;

###Agent occupies its origin and destination
subject to source_constraint_1{a in AGENT}:
    flow[Source[a], a] = 1;
    
subject to destination_constraint_1{a in AGENT}:
    flow[Destination[a], a] = 1;

### The agent must leave its origin ###
subject to source_constraint_2{i in VERTEX, a in AGENT: (i,Source[a]) in EDGE}:
    used[i, Source[a], a] = 0;

### The agent must arrive in its destination ###
subject to destination_constraint_2{i in VERTEX, a in AGENT: (Destination[a], i) in EDGE}:
    used[Destination[a], i, a] = 0;


### If an agent goes trough some vertex then he must enter and leaves it (both exactly once). ###
subject to enter_vertex_contraint{i in VERTEX, a in AGENT: i != Source[a]}: 
    sum{j in VERTEX: (j,i) in EDGE}used[j, i, a] = flow[i, a];

subject to leave_vertex_constraint{i in VERTEX, a in AGENT: i != Destination[a]}: 
    sum{j in VERTEX: (i,j) in EDGE}used[i, j, a] = flow[i, a];

subject to source_in_time{a in AGENT}:
    in_time[Source[a],a] = 1;

### If agent goes through edge (i,j) then out_time from vertex i is equal to in_time (in the same vertex) + 1. ###
### The time step in which the agent goes trough the edge (i,j) is equal to in_time in vertex j. ###
subject to out_time_constraint{i in VERTEX, a in AGENT}:
    out_time[i, a] = in_time[i, a] + flow[i,a];

subject to edge_time_constraint_1{j in VERTEX, i in VERTEX, a in AGENT: (i, j) in EDGE}:
    in_time[j,a] <= used[i,j,a]*(out_time[i, a]) + M*(1 - used[i, j, a]);

subject to edge_time_constraint_2{j in VERTEX, i in VERTEX, a in AGENT: (i, j) in EDGE}:
    in_time[j,a] >= used[i,j,a]*(out_time[i, a]);


### Two AGENT cannot enter the same node at the same time.###
subject to vertex_collision_1{i in VERTEX, a1 in AGENT, a2 in AGENT: a1 < a2}:
    flow[i, a1] * in_time[i, a1] <= flow[i, a2] * (in_time[i, a2] - 1 + M*different_nodes[i, a1, a2]) + (1 - flow[i, a2])*M;

subject to vertex_collision_2{i in VERTEX, a1 in AGENT, a2 in AGENT: a1 < a2}:
    flow[i, a1] * in_time[i, a1] >= flow[i, a2] * (in_time[i, a2] + 1 - M*(1 - different_nodes[i, a1, a2]));


### Takes into consideration if an edge is used in the opposite direction by both AGENT and compares the output times to make sure they do not use it in the opposite direction at the same time
### The out time of two ends of an edge must be different for any pair of AGENT that use the edge in the opposite direction.
subject to edge_collision_1{i in VERTEX, j in VERTEX, a1 in AGENT, a2 in AGENT: a1 < a2 and (i, j) in EDGE}:
    used[j, i, a1] * out_time[j, a1] <= used[i, j, a2] * (out_time[i, a2] - 1 + M*different_edges[i, j, a1, a2]) + (1 - used[i, j, a2])*M;

subject to edge_collision_2{i in VERTEX, j in VERTEX, a1 in AGENT, a2 in AGENT: a1 < a2 and (i, j) in EDGE}:
    used[j, i, a1] * out_time[j, a1] >= used[i, j, a2] * (out_time[i, a2] + 1 - M*(1 - different_edges[i, j, a1, a2]));


### An agent cannot leave two different nodes at the same time. ###
subject to no_multiple_out_time1{i in VERTEX, j in VERTEX, a in AGENT: i != j}:
    out_time[j, a] <= out_time[i, a] - 1 + M*different_out_time[i, j, a];

subject to no_multiple_out_time2{i in VERTEX, j in VERTEX, a in AGENT: i != j}:
    out_time[j, a] >= out_time[i, a] + 1 - M*(1 - different_out_time[i, j, a]);


### An agent cannot enter multiple nodes at the same timestamp. ###
subject to no_multiple_in_time_1{i in VERTEX, j in VERTEX, a in AGENT: i != j}:
    in_time[j, a] <= in_time[i, a] - 1 + M*different_in_time[i, j, a];

subject to no_multiple_in_time_2{i in VERTEX, j in VERTEX, a in AGENT: i != j}:
    in_time[j, a] >= in_time[i, a] + 1 - M*(1 - different_in_time[i, j, a]);

###Obiettivo###
minimize cammino: (sum{(i,j) in EDGE, n in AGENT}used[i,j,n]);
