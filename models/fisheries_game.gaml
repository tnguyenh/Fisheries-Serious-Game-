/**
 *  Fisheries
 *  Author: Tri Nguyen-Huu
 *  Description: 
 */

model fisheries

import "import/main_model_v2.gaml"

global{
	string output_path <- "../output/";
	file shape_file_provinces <- file('../includes/maroc_2012.shp');
	int end_date <- 10000;
	bool is_benchmark <- false;
	string vision <- "sonar";
}

//global {
//	int nb_seiners <- 0;// parameter: 'Nombre de Seiners:' category: 'Vessels';
//	int nb_trawlers <- 5;// parameter: 'Nombre de Trawlers:' category: 'Vessels';
//	int nb_sardine <- 100;// parameter: 'Densite de Sardine:' category: 'Fish';
//	float price <- 1.0;
//	int end_date <- 10000;
//	int no_buy_duration <- 3000;
//	int my_font_size <- 18;
//	bool is_benchmark <- false;
//	
//	string output_file;
//	string output_path <- "../output/";
//	string game_name <- "Enter your name";
//	string objective <- "Maximize capture" among: ["Maximize capture","Maximize capital"];
//	
//	string vision <- "sonar"; 
//	bool show_trails <- false; 	
//	bool pov <- true;
//	bool variable_price <- false;
//	int trail_length <- 10;
//	int sliding_window <- 500;
//	int profit_sliding_window <- 500;
//	font my_font <- font("Helvetica", 16 , #plain);
//	file shape_file_provinces <- file('../includes/maroc_2012.shp');
//	
//	string color_palette_name <- "OrRd";//"OrRd";//"RdBu";
//	list<rgb> palette <- brewer_colors (color_palette_name);
//	rgb sea_color <- rgb(44, 130, 201,0.95);
//	rgb shallow_color <- rgb(44, 130, 201,0.85);
//	rgb fish_stock_color <-  rgb(97,205,114);
//	rgb capture_color <- rgb(52,152,219);
//	rgb profit_color <- rgb(243,157,49);
//	rgb maintenance_color <- rgb(102,57,43);
//	rgb score_color <- rgb(241,196,48);
//	rgb sardine_color <- rgb(30, 81, 123);
//	rgb trail_color <- #grey;
//	rgb trawler_color <- rgb(149,165,166);
//	int nb_last_positions <- 100;
//	float capture <- 0.0;
//	list<float> capture_movmean <-[];
//	list<float> net_profit_movmean <-[];
//	float total_capture <- 0.0;
//	float income <-0.0;
//	float fish_stock;
//	float radius <- 0.6;
//	float capital <- 100.0;
//	float fleet_maintenance_cost <- 0.0;
//	float net_profit <- 0.0;
//
//	list<provinces> sea_provinces <- [];
//	list<float> capture_history;
//	list<float> net_profit_history;
//	list<float> trawler_history;
//	list<float> capture_chart;
//	list<float> net_profit_chart;
//	list<float> trawler_chart;
//	list<int> xaxis;
//	float dtime;
//	
//	string output_string <- "nb_trawlers,fish_stock,capture,income,price,fleet_maintenance_cost,capital,net_profit\n";
//		
//	
//	geometry shallow_waters;
//	geometry sea; // some grid cells have been removed to avoid some fish being stuck
//	geometry sea_for_boat_access; // same than before, but the cells that have been removed and which contain ports are put back
//		
//	geometry shape <- envelope(shape_file_provinces);
//
//	init {
//		
////		xaxis <- [];
////		loop i from: 0 to: 500-1{
////			xaxis << i;
////		}
//
//		output_file <- get_output_file();
//		
//		int current_color <-3 ;
//		create species: provinces from: shape_file_provinces  {
//			if (name = 'provinces7'){
//				type <- 'sea';
//				color <- sea_color;
//			}else{
//				type <- 'land';
//				color <- palette[current_color];
//				current_color <- current_color + 1;
//			}
//		}
//		
//		sea_provinces <- provinces where (each.type = 'sea');
//		
//		ask provinces{
//			if  distance_to(self,  union(sea_provinces)) < 0.01 and type != 'sea'{
//				type <- 'coast';
//			}
//		}
//		
//		shallow_waters <- inter(1.2 around(provinces where (each.type = 'coast')), union(sea_provinces));
//		
//		ask sea_provinces{
//			create provinces{
//				shape <- inter(myself.shape,shallow_waters);
//				type <- 'shallow waters';
//				name <- myself.name+'_shallow';
//				color <- shallow_color;
//			}
//			shape <- shape - shallow_waters;
//		}
//		
//		sea_provinces <- provinces where (each.type = 'sea' or each.type = 'shallow waters');
//
//		sea <- union(sea_provinces collect(each.shape));
//		sea_for_boat_access <- sea - cell grid_at {6,0}- cell grid_at {3,7}- cell grid_at {0,9}
//					- cell grid_at {1,9} - cell grid_at {4,3};
//		sea <- sea - cell grid_at {6,0}- cell grid_at {3,6}- cell grid_at {3,7}- cell grid_at {0,9}
//					- cell grid_at {1,9} - cell grid_at {4,3}- cell grid_at {3,5} - cell grid_at {0,8}
//					- cell grid_at {1,8} - cell grid_at {2,8}; // removing smallest grid cells, where fish can be stuck
//		
//		
//		
//		create port {
//			location <- {5.8,2.4};
//			name <- "casa";
//		}
//
//		create port {
//			location <- {3.92,5.6};
//			name <- "agadir";
//		}
//		
//		create port {
//			location <- {3.8,4.5};
//			name <- "safi";
//		}
//					
//		create seiner number: nb_seiners;
//		create trawler number: nb_trawlers;
//		
//		create sardine number: 200 {//80
//			location <- any_location_in(sea);
//			stock <- rnd(100.0);//50
//		}
//
//		ask cell{
//			if self.shape - sea != nil{
//				border <- true;
//			}
//			if inter(self.shape, sea) != nil{
//				at_sea <- true;
//			}
//		}
//		
//
//		create sonar;
//		create legend;
//	}
//	
//	reflex save_data when: cycle < end_date{
//		output_string <- output_string + ""+nb_trawlers+","+fish_stock+","+capture+","+income+","
//				+price+","+fleet_maintenance_cost+","+capital+","+net_profit+"\n";
//	}
//	
//	reflex endSim when: (cycle=end_date) {
//		write "End of the simulation. Results:";
//		save output_string format: txt rewrite: true to: output_file;
//		write "Total capture: "+trunc(total_capture,2)+" Tons of sardines.";
//		write "Capital: "+trunc(capital,2)+" \u01e4.";
//		do pause;
//	}
//	
//	
//	reflex benchmark when: mod(cycle,1000)=0 and is_benchmark{
//		float new_d <- machine_time;
//		if cycle > 0{
//			write new_d - dtime;
//		}
//		dtime <- new_d;
//	}
//
//	reflex update{
//		capture <- sum((trawler+seiner) collect(each.capture));
//		fish_stock <- sum(sardine collect(each.stock));
//		capture_movmean <- last(sliding_window,	capture_movmean+capture);
//		total_capture <- total_capture + capture;
//		income <- sum((trawler+seiner) collect(each.sales_income));
//		fleet_maintenance_cost <- sum((trawler+seiner) collect(each.maintenance_cost));
//		net_profit <- income - fleet_maintenance_cost;
//		net_profit_movmean <- last(profit_sliding_window,	net_profit_movmean+net_profit);
//		capital <- capital + net_profit;
//		
//		capture_history << mean(capture_movmean);
//		net_profit_history << mean(net_profit_movmean);
//		trawler_history << nb_trawlers;
//		
//		int npoints <- 256;
//		int nvals <- length(capture_history);
//		int j;
//		
//		xaxis <- xaxis + (last(xaxis)+1);
//		xaxis <- last(length(xaxis)-1,xaxis);
//		
//		xaxis <- [];
//		capture_chart <- [];
//		net_profit_chart <- [];
//		trawler_chart <- [];
//		loop i from: 0 to: npoints-1 step: 1{
//			j <- round(i*(nvals-1)/npoints);
//			capture_chart << capture_history[j];
//			net_profit_chart<< net_profit_history[j];
//			trawler_chart << trawler_history[j];
//			xaxis << j;
//		}
//		
//		//capture <- 0.0;	
//		if length(trawler) < nb_trawlers{
//			create trawler;
//		}
//		if length(trawler) > nb_trawlers{
//			ask one_of(trawler) {do die;}
//		}
//	}
//	
//	string get_output_file{
//		file dir;
//		if !folder_exists(output_path){
//			dir <- new_folder(output_path);
//		}else{
//			dir <- folder(output_path);
//		}
//		if output_path = '../output/refs/'{
//			return output_path+"ref_"+(nb_trawlers<10?"0":"")+nb_trawlers+"_trawlers_"+rnd(100000000)+".csv";
//		}else{
//			string nm <- (game_name="Enter your name" or game_name="")?"Anonymous":game_name;
//			string obj <- objective = "Maximize capture"?"c":"p";
//			return output_path+"ouput_"+nm+"_"+obj+"-"+replace_regex(string(#now),'[-: ]','')+rnd(100000000)+".csv";	
//		}
//	}
//	
//	string compute_score(float a){
//		//int sign <- a<0?-1:1;
//		//float b <- abs(a);
//		if abs(a) < 10^3{
//			return string(round(a))+" ";
//		}else if abs(a) < 10^6{
//			return string(round(a/100)/10)+" K";
//		}else if abs(a) < 10^9{
//			return string(round(a/10^5)/10)+" M";
//		}else if abs(a) < 10^12{
//			return string(round(a/10^8)/10)+" B";
//		}
//	}
//	
//	string trunc(float a, int s){
//		return string(round(a*10^s)/10^s);
//	}
//	
//	float demand(float p){
//		float A <- 100.0;
//		float d <- 10.0;
//		return A-d*p;
//	}
//	
////	reflex stop_simulation when: time = 1000 {
////		do action: halt ;
////	}	
//		
//}
//
//
//grid cell width: 10 height: 10 neighbors: 8 parallel: true{
//	float carrying_capacity <- 200.0;//50.0;
//	float smoothed_population <- 0.0;
//	float population; 
//	bool border <- false;
//	bool at_sea <- false;
//	rgb color <- rgb(255,255,255,1);
//	
//	reflex reinit_color when: vision != "heatmap" and at_sea{
//		color <- rgb(255,255,255,1);
//	}
//	
//	reflex count_population{
//		population <- sum((sardine overlapping self) collect each.stock);
//	}
//	
//	reflex count_population_heatmap when: vision = "heatmap" and !border and at_sea{
//		smoothed_population <- (population + sum(self.neighbors collect each.population))/(1+length(self.neighbors));
//		int index <- int(255*min(1.0,(3*smoothed_population/carrying_capacity)^0.6));
//		color <-  rgb(255-index, 255-index, 255);
//	}
//}
//
//
//species provinces {
//	string  type ;
//	rgb color <-#blue; 
//	
//	aspect base {
//		draw shape  color: color ;
//	}
//}
//
//species port{
//	float r <- 0.1;
//	
//	aspect default {
//		draw circle(r) color: #white at: location;
//	//	draw sea_for_boat_access color: rgb(#green,0.15);
//	}
//}
//	
//species sardine skills: [moving] parallel: true{
//	//rgb color <- rgb(30, 81, 123,0.05);
//	rgb color <- sardine_color;
//	float stock <- 50.0;
//	cell current_cell;
//	float growth_rate <- 0.09;
//	float transparency;
//	
//	reflex growth{
//		current_cell <- first(cell overlapping (self.location));
//		if current_cell != nil{
//			stock <- stock + growth_rate * stock * (1 - current_cell.population/current_cell.carrying_capacity);
//			if stock > 0.85*current_cell.carrying_capacity{
//				stock <- stock/2;
//				create sardine{
//					self.stock <- myself.stock;
//					self.location <- myself.location;
//				}
//			}	
//		}
//	}
//
//	reflex move {
//		do wander bounds: sea speed: 0.01 amplitude: 90.0;
//	}
//
//		
//	aspect base {
//		switch vision{
//			match "fade" {
//				float tmp <- self distance_to(trawler closest_to self);
//				transparency <-(max(0,1-tmp/radius))^(1/8);
//				draw  circle(sqrt(stock/5000)) color: rgb(color,transparency);
//			}
//			match "stock" {
//				float tmp <- self distance_to(trawler closest_to self);
//				draw  circle(sqrt(stock/5000)) color: color;
//			}
//			match "sonar" {
//				loop t over: trawler{
//					draw  circle(sqrt(stock/5000)) inter circle(radius,t.location) color: color;	
//				}
//			}
//		}
//	}
//}	
//
//
//species boat skills: [moving] parallel: false{
//	port homeport;
//	provinces home;
//	float effort;
////	cell current_cell;
//	geometry boundaries;
//	float speed;
//	float amplitude;
//	rgb color;
//	list<point> last_positions;
//	int dash <- 4;
//	float maintenance_cost;
//	float sales_income;
//	float capture;
//	sardine s;
//	
//	init{
//		location <- any_location_in(union(port collect(each.shape)));			homeport <- first(port overlapping self);
//		if homeport.name = "casa"{
//			heading <- 80.0;
//		}else{
//			heading <- 0.0;
//		}home <- one_of (provinces where (each.type = 'coast'));
//	}
//		
//	reflex move {
//		do wander bounds: boundaries speed: speed amplitude: amplitude;
//		last_positions <- last_positions+location;
//		if (length(last_positions) > trail_length*2*dash) and (mod(length(last_positions),2*dash)=0) {
//			last_positions <- last(trail_length*2*dash,last_positions);
//		}
//	}
//	
//	reflex fishing{
//		capture <- 0.0;
//		s <- sardine at_distance (1.5*radius) closest_to self;
//		float yield <- 0.0;
//		if s != nil{
//			yield <- min(effort,s.stock);
//			capture <- capture + yield;
//			s.stock <- s.stock - effort;
//			if s.stock < 0{
//				ask s {do die;}
//			}
//		}
//		sales_income <- price*yield;
//	}
//	
//	aspect default {
//		if show_trails{
//			loop i from: 0 to: length(last_positions)-2*dash step: 2*dash{
//				draw polyline(copy_between(last_positions,i,i+dash)) color: trail_color;
//			}
//		}
//		point line_vec <- (s.location-location)/8;
//		int imax <- norm(line_vec)=0?0:min(6,floor(radius/norm(line_vec)));
//		loop i from: 0 to: imax step: 2{
//			draw line([location+line_vec*i, location+line_vec*(i+1)]) color: sardine_color;
//		}
//		draw circle(0.04) color: color ;
//	}
//}
//
//species seiner parent: boat parallel: false{
//	rgb color <- #orange ;
//	float effort <- 0.3;
//	float speed <- 0.08;
//	float amplitude <- 120.0;
//	geometry boundaries <- shallow_waters;
//	int dash <- 2;
//	float maintenance_cost <- 0.045;
//	
//}
//
//species trawler parent: boat parallel: false{
//	rgb color <- rgb(211, 84, 0);
//	float effort <- 3.0;
//	float speed <- 0.04;
//	float amplitude <- 10.0;
//	geometry boundaries <- sea_for_boat_access;
//	float maintenance_cost <- 0.75;
//}
//
//species legend{
//	aspect default{
//		draw "seiners: "+nb_seiners at: {world.shape.width*0.67,world.shape.height*0.88} color: #black font: my_font;
//		draw "trawlers: "+nb_trawlers at: {world.shape.width*0.67,world.shape.height*0.95} color: #black font: my_font;
//		draw square(0.5) color: #green at: {world.shape.width*0.9,world.shape.height*0.92+0.05};
//		draw square(0.5) color: #red at: {world.shape.width*0.9+0.7,world.shape.height*0.92+0.05};
//	}
//}
//
//species sonar{
//	
//	aspect default{
//		if vision = "sonar"{
//			geometry g;
//			ask trawler{
//				g <- union(g,circle(radius,self.location));
//			}
//				//if species(self)=trawler{
//			draw inter(g,union(sea_provinces)) color: rgb(205,205,255,20);
//			//draw world.shape color:#green;
//		}
//	}
//}



//
//
//experiment fisheries type: gui autorun: false {
//	parameter name: 'User name' var: game_name  category: 'Game' on_change: {if cycle = 0 {output_file <- world.get_output_file();}do update_outputs();};
//	parameter name: 'Objective:' var: objective category: 'Game' on_change: {do update_outputs();};
//	
//	text  message: "Buy and sell ships to get the highest score at the end of the simulation ("+
//					end_date+" steps)." category: Game;
//	text  message:"After "+(end_date-no_buy_duration)+" steps, you cannot buy or sell boats." category: Game;
//	user_command "Buy ship     (-1000 \u01e4)" category: "Game" color: fish_stock_color when: (cycle<end_date-no_buy_duration) {if capital>1000 {nb_trawlers <- nb_trawlers+1;capital <- capital-1000;}}
//	user_command "Sell ship      (+600 \u01e4)" category: "Game" color: rgb(231,76,60) when: (cycle<end_date-no_buy_duration){if nb_trawlers > 0 {nb_trawlers <- nb_trawlers-1; capital <- capital+600;}}
//	parameter name: "Font size" var: my_font_size min: 6 max: 26 on_change: {do update_outputs();} category: 'Display';
////	parameter name: "Point of view" var: vision init: "sonar" category: 'Display' among: ['heatmap','sonar','fade','stock'] on_change: {do update_outputs();};
//	parameter name: 'Show trails' var: show_trails  category: 'Display';
////	parameter name: 'Trails length' var: trail_length init: 10 category: 'Display';
//	
//	float overlay_rel_width <- 0.62;
//	float overlay_rel_height <- 0.25;
//		
//	output {
//		layout horizontal([0::140,vertical([1::100,2::100])::100]) tabs: true;
//		display 'Provinces' type: 3d background: rgb(47,47,47)  toolbar: false refresh: every(1#cycle){
//		//	grid cell border: #black;
//			species provinces aspect: base ;
//			species seiner;
//			species trawler;
//			species sardine aspect: base ;
//			species sonar;
//			species port;
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
//	}
//}
//




experiment fisheries type: gui autorun: false {
	parameter name: 'User name' var: game_name  category: 'Game (Master)' on_change: {if cycle = 0 {output_file <- world.get_output_file();}do update_outputs();};
	parameter name: 'Objective:' var: objective category: 'Game (Master)' on_change: {do update_outputs();};
	user_command "Buy ship     (-1000 \u01e4)" category: "Game" color: fish_stock_color when: (cycle<end_date-no_buy_duration) {if capital>1000 {nb_trawlers <- nb_trawlers+1;capital <- capital-1000;}}
	user_command "Sell ship      (+600 \u01e4)" category: "Game" color: rgb(231,76,60) when: (cycle<end_date-no_buy_duration){if nb_trawlers > 0 {nb_trawlers <- nb_trawlers-1; capital <- capital+600;}}
	parameter name: "Font size" var: my_font_size min: 6 max: 26 on_change: {do update_outputs();} category: 'Display';
//	parameter name: "Point of view" var: vision init: "sonar" category: 'Display' among: ['heatmap','sonar','fade','stock'] on_change: {do update_outputs();};
	parameter name: 'Show trails' var: show_trails  category: 'Display';
	float overlay_rel_width <- 0.62;
	float overlay_rel_height <- 0.25;
		
	output {
		layout horizontal([0::140,vertical([1::100,2::100])::100]) tabs: true;
		display 'Provinces' type: 3d background: rgb(47,47,47)  toolbar: false refresh: every(1#cycle){
	//		grid cell border: #black;
			species provinces aspect: base ;
			species sardine aspect: base ;
			species seiner;
			species trawler;
			species sonar;
			species port;
			
			overlay position: { world.shape.width*0.4, world.shape.height*1.05} size: {overlay_rel_width,overlay_rel_height} background: rgb(44,62,80) transparency: 0.2 border: #black rounded: true
            {
            	float overlay_width <- world.shape.width*overlay_rel_width;
    			float overlay_height <- world.shape.height*overlay_rel_height;
            	if cycle = 0{
            		if game_name = "Enter your name"{
            			draw "Enter your name\n(on left panel)" anchor: #center at: {overlay_width/2,overlay_height/3} color: #white font: font("SansSerif", 2*my_font_size, #bold);
            		}else{
            			draw "Welcome "+game_name anchor: #center at: {overlay_width/2,overlay_height*0.3} color: #white font: font("SansSerif", 1.5*my_font_size, #bold);
            			draw "Your objective: "+objective anchor: #center at: {overlay_width/2,overlay_height*0.7} color: #white font: font("SansSerif", 1.5*my_font_size, #bold);
            		}
           		}else{
            		draw "Capture: "+compute_score(total_capture)+"Tons (income: "+trunc(price*capture,1)+" per day)" 
            			at: {0.05*overlay_width,0.2*overlay_height} anchor: #left_center color: objective="Maximize capture"?score_color:#white font: font("SansSerif", my_font_size, #bold);
	            	draw "Capital: "+compute_score(capital)+"\u01e4" at: {0.05*overlay_width,0.5*overlay_height} anchor: #left_center color: objective="Maximize capture"?#white:score_color font: font("SansSerif", my_font_size, #bold);
	            	draw "Ships: "+nb_trawlers+" (cost: "+fleet_maintenance_cost+" \u01e4 per day)" 
	            		at: {0.05*overlay_width,0.8*overlay_height} anchor: #left_center color: cycle<end_date-no_buy_duration?#white:rgb(30,30,30) font: font("SansSerif", my_font_size, #bold); 		
            	}
            }		
		}
		display  Capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
			chart name: 'Daily capture' type: series x_serie: xaxis background: rgb(47,47,47) color: #white title_font:"SansSerif" {
				data legend: 'Capture' value: capture_chart style: area color: rgb(capture_color,0.7) thickness: 2 marker: false;
			}
		}
		display  "Fishery results" refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
			chart name: 'Net profit, fleet size' type: series x_serie: xaxis background: rgb(47,47,47) color: #white title_font:"SansSerif" {
				data legend: 'Net profit' value: net_profit_chart style: area fill: true color: rgb(profit_color,0.7) thickness: 2 marker: false;
				data legend: 'Ships' value: trawler_chart style: line color: trawler_color line_visible: false
						 marker: true marker_size: 0.1;
			}
		}			
	}
}