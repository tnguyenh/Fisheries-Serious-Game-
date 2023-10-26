/**
 *  Fisheries
 *  Author: Tri Nguyen-Huu
 *  Description: 
 */

model fisheries_game_master


import "import/main_model_v2.gaml"

global{
	int nb_trawlers <- 25;
	float capital <- 100000000;
	
	string output_path <- "../output/";
	file shape_file_provinces <- file('../includes/maroc_2012.shp');
	int end_date <- 20000;
	bool is_benchmark <- true;
	
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
	parameter name: "Point of view" var: vision init: "sonar" category: 'Display' among: ['heatmap','sonar','fade','stock'] on_change: {do update_outputs();};
	parameter name: 'Show trails' var: show_trails  category: 'Display';
	parameter name: 'Trails length' var: trail_length init: 10 category: 'Display';
	
	float overlay_rel_width <- 0.62;
	float overlay_rel_height <- 0.25;
		
	output {
		layout horizontal([0::140,vertical([1::100,2::100,3::100])::100]) tabs: false;
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
	
		display stock refresh: every(50#cycle) type: 3d  background: #black toolbar: false{
			chart name: 'Fish stock' type: series background: rgb(47,47,47) title_font:"SansSerif" color: #white  {
				data legend: 'Fish stock' value: sum(sardine collect(each.stock)) style: line color: fish_stock_color thickness: 2 marker: false;
			}
		}

		display  Capture refresh: every(10#cycle) type: 3d  background: #black toolbar: false{
			chart name: 'Daily capture' type: series x_serie: xaxis background: rgb(47,47,47) color: #white title_font:"SansSerif" {
				data legend: 'Capture' value: capture_chart style: area color: rgb(capture_color,0.7) thickness: 2 marker: false;
			}
		}
		display  "Fishery results" refresh: every(10#cycle) type: 3d  background: #black toolbar: false{
			chart name: 'Net profit, fleet size' type: series x_serie: xaxis background: rgb(47,47,47) color: #white title_font:"SansSerif" {
				data legend: 'Net profit' value: net_profit_chart style: area fill: true color: rgb(profit_color,0.7) thickness: 2 marker: false;
				data legend: 'Ships' value: trawler_chart style: line color: trawler_color line_visible: false
						 marker: true marker_size: 0.1;
			}
		}		


//		display  Capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
//			chart name: 'Daily capture' type: series  background: rgb(47,47,47) color: #white  {
//				data legend: 'Capture' value: mean(capture_movmean) style: line color: capture_color thickness: 2 marker: false;
//			}
//		}
//		display  "Fishery results" refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
//			chart name: 'Net profit, fleet size' type: series  background: rgb(47,47,47) color: #white  {
//				data legend: 'Net profit' value: mean(net_profit_movmean) style: area fill: true color: rgb(profit_color,0.4) thickness: 2 marker: false;
//				data legend: 'Fleet size' value: nb_trawlers  style: line line_visible: true color: trawler_color thickness: 1 marker: false marker_size: 0.1;			
//			}
//		}		
	}
}



//experiment "fisheries with price" type: gui {
//	user_command "Buy trawler a modifier  (-1000 \u01e4)" category: "Vessels" color:#green {nb_trawlers <- nb_trawlers+1;}
//	user_command "Sell trawler  (+300 \u01e4)" category: "Vessels" color:#red {nb_trawlers <- nb_trawlers-1;}
//	parameter name: "Point of view" var: vision init: "sonar" category: 'display' among: ['heatmap','sonar','fade','stock'] on_change: {do update_outputs();};
//	parameter name: 'Show trails' var: show_trails  category: 'display';
//	parameter name: 'Trails length' var: trail_length init: 10 category: 'display';
//	parameter name: 'Variable price' var: variable_price init: false read_only: true category: 'display';
//	output {
//		layout #split tabs: true;
////		layout horizontal([1::100,vertical([1::100,2::100])::100]) tabs: true;
//		display 'Provinces' type: 3d background: #black toolbar: false{
//			//grid cell;// border: #black;
//			species provinces aspect: base ;
//			species seiner;
//			species trawler;
//			species sardine aspect: base ;
//			species sonar;
//	//		species legend;
//			species port;
//			overlay position: { world.shape.width*0.6, world.shape.height*1.15 } size: { 0.42,0.25} background: #black transparency: 0.2 border: #black rounded: true
//   //			overlay position: {0.5,0.99} size: {0.5,0.2} background: #black transparency: 0.2 border: #black rounded: true
//            {
//	            draw string("Score: "+compute_score(total_capture))+" Tons" at: {0.4,0.5} color: #white font: font("SansSerif", 18, #bold);
//	            draw string("Revenue: "+compute_score(income))+" \u01e4" at: {0.4,1.0} color: #white font: font("SansSerif", 18, #bold);
//	            draw string("Trawlers: "+nb_trawlers) at: {0.4,1.5} color: #white font: font("SansSerif", 18, #bold); 
//	            draw string("Seiners: "+nb_seiners) at: {0.4,2.0} color: #white font: font("SansSerif", 18, #bold); 
//            }		
//		}
//	
//		display stock refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
////			chart name: 'Fish stock' type: series background: rgb(47,47,47) color: #white  {
////				data legend: 'Fish stock' value: sum(sardine collect(each.stock)) style: spline color: rgb(52,152,219) marker: false;
////			}
//		}
//		display  capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
////			chart name: 'Daily capture' type: series background: rgb(47,47,47) color: #white  {
////				data legend: 'Average capture' value: mean(capture_movmean) style: spline color: rgb(143,86,18) marker: false;
////				data legend: 'Demand' value: demand(price) style: spline color: #red marker: false;
////			}
//		}		
////		display  total_capture refresh: every(10#cycle) type: 2d  background: #black toolbar: false{
////			chart name: 'Total capture' type: series background: rgb(47,47,47) color: #white  {
////				data legend: 'Total capture' value: total_capture style: spline color: rgb(143,86,18) marker: false;
////			}
////		}
//	}
//}





experiment make_reference  type: batch until: (cycle > end_date) or (countdown < 0) {
	parameter name: 'Duration' var: end_date <- 10000 read_only: true;
	parameter name: 'Output path' var: output_path init: '../output/refs/' among: ['../output/refs/'];
	parameter name: 'Number of trawlers' var: nb_trawlers min: 4 max: 32 step: 4;
} 
