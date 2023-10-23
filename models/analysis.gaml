/**
 *  pecheries
 *  Author: Tri Nguyen-Huu
 *  Description: 
 */

model analysis

global {
	string input_path <- "../output/";
	string ref_input_path <- input_path+"refs";
//	list<string> input_list <-folder(input_path).contents - "refs" - "old";
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
	font my_font <- font("Helvetica", 16 , #plain);
	
	rgb fish_stock_color <-  rgb(97,205,114);
	rgb capture_color <- rgb(52,152,219);
	rgb profit_color <- rgb(243,157,49);
	rgb maintenance_color <- rgb(102,57,43);
	rgb trawler_color <- rgb(155,89,182);
	rgb score_color <- rgb(241,196,48);
	
	list<float> capture_movmean <-[];
	list<float> net_profit_movmean <-[];

	int nb_points <- 100;
	
	
	float max_fish_stock;
	float max_capture;
	float max_income;
	list<list<float>> whisker_fish_stock;
	list<list<float>> whisker_capture;
	list<list<float>> whisker_income;
	float scale_capture;
	float scale_income;	

	game cg;
			
	list<float> unsorted_fish_stock_score_list;
	list<float> unsorted_capture_score_list;	
	list<float> unsorted_income_score_list;
	list<float> fish_stock_score_list;
	list<float> capture_score_list;
	list<float> income_score_list;
	
	list<string> ranking;
	
	/* reference scenarios */
	string scn_input_path <- input_path+"refs";
	list<string> scn_list <-folder(scn_input_path).contents  - "old";
//	list<string> sorted_scn_list <- scn_list sort_by(each);
//	list<string> game_list_by_user <- sorted_input_list collect(copy_between(first(regex_matches(each,"_.*_")),1,length(first(regex_matches(each,"_.*_")))-1));
//	list<string> game_list_by_type <- sorted_input_list collect(copy_between(first(regex_matches(each,"_[cp]-")),1,2));
//	list<string> users <- remove_duplicates(game_list_by_user);
//	list<int> aux_int_series <- game_list_by_user collect (game_list_by_user index_of each);
//	list<int> int_series <- all_indexes_of(list_with(length(input_list),1),1);
//	list<string> game_list <- int_series collect(game_list_by_user[each]+

	init {
		// load ref scenarios
		
		
		
		// load games
		
		loop g from: 0 to: length(game_list)-1{
			create game {
				user <- game_list_by_user[g];
				filename <- input_path+sorted_input_list[g];
				id <- game_list[g];
				objective <- game_list_by_type[g];
				file my_csv_file <- csv_file(filename,",",string, false);				
				matrix<string> data <- matrix<string>(my_csv_file);
				loop j from: 0 to: data.columns -1 step: 1{
					put j key: data[j,0] in: header;
				}	
				fish_stock <- get_vals(data,'fish_stock');
				nb_values <- length(fish_stock);
				nb_trawlers <- get_vals(data,'nb_trawlers');
				capture <- get_vals(data,'capture');
				capture_movmean <- movmean(capture);
				net_income <- get_vals(data,'net_profit');
				net_income_movmean <- movmean(net_income);
				x_list <- all_indexes_of(list_with(nb_values,1),1);
				
				fish_stock_score <- mean(last(nb_points, fish_stock));
				capture_score <- mean(last(nb_points, capture_movmean));
				income_score <- mean(last(nb_points, net_income_movmean));
			}
		}
		
		
		max_fish_stock <- max(game accumulate(last(nb_points,each.fish_stock)));
		max_capture <- max(game accumulate(last(nb_points,each.capture_movmean)));
		scale_capture <- max_fish_stock / max_capture;
		max_income <- max(game accumulate(last(nb_points,each.net_income_movmean)));
		scale_income <- max_fish_stock / max_income;
		
		list<float> fish_stock_pool_c <- game where (each.objective="c") accumulate(last(nb_points,each.fish_stock));
		list<float> fish_stock_pool_p <- game where (each.objective="p") accumulate(last(nb_points,each.fish_stock));
		whisker_fish_stock <- [compute_stats(fish_stock_pool_c),compute_stats(fish_stock_pool_p)];
		list<float> capture_pool_c <- game where (each.objective="c") accumulate(last(nb_points,each.capture_movmean));
		capture_pool_c <- capture_pool_c collect (each*scale_capture);
		list<float> capture_pool_p <- game where (each.objective="p") accumulate(last(nb_points,each.capture_movmean));
		capture_pool_p <- capture_pool_p collect (each*scale_capture);
		whisker_capture <- [compute_stats(capture_pool_c),compute_stats(capture_pool_p)];
		list<float> income_pool_c <- game where (each.objective="c") accumulate(last(nb_points,each.net_income_movmean));
		income_pool_c <- income_pool_c collect (each*scale_income);
		list<float> income_pool_p <- game where (each.objective="p") accumulate(last(nb_points,each.net_income_movmean));
		income_pool_p <- income_pool_p collect (each*scale_income);
		whisker_income <- [compute_stats(income_pool_c),compute_stats(income_pool_p)];
	
		// scores
		
		unsorted_fish_stock_score_list <-game collect(each.fish_stock_score);
		unsorted_capture_score_list <-game collect(each.capture_score);
		unsorted_income_score_list <-game collect(each.income_score);
	
		
		do sort_lists;

		cg <-current_game();
		
		
	}
	
	action sort_lists{
		list<float> ref_list;
		switch indicator{
			match "fish stock"{ref_list <- unsorted_fish_stock_score_list;}
			match "capture"{ref_list <- unsorted_capture_score_list;}
			match "income"{ref_list <- unsorted_income_score_list;}
		}
		list<float> sorted_ref_list <- ref_list sort_by each;
		list<int> order_list <- sorted_ref_list collect(index_of(ref_list,each));
		ranking <- order_list accumulate(['','',game_list_by_user[each]+' ('+game_list_by_type[each]+')','','']);
		fish_stock_score_list <- order_list accumulate([0,unsorted_fish_stock_score_list[each], 0, 0,0]);
		capture_score_list <- order_list accumulate([0,0,scale_capture*unsorted_capture_score_list[each],0,0]);
		income_score_list <- order_list accumulate([0,0,0,scale_income*unsorted_income_score_list[each],0]);
	}
	
	game current_game{
		return first(game where (each.id = current_game_id));
	}
	
	
	list<float> compute_stats(list<float> l){
		return [mean(l),median(l), quantile(l sort_by each,0.25),quantile(l sort_by each,0.75),min(l),max(l)];
	}	
	
//	list<string> get_ranks{
//		return ranking;
//	}
	
//	int position(float val, list<float> l){
//		return index_of(l,val);
//	}
}


species game{
	int nb_values;
	string objective;
	list<float> fish_stock <- [];
	list<float> nb_trawlers <- [];
	list<float> capture <- [];
	list<float> net_income <- [];
	list<float> capture_movmean <- [];
	list<float> net_income_movmean <- [];
	float fish_stock_score;
	float capture_score;
	float income_score;
	string user;
	string filename;
	string id;
	map<string,int> header;
	list<int> x_list;


	list<float> get_vals(matrix data, string colname){
			return copy_between((data column_at header[colname]),2,data.rows) collect(float(each));
	}
	
	list<float> movmean(list<float> l){
		list<float> res <- [];
		loop i from: 0 to: length(l-1){
			res <- res + mean(copy_between(l,max(0,i-floor(sliding_window/2)),min(length(l),i+floor(sliding_window/2))));
		}
		return res;
	}
	
}


species references parent: game{
	
}







experiment analysis type: gui autorun: true{
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
	parameter name: "Ranking" var: indicator category: 'display' init: "fish stock" among: ["fish stock","capture","income"] on_change: {ask world{do sort_lists;} do update_outputs();};
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
				data legend: 'Net income' use_second_y_axis: true value: cg.net_income_movmean style: spline color:profit_color marker: false;
				data legend: '' use_second_y_axis: true value: list_with(cg.nb_values,0) style: line color:rgb(profit_color,0.2) marker: false;
			}
		}	
		display  Results  type: 2d  background: #black toolbar: false{
			chart name: 'Results' type: series x_tick_line_visible: false x_serie_labels: ranking x_label: ''
			y_range: {0,max_fish_stock} background: rgb(47,47,47) color: #white  {
				data legend: 'Fish stock' style: bar value: fish_stock_score_list  color: fish_stock_color;
				data legend: 'Capture' style: bar value: capture_score_list  color: capture_color;
				data legend: 'Income' style: bar value: income_score_list  color: profit_color;				
			}
		}	
		display  Summary type: 2d  background: #black toolbar: false{
			chart name: 'Results' type: box_whisker y_tick_values_visible: false  y_range: {0,max_fish_stock} background: rgb(47,47,47) color: #white  {
				data legend: 'Fish stock' value: whisker_fish_stock  color: fish_stock_color;
				data legend: 'Capture' value: whisker_capture  color: capture_color;
				data legend: 'Income' value: whisker_income  color: profit_color;
			}
		}	
	}
}


