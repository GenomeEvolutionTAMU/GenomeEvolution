extends Control

func fix_bars():
	$chromes.fix_bars();

var selected_gap# = null;

var is_ai
var do_yields
var born_on_turn
var died_on_turn

var energy
var resources = [100, 100, 100, 100] #the 4 resource groups
var MIN_ENERGY = 0;
var MAX_ENERGY = 10;
var MAX_ALLOCATED_ENERGY = 10;
var energy_allocations
onready var energy_allocation_panel = get_node("../pnl_energy_allocation");

var max_equality_dist = 10 setget ,get_max_gene_dist;
var reproduct_gene_pool = [] setget ,get_gene_pool;

signal gene_clicked();

signal doing_work(working);

signal updated_gaps(has_gaps, gap_text);
signal justnow_update(text);
signal show_repair_opts(show);
signal show_reprod_opts(show);

signal died(org);

func _ready():
	#initialization done in _ready for restarts
	selected_gap = null;
	
	is_ai = true;
	do_yields = false;
	born_on_turn = -1;
	died_on_turn = -1;

	energy = 5;
	energy_allocations = {};
	
	perform_anims(false);
	for n in Game.ESSENTIAL_CLASSES:
		var code = "";
		for y in range(2):
			# create gene
			var nxt_gelm = load("res://Scenes/SequenceElement.tscn").instance();
			nxt_gelm.setup("gene", n, "essential", code, Game.ESSENTIAL_CLASSES[n]);
			nxt_gelm.set_ess_behavior({n: 1.0});
			if (code == ""):
				code = nxt_gelm.gene_code;
			$chromes.get_cmsm(y).add_elm(nxt_gelm);
	gain_ates(1 + randi() % 6);
	perform_anims(true);
	born_on_turn = Game.round_num;

func get_save():
	return [born_on_turn, energy, $chromes.get_chromes_save()];

func load_from_save(orgn_info):
	perform_anims(false);
	
	gene_selection = [];
	born_on_turn = int(orgn_info[0]);
	energy = int(orgn_info[1]);
	$chromes.load_from_save(orgn_info[2]);
	
	perform_anims(true);

func _input(ev):
	if (ev.is_action_pressed("increment")):
		update_energy(1);
	if (ev.is_action_pressed("decrement")):
		update_energy(-1);
	if (ev.is_action("add_ate") && !ev.is_action_released("add_ate")): # So you can hold it down
		perform_anims(false);
		gain_ates();
		perform_anims(true);

func setup(card_table):
	is_ai = false;
	do_yields = true;
	for type in Game.ESSENTIAL_CLASSES.values():
		#print("type: " + str(type));
		energy_allocations[type] = 0;
	$chromes.setup(card_table);

func perform_anims(perform):
	do_yields = perform;
	$chromes.perform_anims(perform);

func get_card_table():
	return get_parent();

func get_cmsm_pair():
	return $chromes;

func get_max_gene_dist():
	return max_equality_dist;

func gain_ates(count = 1):
	var justnow = "";
	for i in range(count):
		var nxt_te = load("res://Scenes/SequenceElement.tscn").instance();
		nxt_te.setup("gene");
		var pos;
		if (do_yields):
			pos = yield($chromes.insert_ate(nxt_te), "completed");
		else:
			pos = $chromes.insert_ate(nxt_te);
		justnow += "Inserted %s into position %d (%s, %d).\n" % [nxt_te.id, pos, nxt_te.get_parent().get_parent().name, nxt_te.get_index()];
	emit_signal("justnow_update", justnow);

func gain_gaps(count = 1):
	for i in range(count):
		if (do_yields):
			yield($chromes.create_gap(), "completed");
		else:
			$chromes.create_gap();
	if (do_yields):
		return yield($chromes.collapse_gaps(), "completed");
	else:
		return $chromes.collapse_gaps();

func jump_ates():
	var _actives = $chromes.ate_list + [];
	var justnow = "";
	for ate in _actives:
		match (ate.get_ate_jump_roll()):
			0:
				justnow += "%s did not do anything.\n" % ate.id;
			1:
				var old_idx = ate.get_index();
				var old_par = ate.get_parent().get_parent().name;
				var old_id = ate.id;
				if (do_yields):
					yield($chromes.remove_elm(ate), "completed");
				else:
					$chromes.remove_elm(ate);
				justnow += "%s removed from (%s, %d); left a gap.\n" % [old_id, old_par, old_idx];
			2:
				var old_idx = ate.get_index();
				var old_par = ate.get_parent().get_parent().name;
				
				if (do_yields):
					yield($chromes.jump_ate(ate), "completed");
				else:
					$chromes.jump_ate(ate);
				justnow += "%s jumped from (%s, %d) to (%s, %d); left a gap.\n" % \
					[ate.id, old_par, old_idx, ate.get_parent().get_parent().name, ate.get_index()];
			3:
				var copy_ate;
				if (do_yields):
					copy_ate = yield($chromes.copy_ate(ate), "completed");
				else:
					copy_ate = $chromes.copy_ate(ate);
				justnow += "%s copied itself to (%s, %d); left no gap.\n" % \
					[ate.id, copy_ate.get_parent().get_parent().name, copy_ate.get_index()];
	emit_signal("justnow_update", justnow);
	if (do_yields):
		yield($chromes.collapse_gaps(), "completed");
	else:
		$chromes.collapse_gaps();

func get_gene_selection():
	if (gene_selection.size() > 0):
		return gene_selection.back();
	else:
		return null;

func _on_chromes_elm_clicked(elm):
	match (elm.type):
		"break":
			if (elm == selected_gap):
				for r in gene_selection:
					r.disable(true);
				highlight_gap_choices();
				gene_selection = [];
				repair_canceled = true;
				emit_signal("gene_clicked"); # Used to continue the yields
				emit_signal("justnow_update", "");
			else:
				selected_gap = elm;
				upd_repair_opts(elm);
			for g in $chromes.gap_list:
				g.disable(selected_gap != null && g != selected_gap);
		"gene":
			if (elm in gene_selection):
				gene_selection.append(elm); # The selection is accessed via get_gene_selection()
				emit_signal("gene_clicked");

func _on_chromes_elm_mouse_entered(elm):
	pass;

func _on_chromes_elm_mouse_exited(elm):
	pass;

var gene_selection = [];
var roll_storage = [{}, {}]; # When a player selects a gap, its roll is stored. That way reselection scumming doesn't work
# The array number refers to the kind of repair being done (i.e. it should reroll if it is using a different repair option)
# The dictionaries are indexed by the gap object
var repair_type_possible = [false, false, false];
var sel_repair_idx = -1;
var sel_repair_gap = null;

func check_resources(x):
	var repair = ""
	match x:
		0:
			repair = "repair_cd"
		1:
			repair = "repair_cp"
		2:
			repair = "repair_je"
		
	for i in range(4):
		if resources[i]  < costs[repair][i]:
			#print("NOT ENOUGH CASH! STRANGA!")
			return false
	return true

func upd_repair_opts(gap):
	sel_repair_gap = gap;
	
	var cmsm = gap.get_parent();
	var g_idx = gap.get_index();
	if (g_idx == 0 || g_idx == cmsm.get_child_count()-1):
		if (do_yields):
			yield($chromes.close_gap(gap), "completed");
		else:
			$chromes.close_gap(gap);
	else:
		var left_elm = cmsm.get_child(g_idx-1);
		var right_elm = cmsm.get_child(g_idx+1);
		
		repair_type_possible[0] = cmsm.dupe_block_exists(g_idx);
		repair_type_possible[1] = $chromes.get_other_cmsm(cmsm).pair_exists(left_elm, right_elm);
		repair_type_possible[2] = true;
		
		sel_repair_idx = 0;
		while (sel_repair_idx < 2 && !repair_type_possible[sel_repair_idx]):
			sel_repair_idx += 1;
	
	emit_signal("show_repair_opts", true);

func reset_repair_opts():
	repair_type_possible = [false, false, false];
	emit_signal("show_repair_opts", false);

func change_selected_repair(repair_idx):
	sel_repair_idx = repair_idx;

func auto_repair():
	make_repair_choices(sel_repair_gap, sel_repair_idx);

func apply_repair_choice(idx):
	make_repair_choices(sel_repair_gap, idx);

func make_repair_choices(gap, repair_idx):
	emit_signal("show_repair_opts", false);
	var choice_info = {};
	match repair_idx:
		0: # Collapse Duplicates
			var gap_cmsm = gap.get_parent();
			var g_idx = gap.get_index();
			
			var blocks_dict = gap_cmsm.find_dupe_blocks(g_idx);
			
			emit_signal("justnow_update", "Select the leftmost element of the pattern you will collapse.");
			gene_selection = [];
			if (is_ai || blocks_dict.size() == 1):
				choice_info["left"] = gap_cmsm.get_child(blocks_dict.keys()[0]);
			else:
				for k in blocks_dict.keys():
					var gene = gap_cmsm.get_child(k);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				choice_info["left"] = get_gene_selection();
				for g in gene_selection:
					g.disable(true);
			if (choice_info["left"] == null):
				return false;
			var left_idx = choice_info["left"].get_index();
			choice_info["left"].highlight_border(true, true);
			
			emit_signal("justnow_update", "Select the rightmost element of the pattern you will collapse.\n\nThe leftmost element is %s." % choice_info["left"].id);
			gene_selection = [];
			var sel_size_gene = null;
			if (is_ai || blocks_dict[left_idx].size() == 1):
				choice_info["size"] = blocks_dict[left_idx].keys().back();
				sel_size_gene = 0; # Just to make it non-null, fooling it into thinking a selection was made
			else:
				for sz in blocks_dict[left_idx].keys():
					var gene = gap_cmsm.get_child(left_idx + sz - 1);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				sel_size_gene = get_gene_selection();
				for g in gene_selection:
					if (g != choice_info["left"]):
						g.disable(true);
			if (sel_size_gene == null):
				choice_info["left"].highlight_border(false);
				return false;
			else:
				if (!choice_info.has("size")):
					choice_info["size"] = sel_size_gene.get_index() - left_idx + 1;
			
			var pattern_array = [];
			for i in range(0, choice_info["size"]):
				gap_cmsm.get_child(left_idx + i).highlight_border(true, true);
				pattern_array.append(gap_cmsm.get_child(left_idx + i));
			
			emit_signal("justnow_update", "Select the first element of the pattern you will collapse to the right of the gap.\n\nThe pattern is: %s" % Game.pretty_element_name_list(pattern_array));
			gene_selection = [];
			var right_choice_opts = blocks_dict[left_idx][choice_info["size"]];
			if (is_ai || right_choice_opts.size() == 1):
				choice_info["right"] = gap_cmsm.get_child(right_choice_opts[0]);
			else:
				for i in right_choice_opts:
					var gene = gap_cmsm.get_child(i);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				choice_info["right"] = get_gene_selection();
				for g in gene_selection:
					g.disable(true);
			
			for i in range(1, choice_info["size"]):
				gap_cmsm.get_child(left_idx + i).highlight_border(false);
			choice_info["left"].highlight_border(false);
			
			if (choice_info["right"] == null):
				return false;
			emit_signal("justnow_update", "");
		1: # Copy Pattern
			var gap_cmsm = gap.get_parent();
			var g_idx = gap.get_index();
			var left_elm = gap_cmsm.get_child(g_idx-1);
			var right_elm = gap_cmsm.get_child(g_idx+1);
			
			var template_cmsm = $chromes.get_other_cmsm(gap_cmsm);
			
			var pairs_dict = template_cmsm.get_pairs(left_elm, right_elm);
			
			emit_signal("justnow_update", "Select the leftmost element of the pattern you will copy.");
			gene_selection = [];
			if (is_ai || pairs_dict.size() == 1):
				choice_info["left"] = template_cmsm.get_child(pairs_dict.keys()[0]);
			else:
				for k in pairs_dict.keys():
					var gene = template_cmsm.get_child(k);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				choice_info["left"] = get_gene_selection();
				for g in gene_selection:
					g.disable(true);
			if (choice_info["left"] == null):
				return false;
			choice_info["left"].highlight_border(true, true);
			
			emit_signal("justnow_update", "Select the rightmost element of the pattern you will copy.\n\nThe leftmost element is %s." % choice_info["left"].id);
			gene_selection = [];
			var right_idxs = pairs_dict[choice_info["left"].get_index()];
			if (is_ai || right_idxs.size() == 1):
				choice_info["right"] = template_cmsm.get_child(right_idxs[0]);
			else:
				for i in right_idxs:
					var gene = template_cmsm.get_child(i);
					gene_selection.append(gene);
					gene.disable(false);
				yield(self, "gene_clicked");
				choice_info["right"] = get_gene_selection();
				for g in gene_selection:
					g.disable(true);
			if (choice_info["right"] == null):
				choice_info["left"].disable(true);
				return false;
			emit_signal("justnow_update", "");
	repair_gap(gap, repair_idx, choice_info);

var repair_canceled = false;
func repair_gap(gap, repair_idx, choice_info = {}):
	if (repair_type_possible[repair_idx]):
		repair_type_possible = [false, false, false];
		var cmsm = gap.get_parent();
		var g_idx = gap.get_index();
		
		var other_cmsm = $chromes.get_other_cmsm(cmsm);
		
		var left_id = cmsm.get_child(g_idx-1).id;
		var right_id = cmsm.get_child(g_idx+1).id;
		
		repair_canceled = false;
		match (repair_idx):
			0: # Collapse Duplicates
				var left_idx = choice_info["left"].get_index();
				var right_idx = choice_info["right"].get_index();
				choice_info["left"].highlight_border(false);
				choice_info["right"].highlight_border(false);
				
				# Find all the genes to remove before removing them
				var remove_genes = [];
				var left_rem_genes = [];
				var right_rem_genes = [];
				
				var max_collapse_count = right_idx - left_idx - 1;
				var continue_collapse = check_resources(0) && true;
				var ended_due_to = "failure";
				
				for i in range(left_idx, g_idx):
					left_rem_genes.append(cmsm.get_child(i));
				for i in range(g_idx + 1, right_idx + choice_info["size"]):
					right_rem_genes.append(cmsm.get_child(i));
				
				var removing_right = true;
				while (continue_collapse && (remove_genes.size() < max_collapse_count)):
					var chosen_gene;
					if (removing_right):
						chosen_gene = right_rem_genes[0];
						right_rem_genes.remove(0);
					else:
						chosen_gene = left_rem_genes.back();
						left_rem_genes.remove(left_rem_genes.size() - 1);
					remove_genes.append(chosen_gene);
					removing_right = left_rem_genes.size() == 0 || right_rem_genes.size() != 0 && !removing_right;
					
					continue_collapse = check_resources(0) && continue_collapse && Chance.roll_collapse(choice_info["size"], chosen_gene.get_index() - g_idx);
				
				var remove_count = remove_genes.size();
				if (remove_count == max_collapse_count):
					ended_due_to = "completion";
				
				for g in remove_genes:
					if (do_yields):
						yield($chromes.remove_elm(g, false), "completed");
					else:
						$chromes.remove_elm(g, false);
				if (do_yields):
					yield($chromes.close_gap(gap), "completed");
				else:
					$chromes.close_gap(gap);
				emit_signal("justnow_update", "Gap at %s, %d closed: collapsed %d genes and ended due to %s." % [cmsm.get_parent().name, g_idx, remove_count, ended_due_to]);
			
				for times in range(remove_count):
					get_tree().get_root().get_node("Control/WorldMap").player.consume_resources("repair_cd")
			
			1: # Copy Pattern
				choice_info["left"].highlight_border(false);
				if (!roll_storage[0].has(gap)):
					var roll_result = roll_chance("copy_repair");
					#print("roll: ", roll_result);
					roll_storage[0][gap] = roll_chance("copy_repair");
				if !check_resources(1):
					roll_storage[0][gap] = 0
				match (roll_storage[0][gap]):
					0:
						gene_selection = cmsm.get_elms_around_pos(g_idx, true);
						emit_signal("justnow_update", "Trying to copy the pattern from the other chromosome, but 1 gene is lost; choose which.");
						if (is_ai):
							if (gene_selection[0].mode == "ate" || gene_selection[1].mode == "te"):
								gene_selection.append(gene_selection[0]);
							else:
								gene_selection.append(gene_selection[1]);
						else:
							yield(self, "gene_clicked");
						# Yield also ended when a gap is deselected and gene_selection is cleared
						if (!repair_canceled && gene_selection.size() > 0):
							for r in gene_selection:
								r.disable(true);
							
							var gene = get_gene_selection();
							var g_id = gene.id;
							emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome, but a %s gene was lost." % [cmsm.get_parent().name, g_idx, left_id, right_id, g_id]);
							if (do_yields):
								yield($chromes.remove_elm(gene, false), "completed");
								yield($chromes.close_gap(gap), "completed");
							else:
								$chromes.remove_elm(gene, false);
								$chromes.close_gap(gap);
					1:
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome without complications." % [cmsm.get_parent().name, g_idx, left_id, right_id]);
						if (do_yields):
							yield($chromes.close_gap(gap), "completed");
						else:
							$chromes.close_gap(gap);
					2:
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome along with intervening genes." % [cmsm.get_parent().name, g_idx, left_id, right_id]);
						if (do_yields):
							for i in range(choice_info["left"].get_index()+1, choice_info["right"].get_index()):
								var copy_elm = Game.copy_elm(other_cmsm.get_child(i));
								yield(cmsm.add_elm(copy_elm, gap.get_index()), "completed");
							yield($chromes.close_gap(gap), "completed");
						else:
							for i in range(choice_info["left"].get_index()+1, choice_info["right"].get_index()):
								var copy_elm = Game.copy_elm(other_cmsm.get_child(i));
								cmsm.add_elm(copy_elm, gap.get_index());
							$chromes.close_gap(gap);
					3:
						var copy_elm;
						if (randi()%2):
							copy_elm = cmsm.get_child(g_idx-1);
						else:
							copy_elm = cmsm.get_child(g_idx+1);
						
						emit_signal("justnow_update", "Gap at %s, %d closed: copied the pattern (%s, %s) from the other chromosome, but a %s gene was copied." % [cmsm.get_parent().name, g_idx, left_id, right_id, copy_elm.id]);
						if (do_yields):
							yield($chromes.dupe_elm(copy_elm), "completed");
							yield($chromes.close_gap(gap), "completed");
						else:
							$chromes.dupe_elm(copy_elm);
							$chromes.close_gap(gap);
							
				get_tree().get_root().get_node("Control/WorldMap").player.consume_resources("repair_cp")
				#print("repair copy pattern");
			2: # Join Ends
				if (!roll_storage[1].has(gap)):
					roll_storage[1][gap] = roll_chance("join_ends");
				if !check_resources(2):
					roll_storage[1][gap] = 0
				match (roll_storage[1][gap]):
					0:
						gene_selection = cmsm.get_elms_around_pos(g_idx, true);
						emit_signal("justnow_update", "Joining ends as a last-ditch effort, but must lose a gene; choose which.");
						if (is_ai):
							if (gene_selection[0].mode == "ate" || gene_selection[1].mode == "te"):
								gene_selection.append(gene_selection[0]);
							else:
								gene_selection.append(gene_selection[1]);
						else:
							yield(self, "gene_clicked");
						# Yield also ended when a gap is deselected and gene_selection is cleared
						if (!repair_canceled && gene_selection.size() > 0):
							for r in gene_selection:
								r.disable(true);
							
							var gene = get_gene_selection();
							var g_id = gene.id; # Saved here cuz it'll free the gene in a bit
							if (do_yields):
								yield($chromes.remove_elm(gene, false), "completed");
								yield($chromes.close_gap(gap), "completed");
							else:
								$chromes.remove_elm(gene, false);
								$chromes.close_gap(gap);
							emit_signal("justnow_update", "Joined ends for the gap at %s, %d; lost a %s gene in the repair." % [cmsm.get_parent().name, g_idx, g_id]);
					1:
						if (do_yields):
							yield($chromes.close_gap(gap), "completed");
						else:
							$chromes.close_gap(gap);
						emit_signal("justnow_update", "Joined ends for the gap at %s, %d without complications." % [cmsm.get_parent().name, g_idx]);
					2:
						var copy_elm;
						if (randi()%2):
							copy_elm = cmsm.get_child(g_idx-1);
						else:
							copy_elm = cmsm.get_child(g_idx+1);
						if (do_yields):
							yield($chromes.dupe_elm(copy_elm), "completed");
							yield($chromes.close_gap(gap), "completed");
						else:
							$chromes.dupe_elm(copy_elm);
							$chromes.close_gap(gap)
						emit_signal("justnow_update", "Joined ends for the gap at %s, %d; duplicated a %s gene in the repair." % [cmsm.get_parent().name, g_idx, copy_elm.id]);
				
				get_tree().get_root().get_node("Control/WorldMap").player.consume_resources("repair_je")
				#print("repair join ends")
		
		gene_selection.erase(gap);
		highlight_gap_choices();

func highlight_gap_choices():
	reset_repair_opts();
	selected_gap = null;
	$chromes.highlight_gaps();
	var gap_text = "";
	for g in $chromes.gap_list:
		gap_text += "Chromosome %s needs a repair at %d.\n" % [g.get_parent().get_parent().name, g.get_index()];
	emit_signal("updated_gaps", $chromes.gap_list.size() > 0, gap_text);
	if (is_ai && $chromes.gap_list.size() > 0):
		upd_repair_opts($chromes.gap_list[0]);
		auto_repair();

func get_gene_pool():
	return reproduct_gene_pool;

func can_meiosis():
	return get_gene_pool().size() > 0;

func add_to_gene_pool(chrome_pair = null):
	if (chrome_pair == null):
		chrome_pair = $chromes;
	get_gene_pool().append($chromes.get_chromes_save());

func get_random_gene_from_pool():
	return get_gene_pool()[randi() % get_gene_pool().size()][randi() % 2];

func set_cmsm_from_pool(cmsm, pool_info = ""):
	perform_anims(false);
	if (typeof(pool_info) == TYPE_STRING && pool_info == ""):
		pool_info = get_random_gene_from_pool();
	cmsm.load_from_save(pool_info);
	perform_anims(true);

func get_behavior_profile():
	var behavior_profile = {};
	for g in get_cmsm_pair().get_all_genes():
		var g_behave = g.get_ess_behavior();
		for k in g_behave:
			if (behavior_profile.has(k)):
				behavior_profile[k] += g_behave[k];
			else:
				behavior_profile[k] = g_behave[k];
	return behavior_profile;

func roll_chance(type):
	return Chance.roll_chance_type(type, get_behavior_profile());

func evolve_candidates(candids):
	if (candids.size() > 0):
		var justnow = "";
		for e in candids:
			#if (($chromes.get_cmsm(0).find_all_genes(e.id).size() + $chromes.get_cmsm(1).find_all_genes(e.id).size()) > 2):
			match (roll_chance("evolve")):
				0:
					justnow += "%s did not evolve.\n" % e.id;
					e.evolve(0);
				1:
					justnow += "%s received a fatal mutation and has become a pseudogene.\n" % e.id;
					e.evolve(1);
				2:
					justnow += "%s received a major upgrade of +1.0\n" % e.id;
					e.evolve(2);
				3:
					justnow += "%s received a major downgrade of -1.0\n" % e.id;
					e.evolve(3);
				4:
					justnow += "%s received a minor upgrade of +0.1\n" % e.id;
					e.evolve(4);
				5:
					justnow += "%s received a minor downgrade of -0.1\n" % e.id;
					e.evolve(5);
		emit_signal("justnow_update", justnow);
	else:
		emit_signal("justnow_update", "No essential genes were duplicated, so no genes evolve.");

var recombo_chance = 1;
const RECOMBO_COMPOUND = 0.85;
var cont_recombo = true
var recom_justnow = ""
func recombination():
	if (is_ai):
		gene_selection = [];
	else:
		# For some reason, this func bugs out when picking from the first cmsm (see comment at get_other_cmsm below)
		gene_selection = $chromes.highlight_common_genes(false, true);
		yield(self, "gene_clicked");
		# Because this step is optional, by the time a gene is clicked, it might be a different turn
		if (Game.get_turn_type() == Game.TURN_TYPES.Recombination):
			emit_signal("doing_work", true);
			var first_elm = get_gene_selection();
			for g in gene_selection:
				g.disable(true);
			
			# When first_elm lies on the top cmsm, this line breaks and only highlights genes on the top cmsm
			gene_selection = $chromes.highlight_this_gene($chromes.get_other_cmsm(first_elm.get_parent()), first_elm);
			yield(self, "gene_clicked");
			var scnd_elm = get_gene_selection();
			for g in gene_selection:
				g.disable(true);
			
			if (randf() <= recombo_chance):
				perform_anims(false);
				var idxs;
				if (do_yields):
					idxs = yield($chromes.recombine(first_elm, scnd_elm), "completed");
				else:
					idxs = $chromes.recombine(first_elm, scnd_elm);
				recombo_chance *= RECOMBO_COMPOUND;
				perform_anims(true);
				emit_signal("justnow_update", "Recombination success: swapped %s genes at positions %d and %d.\nNext recombination has a %d%% chance of success." % ([first_elm.id] + idxs + [100*recombo_chance]));
				emit_signal("doing_work", false);
				if (do_yields):
					yield(recombination(), "completed");
				else:
					recombination();
			else:
				emit_signal("justnow_update", "Recombination failed.");
				cont_recombo = false
				emit_signal("doing_work", false);

func replicate(idx):
	var rep_type = "some unknown freaky deaky shiznaz";
	match idx:
		0: # Mitosis
			rep_type = "mitosis";
			add_to_gene_pool();
		1: # Meiosis
			rep_type = "meiosis";
			emit_signal("justnow_update", "Choose which chromosome to keep.");
			var keep_cmsm = null;
			if (is_ai):
				keep_cmsm = $chromes.get_cmsm(randi() % 2);
			else:
				gene_selection = $chromes.highlight_all_genes();
				yield(self, "gene_clicked");
				keep_cmsm = get_gene_selection().get_cmsm();
				for g in gene_selection:
					g.disable(true);
			
			var new_cmsm = get_random_gene_from_pool();
			add_to_gene_pool();
			set_cmsm_from_pool($chromes.get_other_cmsm(keep_cmsm), new_cmsm);
	emit_signal("doing_work", false);
	emit_signal("justnow_update", "Reproduced by %s." % rep_type);

func get_missing_ess_classes():
	var b_prof = get_behavior_profile();
	var missing = [];
	for k in Game.ESSENTIAL_CLASSES:
		if (!b_prof.has(k) || b_prof[k] == 0):
			missing.append(k);
	return missing;

func adv_turn(round_num, turn_idx):
	if (died_on_turn == -1):
		match (Game.get_turn_type()):
			Game.TURN_TYPES.NewTEs:
				emit_signal("justnow_update", "");
				if (do_yields):
					yield(gain_ates(1), "completed");
				else:
					gain_ates(1);
			Game.TURN_TYPES.TEJump:
				emit_signal("justnow_update", "");
				if (do_yields):
					yield(jump_ates(), "completed");
				else:
					jump_ates();
			Game.TURN_TYPES.RepairBreaks:
				roll_storage = [{}, {}];
				var num_gaps = $chromes.gap_list.size();
				if (num_gaps == 0):
					emit_signal("justnow_update", "No gaps present.");
				elif (num_gaps == 1):
					emit_signal("justnow_update", "1 gap needs repair.");
				else:
					emit_signal("justnow_update", "%d gaps need repair." % num_gaps);
				highlight_gap_choices();
			Game.TURN_TYPES.EnvironmentalDamage:
				var rand;
				if (do_yields):
					rand = yield(gain_gaps(1+randi()%3), "completed");
				else:
					rand = gain_gaps(1+randi()%3);
				var plrl = "s";
				if (rand == 1):
					plrl = "";
				emit_signal("justnow_update", "%d gap%s appeared due to environmental damage." % [rand, plrl]);
			Game.TURN_TYPES.Recombination:
				emit_signal("justnow_update", "If you want, you can select a gene that is common to both chromosomes. Those genes and every gene to their right swap chromosomes.\nThis recombination has a %d%% chance of success." % (100*recombo_chance));
				if (do_yields):
					yield(recombination(), "completed");
				else:
					recombination();
			Game.TURN_TYPES.Evolve:
				emit_signal("justnow_update", "");
				var _candidates = []
				for cmsm in $chromes.get_cmsms():
					for i in cmsm.get_child_count():
						_candidates.append(cmsm.get_child(i))
				#print(_candidates.size())
				evolve_candidates(_candidates);
			Game.TURN_TYPES.CheckViability:
				var missing = get_missing_ess_classes();
				if (missing.size() == 0):
					emit_signal("justnow_update", "You're still kicking!");
					cont_recombo = true
					recombo_chance = 1
				else:
					died_on_turn = Game.round_num;
					#$lbl_dead.text = "Died after %d rounds." % (died_on_turn - born_on_turn);
					#$lbl_dead.visible = true;
					emit_signal("justnow_update", "You're missing essential behavior: %s" % PoolStringArray(missing).join(", "));
					emit_signal("died", self);
			Game.TURN_TYPES.Replication:
				emit_signal("justnow_update", "Choose replication method.");
				emit_signal("doing_work", true);
				emit_signal("show_reprod_opts", true);

func is_dead():
	return died_on_turn > -1;

func update_energy(amount):
	energy += amount;
	if (energy < MIN_ENERGY):
		energy = MIN_ENERGY;
	elif (energy > MAX_ENERGY):
		energy = MAX_ENERGY;
	energy_allocation_panel.update_energy(energy);

func update_energy_allocation(type, amount):
	#print(type);
	if (energy - amount < MIN_ENERGY || energy - amount > MAX_ENERGY):
		return;
	if (energy_allocations[type] + amount < 0 || energy_allocations[type] + amount > MAX_ALLOCATED_ENERGY):
		return;
	energy -= amount;
	energy_allocations[type] += amount;
	energy_allocation_panel.update_energy_allocation(type, energy_allocations[type]);
	energy_allocation_panel.update_energy(energy);

var costs = {
	"repair_cd" : [0, 1, 5, 0],
	"repair_cp" : [0, 2, 2, 8],
	"repair_je" : [0, 5, 1, 0],
	"move" : [10, 0, 0, 0]
}
const BEHAVIOR_TO_COST_MULT = {
	"Locomotion": {
		"move": -0.05
	}
}
func use_resources(action):
	var cost_mult = 1.0;
	var bprof = get_behavior_profile();
	for k in bprof:
		if (BEHAVIOR_TO_COST_MULT.has(k) && BEHAVIOR_TO_COST_MULT[k].has(action)):
			cost_mult += BEHAVIOR_TO_COST_MULT[k][action] * bprof[k];
	cost_mult = max(0.05, cost_mult);
	for i in range(4):
		resources[i] = max(0, resources[i] - (costs[action][i] * cost_mult * Game.resource_mult))


