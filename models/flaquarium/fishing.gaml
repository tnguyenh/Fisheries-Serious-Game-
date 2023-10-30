/**
* Name: fishing
* Based on the internal empty template. 
* Author: Tri
* Tags: 
*/


model fishing

/* Insert your model definition here */

import "flaquarium.gaml"

global{
	
}

species net{
	
}

experiment flaquarium type: gui  {
	parameter name: 'Number of boats' var: nb_boats init: 1 min:0 max: 100;
	parameter name: 'Net mesh size' var: mesh_size init: 1 min: 1 max: 6;

	output  {
//		layout horizontal([0::140,vertical([1::100,2::100])::100]) tabs: true;
		display 'Sea' type: opengl background: rgb(47,47,47)  toolbar: false
		 refresh: every(1#cycle){
			camera 'default' location: {119.998,155.6332,61.027} target: {48.7163,45.869,0.0};
			species boat;
			species sardine aspect: nice;// aspect: nice;
			species aquarium;			
		}
}
		}