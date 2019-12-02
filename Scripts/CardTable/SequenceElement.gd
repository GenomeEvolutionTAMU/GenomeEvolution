extends TextureButton


var type; #holds break or gene
var mode; #holds essential, ate, or pseudogene
var id;   #holds unique identifier

var ess_class = null; #holds essential gene class
var ess_behavior = {
	"Replication": 0.0,
	"Locomotion": 0.0,
	"Manipulation": 0.0,
	"Sensing": 0.0,
	"Construction": 0.0,
	"Deconstruction": 0.0
};


var specialization = {};
var spec_types = {
	"resource": {"specs": Game.resource_groups.keys().duplicate(), "subs": range(4)},
	"terrain": {"specs": ["biomes"], "subs": Game.biomes.keys().duplicate()},
};
var behavior_to_spec_type = {
	"Manipulation": "resource",
	"Sensing": "resource",
	"Construction": "resource",
	"Deconstruction": "resource",
	"Locomotion": "terrain",
};

var ate_activity = 0.0;
var ate_personality = {};

const CODE_LENGTH = 7;
var gene_code = "";

var DEFAULT_SIZE = 200;
var MIN_SIZE = 125;
var MAGNIFICATION_FACTOR = 1.5;
var MAGNIFICATION_DROPOFF = 0.9;
var current_size;

signal elm_clicked(elm);
signal elm_mouse_entered(elm);
signal elm_mouse_exited(elm);

func _ready():
	current_size = DEFAULT_SIZE;
	Tooltips.setup_delayed_tooltip(self);
	for k in ess_behavior:
		get_node("Indic%s" % k).ttip_data = [k, "base"];

func setup(_type, _id = "", _mode = "ate", _code = "", _ess_class = -1):
	id = _id;
	type = _type;
	mode = _mode;
	if (_code == ""):
		randomize_code();
	else:
		gene_code = _code;
	var tex;
	if (type == "gene"):
		match (mode):
			"essential":
				# This will happen for saveloads
				if (typeof(_ess_class) != TYPE_INT):
					_ess_class = int(_ess_class);
				
				if (_ess_class in Game.ESSENTIAL_CLASSES.values()):
					ess_class = _ess_class;
					tex = Game.ess_textures[_ess_class];
				else:
					print("!! Trying to put ", name, " (", _type, ", ", _id, ") in non-existent eclass (", _ess_class, ")");
					print("Here are the valid values: ", Game.ESSENTIAL_CLASSES.values());
			"ate":
				ate_activity = 1.0;
				if (id == ""):
					ate_personality = Game.get_random_ate_personality();
					id = ate_personality["title"];
				else:
					ate_personality = Game.get_ate_personality_by_name(id);
				tex = ate_personality["art"];
			"pseudo":
				var ate_personality = Game.get_ate_personality_by_name(id);
				if (ate_personality == null):
					tex = Game.ess_textures[Game.ESSENTIAL_CLASSES[id]];
				else:
					tex = ate_personality["art"];
		#Sets the hover tooltip based on the mode and _ess_class
	else:
		tex = Game.sqelm_textures[_type];
		gene_code = "";
		
	upd_display();
	
	texture_normal = tex;
	texture_pressed = tex;
	texture_disabled = tex;
	
	disable(true);

func setup_copy(ref_elm):
	id = ref_elm.id;
	type = ref_elm.type;
	mode = ref_elm.mode;
	gene_code = ref_elm.gene_code;
	var tex = ref_elm.texture_normal;
	if (ref_elm.type == "gene"):
		match (ref_elm.mode):
			"essential":
				ess_class = ref_elm.ess_class;
				ess_behavior = ref_elm.ess_behavior;
				specialization = ref_elm.specialization;
			"ate":
				ate_activity = ref_elm.ate_activity;
				ate_personality = ref_elm.ate_personality;
				id = ate_personality["title"];
				tex = ate_personality["art"];
	upd_display();
	
	texture_normal = tex;
	texture_pressed = tex;
	texture_disabled = tex;
	
	disable(true);

func set_ess_behavior(dict):
	for k in dict:
		if (k == "ate"):
			ate_activity = dict[k];
		else:
			ess_behavior[k] = dict[k];
		upd_behavior_disp(k);

func get_ess_behavior():
	var d = {};
	for k in ess_behavior:
		if (ess_behavior[k] > 0):
			d[k] = ess_behavior[k];
	if is_ate():
		d["ate"] = ate_activity;
	return d;

func get_specialization():
	var d = {};
	if !is_ate():
		for r in specialization:
			for t in specialization[r]:
				var spec_val = get_specific_specialization(r, t);
				if (spec_val != 1.0):
					if !(r in d):
						d[r] = {};
					d[r][t] = spec_val;
	return d;

func get_specific_specialization(spec, sub_idx):
	if !(spec in specialization) || !(sub_idx in specialization[spec]):
		return 1.0;
	return specialization[spec][sub_idx];

func set_specific_specialization(spec, sub_idx, val):
	if !(spec in specialization):
		specialization[spec] = {};
	specialization[spec][sub_idx] = val;

func modify_specific_specialization(spec, sub_idx, dval):
	set_specific_specialization(spec, sub_idx, dval + get_specific_specialization(spec, sub_idx));

func evolve_spec(behavior, ev_amt):
	if (behavior in behavior_to_spec_type):
		var spec_info = spec_types[behavior_to_spec_type[behavior]];
		
		var spec = spec_info["specs"][randi() % spec_info["specs"].size()];
		var sub_idx = spec_info["subs"][randi() % spec_info["subs"].size()];
		
		modify_specific_specialization(spec, sub_idx, ev_amt);

func get_random_code():
	var _code = "";
	for i in range(CODE_LENGTH):
		_code += Game.get_code_char(randi() % Game.code_elements.size());
	return _code;

func randomize_code():
	gene_code = get_random_code();

func modify_code(spaces = 1, min_mag = 1, allow_negative = false):
	for i in range(spaces):
		var _idx = randi() % gene_code.length();
		var _change = min_mag;
		if (allow_negative && randi() % 2):
			_change *= -1;
		var _char = Game.get_code_num(gene_code[_idx]);
		
		_char = (_char + _change) % Game.code_elements.size();
		gene_code[_idx] = Game.get_code_char(_char);

func get_code_elm_dist(elm0, elm1):
	var _dist = abs(Game.get_code_num(elm0) - Game.get_code_num(elm1));
	return min(_dist, Game.code_elements.size() - _dist);

func get_code_dist(other_cd, my_cd = ""):
	if (my_cd == ""):
		my_cd = gene_code;
	
	var _dist = 0;
	for i in range(other_cd.length()):
		var cd = get_code_elm_dist(other_cd[i], my_cd[i]);
		_dist += cd;
	
	return _dist;

func can_compare_elm(other_elm):
	return gene_code.length() > 0 && other_elm.gene_code.length() > 0 && other_elm.type == type;

func get_gene_distance(other_elm):
	return get_code_dist(other_elm.gene_code, gene_code);

func is_equal(other_elm, max_dist = -1):
	if (max_dist < 0):
		return can_compare_elm(other_elm);
	else:
		return can_compare_elm(other_elm) && get_gene_distance(other_elm) <= max_dist;

func evolve_current_behavior(amt):
	match mode:
		"essential":
			if (ess_behavior.values().max() > 0):
				var behave_key = ess_behavior.keys()[Chance.roll_chances(ess_behavior.values())];
				evolve_spec(behave_key, amt);
				ess_behavior[behave_key] = max(0, ess_behavior[behave_key] + amt);
		"ate":
			ate_activity += amt;
	check_for_death();

const GAIN_AMT = 0.4;
const ATE_LOSS_AMT = 2.0;

func get_gain_chance(num_missing_behaviors, num_max_behaviors):
	var num_current_behaves = num_max_behaviors - num_missing_behaviors;
	var log_b10 = log(2.25 * num_current_behaves / float(num_max_behaviors)) / log(10);
	# log() is actually ln
	return -1.25 * log_b10 + .25;

func evolve_new_behavior(gain):
	match mode:
		"essential":
			var behave_key = "";
			if (gain):
				var key_candids = [];
				for k in ess_behavior:
					if (ess_behavior[k] == 0):
						key_candids.append(k);
				
				if (randf() <= get_gain_chance(key_candids.size(), ess_behavior.size())):
					behave_key = key_candids[randi() % key_candids.size()];
				else:
					behave_key = ess_behavior.keys()[Chance.roll_chances(ess_behavior.values())];
			else:
				behave_key = ess_behavior.keys()[Chance.roll_chances(ess_behavior.values())];
			
			if (gain):
				evolve_spec(behave_key, GAIN_AMT);
				if (ess_behavior.has(behave_key)):
					ess_behavior[behave_key] += GAIN_AMT;
				else:
					ess_behavior[behave_key] = GAIN_AMT;
			else:
				evolve_spec(behave_key, -ess_behavior[behave_key]);
				ess_behavior[behave_key] = 0.0;
		"ate":
			if (gain):
				ate_activity += GAIN_AMT;
			else:
				ate_activity -= ATE_LOSS_AMT;
	check_for_death();

func check_for_death():
	match mode:
		"essential":
			if (ess_behavior.values().max() == 0):
				kill_elm();
		"ate":
			if (ate_activity <= 0):
				kill_elm();

func kill_elm():
	mode = "pseudo";
	ess_class = null;
	
	var cm_pair = get_cmsm().get_cmsm_pair();
	if (self in cm_pair.ate_list):
		cm_pair.ate_list.erase(self);
	
	for k in ess_behavior:
		ess_behavior[k] = 0;
		upd_behavior_disp(k);
	ate_activity = 0;

func evolve_specific(major, up):
	var code_change = 2;
	
	var up_sign = -1;
	if (up):
		up_sign = 1;
	
	if (major):
		evolve_new_behavior(up);
	else:
		code_change = 1;
		evolve_current_behavior(0.1 * up_sign);
	
	modify_code(code_change, code_change * up_sign);
	
	upd_display();
	get_cmsm().emit_signal("cmsm_changed");

func evolve(ndx, good = true):
	if (type == "gene"):
		match ndx:
			1: # Gene death
				modify_code(5, -5);
				kill_elm();
			2: # Major Upgrade
				evolve_specific(true, true);
			3: # Major Downgrade
				evolve_specific(true, false);
			4: # Minor Upgrade
				evolve_specific(false, true);
			5: # Minor Downgrade
				evolve_specific(false, false);

func get_tooltip_data():
	match type:
		"gene":
			var key = "";
			match(mode):
				"essential":
					key = Game.ESSENTIAL_CLASSES.keys()[ess_class];
				"ate":
					key = "Transposon";
				"pseudo":
					key = "Pseudogene";
			return ["set_gene_ttip", [key]];
		"break":
			return ["This will need to be repaired before more actions can be taken.", "Break"];

func upd_behavior_disp(behavior = ""):
	match mode:
		"essential", "pseudo":
			if (behavior != ""):
				get_node("Indic" + behavior).set_value(ess_behavior[behavior]);
			else:
				for b in ess_behavior:
					get_node("Indic" + b).set_value(ess_behavior[b]);
			continue;
		"ate", "pseudo":
			get_node("IndicATE").set_value(ate_activity);

func upd_display():
	$DBGLBL.text = gene_code;
	if (type != "break"):
		$version/version_lbl.text = "B"
		$version.hide()
	else:
		$version.show()
	$lbl.text = id;
	match(type):
		"gene":
			toggle_mode = false;
			$BorderRect.modulate = toggle_rect_clr[false];
			var start_mode = mode;
			match (mode):
				"ate":
					self_modulate = Color(.8, .15, 0);
				"ste":
					self_modulate = Color(.55, 0, 0);
				"essential":
					$lbl.visible = false;
					$version/version_lbl.text = "";
				"pseudo":
					$lbl.visible = false;
					#$lbl.text += " [p]";
					self_modulate = Color(.5, .5, 0);
			upd_behavior_disp();
			
		#NOTE: This is broken.  It enables you to click on a break in the
		#chromosome, select collapse/copy/join, see the behavior, then
		#deselect it
		
		# That's actually expected behavior, but it does crash sometimes
		"break":
			$version.hide()
			toggle_mode = true;
			continue;
		_:
			self_modulate = Color(1, 1, 1);

func get_cmsm():
	return get_parent();

func get_position_display():
	return [get_cmsm().get_disp_control().get_index() + 1, get_index() + 1];

func is_gap():
	return type == "break";

func is_ate():
	return type == "gene" && mode == "ate";

func silence_ate():
	if is_ate():
		mode = "ste";
		upd_display();

func disable(dis):
	disabled = dis;
	#$GrayFilter.visible = dis; #Commented out in order to remove the gray box around the elements in the chomosome
	highlight_border(!dis);

func highlight_border(on, special_color = false):
	$BorderRect.visible = on;
	$BorderRect.modulate = toggle_rect_clr[special_color];

func is_highlighted():
	return $BorderRect.visible;

func get_ate_jump_roll():
	var mods = [0.75 / ate_activity];
	for i in range(3):
		mods.append(ate_activity);
	return Chance.roll_chances(ate_personality["roll"], mods);

func get_active_behavior(jump): #if jump==false, get the copy range
	var grab_dict = {};
	if (jump):
		# If jumping and j_range is present, use that
		if (ate_personality.has("j_range")):
			grab_dict = ate_personality["j_range"];
	else:
		# If copying and c_range is present, use that
		if (ate_personality.has("c_range")):
			grab_dict = ate_personality["c_range"];
	
	if (grab_dict.size() == 0):
		# If we haven't found one to use, use range
		if (ate_personality.has("range")):
			grab_dict = ate_personality["range"];
		else:
			# If none of the ranges are present, use the default behavior
			return Game.DEFAULT_ATE_RANGE_BEHAVIOR;
	var idx = 0;
	var roll = randf();
	# Roll a random number, then find the behavior that matches the probability
	while (idx < grab_dict.size() && roll >= grab_dict.keys()[idx]):
		idx += 1;
	
	# Once found, fill in the implied default behavior
	grab_dict = grab_dict[grab_dict.keys()[idx]];
	if (grab_dict.size() < Game.DEFAULT_ATE_RANGE_BEHAVIOR.size()):
		for k in Game.DEFAULT_ATE_RANGE_BEHAVIOR:
			if (!grab_dict.has(k)):
				grab_dict[k] = Game.DEFAULT_ATE_RANGE_BEHAVIOR[k];
	return grab_dict;

var toggle_rect_clr = {true: Color(0.5, 0.5, 0), false: Color(1, 1, 1)};
func _on_SeqElm_toggled(on):
	$BorderRect.modulate = toggle_rect_clr[on];

func set_size(size = null):
	if (size == null):
		size = DEFAULT_SIZE;
	elif (size < MIN_SIZE):
		size = MIN_SIZE;
	elif (size > DEFAULT_SIZE):
		size = DEFAULT_SIZE;
	rect_min_size = Vector2(size, size);
	$BorderRect.rect_min_size = Vector2(size, size);
	$GrayFilter.rect_min_size = Vector2(size, size);
	rect_size = Vector2(size, size);
	$BorderRect.rect_size = Vector2(size, size);
	$GrayFilter.rect_size = Vector2(size, size);
	current_size = size;
	
	var scale = size / float(DEFAULT_SIZE);
	for k in ess_behavior:
		get_node("Indic" + k).rescale(scale);
	

func _on_SeqElm_pressed():
	emit_signal("elm_clicked", self);

func _on_SeqElm_mouse_entered():
	get_cmsm().magnify_elm(self);
	if type != "break" && $version/version_lbl.text == "B":
		$version.show()
	emit_signal("elm_mouse_entered", self);

func _on_SeqElm_mouse_exited():
	get_cmsm().demagnify_elm(self);
	if $version/version_lbl.text == "B":
		$version.hide()
	emit_signal("elm_mouse_exited", self);
