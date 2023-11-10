/**
 *  Fisheries
 *  Author: Tri Nguyen-Huu
 *  Description: 
 */

model fisheries

//import "parameters.gaml"

global {
	float sardine_growth_rate <- 0.002;
	
	int nb_boats <- 2;
	int mesh_size <- 1;
	float capture <- 0.0;
	int max_size <- 6;
	float h <- 50.0;
	float flip_growth <- 0.001;
	float climb_smoothness <- 0.01;
	list<float> categories <-list<float>(all_indexes_of([0]+list_with(max_size,1),1));
	list<float> capture_by_size <- list_with(6,0.0);
	float biomass;
	float carrying_capacity <- 500.0;
	
	float margin <- 4.0;

	geometry shape <- polygon([{0,0},{0,100},{100,100},{100,0}]);
	geometry bounds <- polygon([{margin,margin},{margin,100-margin},{100-margin,100-margin},{100-margin,margin}]);

	init {
		create boat;
		create sardine number: 100{
			size <- rnd(float(max_size));
		}
		create aquarium;
	}
	
	reflex stats{
		biomass <- sum((sardine where !dead(each)) collect(each.size));
	}
	
	reflex debug when: false{
		//write "debug";
		write ""+length(sardine)+" sardines (biomass: "+biomass+")";
	}
}


species sardine skills:[moving] parallel: false{
	rgb color <- rnd_color(255);
	float size;
	bool captured <- false;
	bool to_kill <- false;
	float amplitude;
	float scale -> 0.15*size/max_size;
	float heading <- rnd(360.0);
	list<float> fishbones_headings <- list_with(5,heading);
	float align_coeff <- 0.1;
	float h_target;
	float distance_to_climb <- 1.0;
	float v_heading <- 0.0;
	point norm;
	float delay <- rnd(360.0);
	
	init{
		location <- any_location_in(bounds);
		h_target <- 5+rnd(h-10.0);
		location <- {location.x,location.y,h_target};
		size <- 0.2;
	}
	
	reflex fin when: captured{
		do die;
	}
	
	reflex growth{
//		if int(self)=0{
//			write "sardine";
//		}
		size <- size*exp(sardine_growth_rate * (1-size/max_size));
		if (size > 3.2) and flip(flip_growth*(1-biomass/carrying_capacity)){
			create sardine;
		}
	}
	
	reflex natural_death{
	//	if
	}
	
	reflex move{
		do wander speed: 0.03 amplitude: 10.0 bounds: bounds;
		fishbones_headings[0] <- heading;
		loop i from: 1 to: length(fishbones_headings)-1{
			fishbones_headings[i] <- fishbones_headings[i] +align_coeff*(fishbones_headings[i-1]-fishbones_headings[i]);
		}
		if flip(0.001){
			h_target <- 5+rnd(h-10.0);
			distance_to_climb <- 1.0+rnd(10.0);
			v_heading <- -50+rnd(100.0);
		}
		location <- location + {0,0,0.01*speed*tan(v_heading)};
//		if location.z > h-5{
//			location <- {location.x,location.y,h-5};
//		}
//		if location.z < 5{
//			location <- {location.x,location.y,5};
//		}
	}
	
	aspect default{
		if captured{
			draw circle(sqrt(size)+1) color: #green;
		}
		draw circle(sqrt(size)) color: color;
	}
	
	point p(point po){
		return location + (po rotated_by(-v_heading::norm))*scale;
	}
	
	aspect nice{
		norm <- {0,1,0} rotated_by (fishbones_headings[0]::{0,0,1});
		point x1 <- {10,0,0} rotated_by (fishbones_headings[1]::{0,0,1});
		point x0 <- x1 +  ({6,0,0} rotated_by (fishbones_headings[0]::{0,0,1}));
		point x2 <- {-10,0,0} rotated_by (fishbones_headings[2]::{0,0,1});
		point x3 <- x2 + ({-12,0,0} rotated_by (fishbones_headings[3]::{0,0,1}));
		point x4 <- x3 + ({-12,0,0} rotated_by (fishbones_headings[4]::{0,0,1}));
		point xn1 <- {-15,6,4*cos(cycle-delay)} rotated_by (fishbones_headings[2]::{0,0,1});
		point xn2 <- {-15,-6,4*cos(cycle-delay)} rotated_by (fishbones_headings[2]::{0,0,1});
	
	//	draw polyline([p({0,0,0}),p(norm*10)]) color: #red;
		draw polygon([p(x0),p(x1+{0,0,10}),p(x1-{0,0,10})]) color: color;
		draw polygon([p(x1+{0,0,10}),p(x1-{0,0,10}),p({0,0,-12}),p({0,0,12})]) color: color;
		draw polygon([p({0,0,-12}),p({0,0,12}),p(x2+{0,0,8}),p(x2-{0,0,8})]) color: color;
		draw polygon([p(x2+{0,0,8}),p(x2-{0,0,8}),p(x3)]) color: color;
		draw polygon([p(x4+{0,0,8}),p(x4-{0,0,8}),p(x3)]) color: color;
		draw polygon([p({0,0,0}),p(x2),p(xn1)]) color: color;
		draw polygon([p({0,0,0}),p(x2),p(xn2)]) color: color;			
	}
}


species boat{
	
	float radius <- 20.0;
	
	
	reflex fishing{
//		capture <- 0.0;
//		loop times: nb_boats{
//			location <- any_location_in(world.shape);
//			list<sardine> ls <- sardine at_distance(radius);
//			ask ls{
//				if !dead(self){
//					captured <- true;
//				}	
//			}
//			capture <- capture + sum(ls where !dead(each) collect(each.size));
//			loop i from: 1 to: 6{
//				capture_by_size[i-1] <- sum(ls where ((each.size <=i) and (each.size>i-1)) collect (each.size));
//			}
//		}
	}
	
	aspect default{
//		draw world.shape color:rgb(185, 122, 87);// rgb(44, 130, 201);// depth: 50 ;
		
	}
	
		
}

species aquarium{
	aspect default {

		float transp <- 0.4;
		draw world.shape color:rgb(185, 122, 87) depth: -20;// rgb(44, 130, 201);// depth: 50 ;
		draw polygon([{0,0,0},{0,100,0},{0,100,h},{0,0,h}]) color: rgb(44, 130, 201,transp);// depth: 50 ;
		draw polygon([{100,100,0},{0,100,0},{0,100,h},{100,100,h}]) color: rgb(44, 130, 201,transp);// depth: 50 ;
		draw polygon([{100,100,0},{100,0,0},{100,0,h},{100,100,h}]) color: rgb(44, 130, 201,transp);// depth: 50 ;
		draw polygon([{0,0,0},{100,0,0},{100,0,h},{0,0,h}]) color: rgb(44, 130, 201,transp);// depth: 50 ;
		draw polygon([{0,0,h},{100,0,h},{100,100,h},{0,100,h}]) color: rgb(44, 130, 201,transp);// depth: 50 ;
	}
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
//			
//			overlay position: { world.shape.width*0.4, world.shape.height*1.05} size: {overlay_rel_width,overlay_rel_height} background: rgb(44,62,80) transparency: 0.2 border: #black rounded: true
//            {
//            	float overlay_width <- world.shape.width*overlay_rel_width;
//    			float overlay_height <- world.shape.height*overlay_rel_height;
//            	if cycle = 0{
//            		if game_name = "Enter your name"{
//            			draw "Enter your name\n(on left panel)" anchor: #center at: {overlay_width/2,overlay_height/3} color: #white font: font("SansSerif", 2*my_font_size, #bold);
//            		}else{
//            			draw "Welcome "+game_name anchor: #center at: {overlay_width/2,overlay_height*0.3} color: #white font: font("SansSerif", 1.5*my_font_size, #bold);
//            			draw "Your objective: "+objective anchor: #center at: {overlay_width/2,overlay_height*0.7} color: #white font: font("SansSerif", 1.5*my_font_size, #bold);
//            		}
//           		}else{
//            		draw "Capture: "+compute_score(total_capture)+"Tons (income: "+trunc(price*capture,1)+" per day)" 
//            			at: {0.05*overlay_width,0.2*overlay_height} anchor: #left_center color: objective="Maximize capture"?score_color:#white font: font("SansSerif", my_font_size, #bold);
//	            	draw "Capital: "+compute_score(capital)+"\u01e4" at: {0.05*overlay_width,0.5*overlay_height} anchor: #left_center color: objective="Maximize capture"?#white:score_color font: font("SansSerif", my_font_size, #bold);
//	            	draw "Ships: "+nb_trawlers+" (cost: "+fleet_maintenance_cost+" \u01e4 per day)" 
//	            		at: {0.05*overlay_width,0.8*overlay_height} anchor: #left_center color: cycle<end_date-no_buy_duration?#white:rgb(30,30,30) font: font("SansSerif", my_font_size, #bold); 		
//            	}
//            }		
//		}
//		display  Capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
//			chart name: 'Daily capture' type: series x_serie: xaxis background: rgb(47,47,47) color: #white title_font:"SansSerif" {
//				data legend: 'Capture' value: capture_chart style: area color: rgb(capture_color,0.7) thickness: 2 marker: false;
//			}
//		}
//		display  "Fishery results" refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
//			chart name: 'Net profit, fleet size' type: series x_serie: xaxis background: rgb(47,47,47) color: #white title_font:"SansSerif" {
//				data legend: 'Net profit' value: net_profit_chart style: area fill: true color: rgb(profit_color,0.7) thickness: 2 marker: false;
//				data legend: 'Ships' value: trawler_chart style: line color: trawler_color line_visible: false
//						 marker: true marker_size: 0.1;
//			}
//		}		
	}
}

