/**
 *  pecheries
 *  Author: Alassane Bah, Tri Nguyen-Huu
 *  Description: 
 */

model pecheries

global {
	int nb_seiners <- 0;// parameter: 'Nombre de Seiners:' category: 'Vessels';
	int nb_trawlers <- 5;// parameter: 'Nombre de Trawlers:' category: 'Vessels';
	int nb_sardine <- 100;// parameter: 'Densite de Sardine:' category: 'Fish';
	float price <- 5.0;
	int end_date <- 2000;
	
	string output_file;
	string output_path <- "../output/";
	
	string vision <- "heatmap"; 
	bool show_trails <- false; 	
	bool pov <- true;
	bool variable_price;
	int trail_length;
	int sliding_window <- 100;
	font my_font <- font("Helvetica", 16 , #plain);
	//file shape_file_grass <- file("../includes/gis/gridsngreen.shp");
	
	//var shape_file_provinces type: string init: '../includes/maroc_2012.shp' parameter: 'Shapefile for the provinces:' category: 'GIS';
	file shape_file_provinces <- file('../includes/maroc_2012.shp');
	
	string color_palette_name <- "OrRd";//"OrRd";//"RdBu";
	list<rgb> palette <- brewer_colors (color_palette_name);
	rgb sea_color <- rgb(44, 130, 201,0.95);
	rgb shallow_color <- rgb(44, 130, 201,0.85);
	rgb trail_color <- #grey;
	int nb_last_positions <- 100;
	float capture <- 0.0;
	list<float> capture_sliding_mean <-[];
	float total_capture <- 0.0;
	string score <- "0";
	float income <-0.0;
	float fish_stock;
	float radius <- 0.6;

	list<provinces> sea_provinces <- [];
	
//	list<float> stock_history;
//	list<float> yield_history;
//	list<float> revenue_history;
//	list<float> trawler_history;
	

	
	
	geometry shallow_waters;
	geometry sea;
	
	geometry shape <- envelope(shape_file_provinces);

	init {
		
		output_file <- get_output_file();
		
		int current_color <-3 ;
		create species: provinces from: shape_file_provinces  {
			if (name = 'provinces7'){
				type <- 'sea';
				color <- sea_color;
			}else{
				type <- 'land';
				color <- palette[current_color];
				current_color <- current_color + 1;
			}
		}
		
		sea_provinces <- provinces where (each.type = 'sea');
		
		ask provinces{
			if  distance_to(self,  union(sea_provinces)) < 0.01 and type != 'sea'{
				type <- 'coast';
			}
		}
		
		shallow_waters <- inter(1.2 around(provinces where (each.type = 'coast')), union(sea_provinces));
		
		ask sea_provinces{
			create provinces{
				shape <- inter(myself.shape,shallow_waters);
				type <- 'shallow waters';
				name <- myself.name+'_shallow';
				color <- shallow_color;
			}
			shape <- shape - shallow_waters;
		}
		
		sea_provinces <- provinces where (each.type = 'sea' or each.type = 'shallow waters');

		sea <- union(sea_provinces collect(each.shape));
		
		create port {
			location <- {5.8,2.4};
			name <- "casa";
		}

		create port {
			location <- {3.92,5.6};
			name <- "agadir";
		}
		
		create port {
			location <- {3.8,4.5};
			name <- "safi";
		}
					
		create seiner number: nb_seiners;
		create trawler number: nb_trawlers;
		
		create sardine number: 200 {//80
			location <- any_location_in(sea);
			stock <- rnd(200.0);//50
		}

		ask cell{
			if self.shape - sea != nil{
				border <- true;
			}
			if inter(self.shape, sea) != nil{
				at_sea <- true;
			}
		}
		

		create sonar;
		create legend;
	}
	
	reflex save_data when: cycle < end_date{
		save [fish_stock, capture, income, nb_trawlers] format: csv rewrite: false to: output_file;
	}
	
	reflex endSim when: (cycle=end_date) {
		write "End of the simulation";
		do pause;
	}
	
	

	reflex update{
		capture_sliding_mean <- last(sliding_window,capture_sliding_mean+capture);
		total_capture <- total_capture + capture;
		score <- compute_score(total_capture);
		income <- income+sum((trawler+seiner) collect(each.revenue));
		
		fish_stock <- sum(sardine collect(each.stock));
		
		capture <- 0.0;	
		if length(trawler) < nb_trawlers{
			create trawler;
		}
		if length(trawler) > nb_trawlers{
			ask one_of(trawler) {do die;}
		}
	}
	
	string get_output_file{
		file dir;
		if !folder_exists(output_path){
			dir <- new_folder(output_path);
		}else{
			dir <- folder(output_path);
		}
	//	list<string> file_list <- list<string>(dir.contents) where(copy_between(each,length(each)-4,length(each))=".csv");
	//	if empty(file_list){
		return output_path+"ouput_"+rnd(100000000)+rnd(100000000)+".csv";
	//	}else{
	//		return output_path+first(file_list);
	//	}
	}
	
	string compute_score(float a){
		//int sign <- a<0?-1:1;
		//float b <- abs(a);
		if abs(a) < 10^3{
			return string(round(a));
		}else if abs(a) < 10^6{
			return string(round(a/100)/10)+"K";
		}else if abs(a) < 10^9{
			return string(round(a/10^5)/10)+"M";
		}else if abs(a) < 10^12{
			return string(round(a/10^8)/10)+"B";
		}
	}
	
	float demand(float p){
		float A <- 100.0;
		float d <- 10.0;
		return A-d*p;
	}
	
//	reflex stop_simulation when: time = 1000 {
//		do action: halt ;
//	}	
		
}


grid cell width: 20 height: 20 neighbors: 8{
	float carrying_capacity <- 200.0;//50.0;
	float smoothed_population <- 0.0;
	float population -> sum((sardine overlapping self) collect each.stock);
	bool border <- false;
	bool at_sea <- false;
	rgb color <- rgb(255,255,255,1);
	
	reflex reinit_color when: vision != "heatmap" and at_sea{
		color <- rgb(255,255,255,1);
	}
	
	reflex count_population when: vision = "heatmap" and !border and at_sea{
		smoothed_population <- (population + sum(self.neighbors collect each.population))/(1+length(self.neighbors));
		int index <- int(255*min(1.0,(3*smoothed_population/carrying_capacity)^0.6));
		color <-  rgb(255-index, 255-index, 255);
	}
}


species provinces {
	string  type ;
	rgb color <-#blue; 
	
	aspect base {
		draw shape  color: color ;
	}
}

species port{
	float r <- 0.1;
	
	aspect default {
		draw circle(r) color: #white at: location;
	}
}
	
species sardine skills: [moving]{
	//rgb color <- rgb(30, 81, 123,0.05);
	rgb color <- rgb(30, 81, 123);
	float stock <- 50.0;
	cell current_cell;
	float growth_rate <- 0.09;
	float transparency;
	
	reflex growth{
		current_cell <- first(cell overlapping (self.location));
		if current_cell != nil{
			stock <- stock + growth_rate * stock * (1 - current_cell.population/current_cell.carrying_capacity);
			if stock > 0.85*current_cell.carrying_capacity{
				stock <- stock/2;
				create sardine{
					self.stock <- myself.stock;
					self.location <- myself.location;
				}
			}	
		}
	}

	reflex move {
		do wander bounds: sea speed: 0.01 amplitude: 90.0;
	}

		
	aspect base {
		switch vision{
			match "fade" {
				float tmp <- self distance_to(trawler closest_to self);
				transparency <-(max(0,1-tmp/radius))^(1/8);
				draw  circle(sqrt(stock/5000)) color: rgb(color,transparency);
			}
			match "stock" {
				float tmp <- self distance_to(trawler closest_to self);
				draw  circle(sqrt(stock/5000)) color: color;
			}
			match "sonar" {
				loop t over: trawler{
					draw  circle(sqrt(stock/5000)) inter circle(radius,t.location) color: color;	
				}
			}
		}
	}
}	


species boat skills: [moving]{
	port homeport;
	provinces home;
	float effort;
	cell current_cell;
	geometry boundaries;
	float speed;
	float amplitude;
	rgb color;
	list<point> last_positions;
	int dash <- 4;
	float maintenance_cost;
	float revenue;
	
	init{
		location <- any_location_in(union(port collect(each.shape)));			homeport <- first(port overlapping self);
		if homeport.name = "casa"{
			heading <- 80.0;
		}else{
			heading <- 0.0;
		}home <- one_of (provinces where (each.type = 'coast'));
	}
		
	reflex move {
		do wander bounds: boundaries speed: speed amplitude: amplitude;
		last_positions <- last_positions+location;
		if (length(last_positions) > trail_length*2*dash) and (mod(length(last_positions),2*dash)=0) {
			last_positions <- last(trail_length*2*dash,last_positions);
		}
	}
	
	reflex fishing{
		current_cell <- first(cell overlapping (self.location));
		sardine s <- one_of(sardine overlapping current_cell);
		float yield <- 0.0;
		if s != nil{
			yield <- min(effort,s.stock);
			capture <- capture + yield;
			s.stock <- s.stock - effort;
			if s.stock < 0{
				ask s {do die;}
			}
		}
		revenue <- price*yield-maintenance_cost;
	}
	
	aspect default {
		if show_trails{
			loop i from: 0 to: length(last_positions)-2*dash step: 2*dash{
				draw polyline(copy_between(last_positions,i,i+dash)) color: trail_color;
			}
		}
		draw circle(0.04) color: color ;
	}
}

species seiner parent: boat {
	rgb color <- #orange ;
	float effort <- 1.0;
	float speed <- 0.08;
	float amplitude <- 120.0;
	geometry boundaries <- shallow_waters;
	int dash <- 2;
	float maintenance_cost <- 1.0;
	
}

species trawler parent: boat {
	rgb color <- rgb(211, 84, 0);
	float effort <- 20.0;
	float speed <- 0.04;
	float amplitude <- 10.0;
	geometry boundaries <- sea;
	float maintenance_cost <- 20.0;
}

species legend{
	aspect default{
		draw "seiners: "+nb_seiners at: {world.shape.width*0.67,world.shape.height*0.88} color: #black font: my_font;
		draw "trawlers: "+nb_trawlers at: {world.shape.width*0.67,world.shape.height*0.95} color: #black font: my_font;
		draw square(0.5) color: #green at: {world.shape.width*0.9,world.shape.height*0.92+0.05};
		draw square(0.5) color: #red at: {world.shape.width*0.9+0.7,world.shape.height*0.92+0.05};
	}
}

species sonar{
	
	aspect default{
		if vision = "sonar"{
			geometry g;
			ask trawler{
				g <- union(g,circle(radius,self.location));
			}
				//if species(self)=trawler{
			draw inter(g,union(sea_provinces)) color: rgb(205,205,255,20);
			//draw world.shape color:#green;
		}
	}
}





experiment fisheries type: gui {
	user_command "Add trawler" category: "Vessels" color:#green {nb_trawlers <- nb_trawlers+1;}
	user_command "Remove trawler" category: "Vessels" color:#red {nb_trawlers <- nb_trawlers-1;}
	parameter name: "Point of view" var: vision init: "sonar" category: 'display' among: ['heatmap','sonar','fade','stock'] on_change: {do update_outputs();};
	parameter name: 'Show trails' var: show_trails  category: 'display';
	parameter name: 'Trails length' var: trail_length init: 10 category: 'display';
	parameter name: 'Variable price' var: variable_price init: false read_only: true category: 'display';
	output {
//		layout #split tabs: true;
		layout horizontal([0::140,vertical([1::100,2::100])::100]) tabs: true;
		display 'Provinces' type: 3d background: #black toolbar: false{
			grid cell;// border: #black;
			species provinces aspect: base ;
			species seiner;
			species trawler;
			species sardine aspect: base ;
	//		species legend;
			species sonar;
			species port;
			overlay position: { world.shape.width*0.6, world.shape.height*1.05} size: { 0.42,0.25} background: #black transparency: 0.2 border: #black rounded: true
   //			overlay position: {0.5,0.99} size: {0.5,0.2} background: #black transparency: 0.2 border: #black rounded: true
            {
	            draw string("Score: "+score) at: {0.4,0.5} color: #white font: font("SansSerif", 18, #bold);
	            draw string("Revenue: "+compute_score(income))+" \u01e4" at: {0.4,1.0} color: #white font: font("SansSerif", 18, #bold);
	            draw string("Trawlers: "+nb_trawlers) at: {0.4,1.5} color: #white font: font("SansSerif", 18, #bold); 
	            draw string("Seiners: "+nb_seiners) at: {0.4,2.0} color: #white font: font("SansSerif", 18, #bold); 
	            
	            
	            
            }		
		}
	
		display stock refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
			chart name: 'Fish stock' type: series background: rgb(47,47,47) color: #white  {
				data legend: 'Fish stock' value: sum(sardine collect(each.stock)) style: spline color: rgb(52,152,219) marker: false;
			}
		}
		display  capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
			chart name: 'Daily capture' type: series background: rgb(47,47,47) color: #white  {
				data legend: 'Average capture' value: mean(capture_sliding_mean) style: spline color: rgb(143,86,18) marker: false;
			}
		}		
//		display  total_capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
//			chart name: 'Total capture' type: series background: rgb(47,47,47) color: #white  {
//				data legend: 'Total capture' value: total_capture style: spline color: rgb(143,86,18) marker: false;
//			}
//		}
	}
}



experiment "fisheries with price" type: gui {
	user_command "Add trawler" category: "Vessels" color:#green {nb_trawlers <- nb_trawlers+1;}
	user_command "Remove trawler" category: "Vessels" color:#red {nb_trawlers <- nb_trawlers-1;}
	parameter name: "Point of view" var: vision init: "sonar" category: 'display' among: ['heatmap','sonar','fade','stock'] on_change: {do update_outputs();};
	parameter name: 'Show trails' var: show_trails  category: 'display';
	parameter name: 'Trails length' var: trail_length init: 10 category: 'display';
	parameter name: 'Variable price' var: variable_price init: false read_only: true category: 'display';
	output {
		layout #split tabs: true;
//		layout horizontal([1::100,vertical([1::100,2::100])::100]) tabs: true;
		display 'Provinces' type: 3d background: #black toolbar: false{
			grid cell;// border: #black;
			species provinces aspect: base ;
			species seiner;
			species trawler;
			species sardine aspect: base ;
			species sonar;
	//		species legend;
			species port;
			overlay position: { world.shape.width*0.6, world.shape.height*1.15 } size: { 0.42,0.25} background: #black transparency: 0.2 border: #black rounded: true
   //			overlay position: {0.5,0.99} size: {0.5,0.2} background: #black transparency: 0.2 border: #black rounded: true
            {
	            draw string("Score: "+score) at: {0.4,0.5} color: #white font: font("SansSerif", 18, #bold);
	            draw string("Revenue: "+compute_score(income))+" \u01e4" at: {0.4,1.0} color: #white font: font("SansSerif", 18, #bold);
	            draw string("Trawlers: "+nb_trawlers) at: {0.4,1.5} color: #white font: font("SansSerif", 18, #bold); 
	            draw string("Seiners: "+nb_seiners) at: {0.4,2.0} color: #white font: font("SansSerif", 18, #bold); 
            }		
		}
	
		display stock refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
			chart name: 'Fish stock' type: series background: rgb(47,47,47) color: #white  {
				data legend: 'Fish stock' value: sum(sardine collect(each.stock)) style: spline color: rgb(52,152,219) marker: false;
			}
		}
		display  capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
			chart name: 'Daily capture' type: series background: rgb(47,47,47) color: #white  {
				data legend: 'Average capture' value: mean(capture_sliding_mean) style: spline color: rgb(143,86,18) marker: false;
				data legend: 'Demand' value: demand(price) style: spline color: #red marker: false;
			}
		}		
//		display  total_capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
//			chart name: 'Total capture' type: series background: rgb(47,47,47) color: #white  {
//				data legend: 'Total capture' value: total_capture style: spline color: rgb(143,86,18) marker: false;
//			}
//		}
	}
}
