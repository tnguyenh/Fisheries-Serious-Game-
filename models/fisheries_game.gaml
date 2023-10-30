/**
 *  Fisheries
 *  Author: Tri Nguyen-Huu
 *  Description: 
 */

model fisheries

import "import/main_model.gaml"

global{
	string output_path <- "../output/";
	file shape_file_provinces <- file('../includes/maroc_2012.shp');
	int end_date <- 10000;
	bool is_benchmark <- false;
	string vision <- "sonar";
	
	init{
		do init_sim;
	}
}




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