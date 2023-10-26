/**
* Name: parameters
* Based on the internal empty template. 
* Author: Tri
* Tags: 
*/


model parameters

global{
	int scn_nb_points <- 500;
	
	string color_palette_name <- "OrRd";//"OrRd";//"RdBu";
	list<rgb> palette <- brewer_colors (color_palette_name);
	rgb sea_color <- rgb(44, 130, 201,0.95);
	rgb shallow_color <- rgb(44, 130, 201,0.85);
	rgb fish_stock_color <-  rgb(97,205,114);
	rgb capture_color <- rgb(52,152,219);
	rgb profit_color <- rgb(243,157,49);
	rgb maintenance_color <- rgb(102,57,43);
	rgb score_color <- rgb(241,196,48);
	rgb sardine_color <- rgb(30, 81, 123);
	rgb trail_color <- #grey;
	rgb trawler_color <- rgb(149,165,166);
	
	list<string> port_names <- ["casa","safi","agadir"];
	
}

