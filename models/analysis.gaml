/**
 *  pecheries
 *  Author: Tri Nguyen-Huu
 *  Description: 
 */


model analysis

import "import/parameters.gaml"

global {
	float mc;
	string input_path <- "../output/";
	list<string> sorted_input_list <- (list<string>(folder(input_path).contents) - "refs" - "old") sort_by(each);
	list<string> game_list_by_user <- sorted_input_list collect(copy_between(first(regex_matches(each,"_.*_")),1,length(first(regex_matches(each,"_.*_")))-1));
	list<string> game_list_by_type <- sorted_input_list collect(copy_between(first(regex_matches(each,"_[cp]-")),1,2));
	list<string> users <- remove_duplicates(game_list_by_user);
	list<int> aux_int_series <- game_list_by_user collect (game_list_by_user index_of each);
	list<int> int_series <- all_indexes_of(list_with(length(sorted_input_list),1),1);
	list<string> game_list <- int_series collect(game_list_by_user[each]+" ("+(each - aux_int_series[each]+1)+")("+game_list_by_type[each]+")");
	
	string current_game_id <-first(game_list);	
	string indicator <- "fish stock";

	int sliding_window <- 100;
	int scn_sliding_window <- 500;
	font my_font <- font("Helvetica", 16 , #plain);
	
	
	list<float> capture_movmean <-[];
	list<float> net_profit_movmean <-[];

	int nb_points <- 100;
	
	float max_fish_stock;
	float max_capture;
	float max_profit;
	list<list<float>> whisker_fish_stock;
	list<list<float>> whisker_capture;
	list<list<float>> whisker_profit;
	float scale_capture;
	float scale_profit;	
	
	float scn_max_fish_stock;
	float scn_max_capture;
	float scn_max_profit;
	float scn_max_income;
	float scn_scale_capture;
	float scn_scale_profit;	
	float scn_scale_income;	
	
	int max_nb_trawlers;
	
	list<point> scat_maintenance <-[];
	list<point> scat_income <-[];

	game cg;
	scenario cs;
			
	list<float> unsorted_fish_stock_score_list;
	list<float> unsorted_capture_score_list;	
	list<float> unsorted_profit_score_list;
	list<float> fish_stock_score_list;
	list<float> capture_score_list;
	list<float> profit_score_list;
	
	list<string> ranking;
	
	/* reference scenarios */
	string scn_input_path <- input_path+"refs/";
	list<string> sorted_scn_list <- (list<string>(folder(scn_input_path).contents)  - "old") sort_by(each);
	list<string> trawler_list <- sorted_scn_list collect(copy_between(first(regex_matches(each,"f_.*_t")),2,length(first(regex_matches(each,"f_.*_t")))-2));
	list<string> id_list <- sorted_scn_list collect(copy_between(first(regex_matches(each,"s_.*csv")),2,length(first(regex_matches(each,"s_.*csv")))-4));
	list<int> int_series2 <- all_indexes_of(list_with(length(sorted_scn_list),1),1);
	list<string> scn_list <- int_series2 collect(trawler_list[each]+" ships ("+id_list[each]+")");

	string current_scenario_id <- first(scn_list);

	init {
		// load ref scenarios
		loop s from: 0 to: length(scn_list)-1{
			create scenario {
				id <- scn_list[s]; 
				filename <- scn_input_path+sorted_scn_list[s];	
				sliding_window <- myself.scn_sliding_window;		
				do load_csv_file;
			}
		}
		
		scn_max_fish_stock <- max(scenario accumulate(last(scn_nb_points,each.fish_stock)));
		scn_max_capture <- max(scenario accumulate(last(scn_nb_points,each.capture_movmean)));
		scn_scale_capture <- scn_max_fish_stock / scn_max_capture;
		scn_max_profit <- max(scenario accumulate(last(scn_nb_points,each.net_profit_movmean)));
		scn_scale_profit <- scn_max_fish_stock / scn_max_profit;
		scn_max_profit <- max(scenario accumulate(last(scn_nb_points,each.net_profit_movmean)));
		scn_scale_profit <- scn_max_fish_stock / scn_max_profit;
		scn_max_income <- max(scenario accumulate(last(scn_nb_points,each.income_movmean)));
		scn_scale_income <- scn_max_fish_stock / scn_max_income;
		
		max_nb_trawlers <- int(max(scenario collect(max(each.nb_trawlers))));
		
		ask scenario{
			if last(self.income_movmean)=0{
				scat_income <- scat_income + {self.nb_trawlers[0],0};
			}else{
				scat_income <- scat_income + (last(scn_nb_points,self.income_movmean) collect({self.nb_trawlers[0],each}));
			}
			//scat_maintenance <- scat_maintenance + {self.nb_trawlers[0],self.maintenance[0]};
		}
		
		do compute_scat_maintenance;
		
		// load games
		
		loop g from: 0 to: length(game_list)-1{
			create game {
				user <- game_list_by_user[g];
				filename <- input_path+sorted_input_list[g];
				id <- game_list[g];
				objective <- game_list_by_type[g];
				sliding_window <- myself.sliding_window;				
				do load_csv_file;
			}
		}
		
		
		max_fish_stock <- max(game accumulate(last(nb_points,each.fish_stock)));
		max_capture <- max(game accumulate(last(nb_points,each.capture_movmean)));
		scale_capture <- max_fish_stock / max_capture;
		max_profit <- max(game accumulate(last(nb_points,each.net_profit_movmean)));
		scale_profit <- max_fish_stock / max_profit;
		
		list<float> fish_stock_pool_c <- game where (each.objective="c") accumulate(last(nb_points,each.fish_stock));
		list<float> fish_stock_pool_p <- game where (each.objective="p") accumulate(last(nb_points,each.fish_stock));
		whisker_fish_stock <- [compute_stats(fish_stock_pool_c),compute_stats(fish_stock_pool_p)];
		list<float> capture_pool_c <- game where (each.objective="c") accumulate(last(nb_points,each.capture_movmean));
		capture_pool_c <- capture_pool_c collect (each*scale_capture);
		list<float> capture_pool_p <- game where (each.objective="p") accumulate(last(nb_points,each.capture_movmean));
		capture_pool_p <- capture_pool_p collect (each*scale_capture);
		whisker_capture <- [compute_stats(capture_pool_c),compute_stats(capture_pool_p)];
		list<float> profit_pool_c <- game where (each.objective="c") accumulate(last(nb_points,each.net_profit_movmean));
		profit_pool_c <- profit_pool_c collect (each*scale_profit);
		list<float> profit_pool_p <- game where (each.objective="p") accumulate(last(nb_points,each.net_profit_movmean));
		profit_pool_p <- profit_pool_p collect (each*scale_profit);
		whisker_profit <- [compute_stats(profit_pool_c),compute_stats(profit_pool_p)];
	
		// scores
		
		unsorted_fish_stock_score_list <-game collect(each.fish_stock_score);
		unsorted_capture_score_list <-game collect(each.capture_score);
		unsorted_profit_score_list <-game collect(each.profit_score);
	
		
		do sort_lists;

		cg <- current_game();
		cs <- current_scenario();
		
		
	}
	
	action compute_scat_maintenance{
		scat_maintenance <-[{0,0},{max_nb_trawlers,mc*max_nb_trawlers}];
	}
	
	action sort_lists{
		list<float> ref_list;
		switch indicator{
			match "fish stock"{ref_list <- unsorted_fish_stock_score_list;}
			match "capture"{ref_list <- unsorted_capture_score_list;}
			match "profit"{ref_list <- unsorted_profit_score_list;}
		}
		list<float> sorted_ref_list <- ref_list sort_by each;
		list<int> order_list <- sorted_ref_list collect(index_of(ref_list,each));
		ranking <- order_list accumulate(['','',game_list_by_user[each]+' ('+game_list_by_type[each]+')','','']);
		fish_stock_score_list <- order_list accumulate([0,unsorted_fish_stock_score_list[each], 0, 0,0]);
		capture_score_list <- order_list accumulate([0,0,scale_capture*unsorted_capture_score_list[each],0,0]);
		profit_score_list <- order_list accumulate([0,0,0,scale_profit*unsorted_profit_score_list[each],0]);
	}
	
	game current_game{
		return first(game where (each.id = current_game_id));
	}
	
	scenario current_scenario{
		return first(scenario where (each.id = current_scenario_id));
	}
	
	list<float> compute_stats(list<float> l){
		return [mean(l),median(l), quantile(l sort_by each,0.25),quantile(l sort_by each,0.75),min(l),max(l)];
	}	
}


species game{
	int nb_values;
	string objective;
	list<float> fish_stock <- [];
	list<float> nb_trawlers <- [];
	list<float> capture <- [];
	list<float> net_profit <- [];
	list<float> income <- [];
	list<float> capture_movmean <- [];
	list<float> net_profit_movmean <- [];
	list<float> income_movmean <- [];
	list<float> maintenance <- [];
	float fish_stock_score;
	float capture_score;
	float profit_score;
	string user;
	string filename;
	string id;
	map<string,int> header;
	list<int> x_list;
	int sliding_window;


	list<float> get_vals(matrix data, string colname){
			return copy_between((data column_at header[colname]),1,data.rows) collect(float(each));
	}
	
	list<float> movmean(list<float> l){
		list<float> res <- [];
		loop i from: 0 to: length(l-1){
			res <- res + mean(copy_between(l,max(0,i-floor(sliding_window/2)),min(length(l),i+floor(sliding_window/2))));
		}
		return res;
	}
	
	action load_csv_file{
		file my_csv_file <- csv_file(filename,",",string, false);				
		matrix<string> data <- matrix<string>(my_csv_file);
		loop j from: 0 to: data.columns -1 step: 1{
			put j key: data[j,0] in: header;
		}				
		fish_stock <- get_vals(data,'fish_stock');
		nb_values <- length(fish_stock);
		nb_trawlers <- get_vals(data,'nb_trawlers');
		capture <- get_vals(data,'capture');
		//write capture;
		capture_movmean <- movmean(capture);
		net_profit <- get_vals(data,'net_profit');
		net_profit_movmean <- movmean(net_profit);
		income <- get_vals(data,'income');
		income_movmean <- movmean(income);
		x_list <- all_indexes_of(list_with(nb_values,1),1);
		maintenance <- get_vals(data,'maintenance_cost');
		fish_stock_score <- mean(last(nb_points, fish_stock));
		capture_score <- mean(last(nb_points, capture_movmean));
		profit_score <- mean(last(nb_points, net_profit_movmean));
	}
	
}


species scenario parent: game{
	
}







experiment Analysis type: gui autorun: true{
	float minimum_cycle_duration <- 0.2#s;
	string indicator;
//	list<string> input_list <-folder(input_path).contents - "refs";
	list<string> sorted_input_list <- (list<string>(folder(input_path).contents) - "refs" - "old") sort_by(each);
	//list<string> sorted_input_list <- input_list sort_by(each);
	list<string> game_list_by_user <- sorted_input_list collect(copy_between(first(regex_matches(each,"_.*_")),1,length(first(regex_matches(each,"_.*_")))-1));
	list<string> game_list_by_type <- sorted_input_list collect(copy_between(last(regex_matches(each,"_[cp]-")),1,2));
	list<string> users <- remove_duplicates(game_list_by_user);
	list<int> aux_int_series <- game_list_by_user collect (game_list_by_user index_of each);
	list<int> int_series <- all_indexes_of(list_with(length(sorted_input_list),1),1);
	list<string> game_list <- int_series collect(game_list_by_user[each]+" ("+(each - aux_int_series[each]+1)+")("+game_list_by_type[each]+")");
	parameter name: "Game" var: current_game_id category: 'display' among: game_list on_change: {cg<-world.current_game();do update_outputs();};
	parameter name: "Ranking" var: indicator category: 'display' init: "fish stock" among: ["fish stock","capture","profit"] on_change: {ask world{do sort_lists;} do update_outputs();};
	output {
//		layout #split tabs: true;
		layout horizontal([vertical([0::100,1::100])::100,vertical([2::100,3::100])::100]) tabs: true;
		
		display stock type: 2d  background: #black toolbar: false{
			chart name: 'Fish stock' type: series x_serie:cg.x_list y2_label: 'trawlers'
				y2_range: {0,20} background: rgb(47,47,47) color: #white  {
				data legend: 'Fish stock' value: cg.fish_stock style: spline color: fish_stock_color marker: false;
				data legend: 'Trawlers' use_second_y_axis: true value: cg.nb_trawlers 
				style: line line_visible: false color: trawler_color marker_size: 0.1;
			}
		}
		display  "fishery results" type: 2d  background: #black toolbar: false{
			chart name: 'Daily results' type: series background: rgb(47,47,47) color: #white  {
				data legend: 'Capture' value: cg.capture_movmean style: spline color:capture_color marker: false;
				data legend: 'Net profit' use_second_y_axis: true value: cg.net_profit_movmean style: spline color:profit_color marker: false;
				data legend: '' use_second_y_axis: true value: list_with(cg.nb_values,0) style: line color:rgb(profit_color,0.2) marker: false;
			}
		}	
		display  Results  type: 2d  background: #black toolbar: false{
			chart name: 'Results' type: series x_tick_line_visible: false x_serie_labels: ranking x_label: ''
			y_range: {0,max_fish_stock} background: rgb(47,47,47) color: #white  {
				data legend: 'Fish stock' style: bar value: fish_stock_score_list  color: fish_stock_color;
				data legend: 'Capture' style: bar value: capture_score_list  color: capture_color;
				data legend: 'Profit' style: bar value: profit_score_list  color: profit_color;				
			}
		}	
		display  Summary type: 2d  background: #black toolbar: false{
			chart name: 'Results' type: box_whisker y_tick_values_visible: false  y_range: {0,max_fish_stock} background: rgb(47,47,47) color: #white  {
				data legend: 'Fish stock' value: whisker_fish_stock  color: fish_stock_color;
				data legend: 'Capture' value: whisker_capture  color: capture_color;
				data legend: 'Profit' value: whisker_profit  color: profit_color;
			}
		}	
	}
}



experiment "Reference scenarios" type: gui autorun: false{
	float minimum_cycle_duration <- 0.2#s;
	string indicator;
	string scn_input_path <- input_path+"refs";
	list<string> sorted_scn_list <- (list<string>(folder(scn_input_path).contents)  - "old") sort_by(each);
	list<string> trawler_list <- sorted_scn_list collect(copy_between(first(regex_matches(each,"f_.*_t")),2,length(first(regex_matches(each,"f_.*_t")))-2));
	list<string> id_list <- sorted_scn_list collect(copy_between(first(regex_matches(each,"s_.*csv")),2,length(first(regex_matches(each,"s_.*csv")))-4));
	list<int> int_series2 <- all_indexes_of(list_with(length(sorted_scn_list),1),1);
	list<string> scn_list <- int_series2 collect(trawler_list[each]+" ships ("+id_list[each]+")");
	

	parameter name: "Scenario" var: current_scenario_id category: 'display' among: scn_list on_change: {cs<-world.current_scenario();do update_outputs();};
	parameter name: "Maintenance cost" var: mc category: 'display' min: 0.0 max:40.0 step: 0.5 on_change: {ask world{do compute_scat_maintenance;}do update_outputs();};
	output {
//		layout #split tabs: true;
		layout horizontal([vertical([0::100,1::100])::100,vertical([2::100,3::100])::100]) tabs: true;
		
		display stock type: 2d  background: #black toolbar: false{
			chart name: 'Fish stock' type: series x_serie:cs.x_list y2_label: 'trawlers'
				y2_range: {0,20} background: rgb(47,47,47) color: #white  {
				data legend: 'Fish stock ' value: cs.fish_stock style: spline color: fish_stock_color marker: false;
			}
		}
		display  "fishery results" type: 2d  background: #black toolbar: false{
			chart name: 'Daily results' type: series background: rgb(47,47,47) color: #white  {
				data legend: 'Capture' value: cs.capture_movmean style: line color:capture_color marker: false;
				data legend: 'Net profit' use_second_y_axis: true value: cs.net_profit_movmean style: line color:profit_color marker: false;
				data legend: '' use_second_y_axis: true value: list_with(cs.nb_values,0) style: line color:rgb(profit_color,0.2) marker: false;
			}
		}	
		display  Results  type: 2d  background: #black toolbar: false{
			chart name: 'Results' type: xy x_tick_line_visible: false x_label: ''
			y_range: {0,scn_max_income} background: rgb(47,47,47) color: #white  {
				data legend: 'Income'  value: scat_income  color: profit_color line_visible: false marker_shape: marker_circle marker_size: 0.1;
				data legend: 'Maintenance cost'  value: scat_maintenance  color: maintenance_color line_visible: true  marker: false;
			}
		}	
		display  Summary type: 2d  background: #black toolbar: false{
//			chart name: 'Results' type: box_whisker y_tick_values_visible: false  y_range: {0,max_fish_stock} background: rgb(47,47,47) color: #white  {
//				data legend: 'Fish stock' value: whisker_fish_stock  color: fish_stock_color;
//				data legend: 'Capture' value: whisker_capture  color: capture_color;
//				data legend: 'Income' value: whisker_income  color: profit_color;
//			}
		}	
	}
}


