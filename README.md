# Operations Research: Shortest Path for Multiple Agents
### Project Task
Let be given an undirected graph with arcs all having travel time equal to 1. N agents move on this graph. Each agent i has a source node oi and a destination node di. Define a mathematical model to minimize the sum of the shortest paths of all agents, taking into account that the agents cannot be on the same node or along the same arc at the same time. The mathematical model has to be formulated in AMPL and provided together with data of a particular instance to solve it. 

### Used approach
The approach used is based on the use of binary and integer variables. Those of the first type are used to keep track of the route taken by a certain agent (these are set to 1 for each node 'v' and each arc 'e' that the agent uses to reach its destination). 

Variables with integer values, on the other hand, are used for collision management. Each indicates the instant of time in which the agent 'a' enters and exits a certain node 'v'. It is assumed that each agent 'a' moves at every instant of time (it cannot stop and wait on a node) and that once the agent reaches its destination it exits the graph, therefore equal destinations are admitted for different agents, (as long as they enter the node at different times). 

The goal of the problem is to minimize the sum of the shortest paths. It means to search, for each agent, the shortest path from the source to the destination, avoiding collisions with the other agents.

### Alternative approach
A second possible approach could be to use binary variables only. A set of nodes, a set of arcs and a set of time instants are defined, so the variable indicates whether the agent 'a' occupies node 'v' at time 't'. The difficulty in implementing this approach lies in the simultaneous management of the 3 dimensions.
