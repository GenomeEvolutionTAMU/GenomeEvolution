extends CanvasLayer

func _ready():
	TooltipPanel.visible = false;

#	.d88888b    dP            oo                       a88888b.                              dP                                dP   oo                   
#	88.    "'   88                                    d8'   `88                              88                                88                        
#	`Y88888b. d8888P 88d888b. dP 88d888b. .d8888b.    88        .d8888b. 88d888b. .d8888b. d8888P 88d888b. dP    dP .d8888b. d8888P dP .d8888b. 88d888b. 
#	      `8b   88   88'  `88 88 88'  `88 88'  `88    88        88'  `88 88'  `88 Y8ooooo.   88   88'  `88 88    88 88'  `""   88   88 88'  `88 88'  `88 
#	d8'   .8P   88   88       88 88    88 88.  .88    Y8.   .88 88.  .88 88    88       88   88   88       88.  .88 88.  ...   88   88 88.  .88 88    88 
#	 Y88888P    dP   dP       dP dP    dP `8888P88     Y88888P' `88888P' dP    dP `88888P'   dP   dP       `88888P' `88888P'   dP   dP `88888P' dP    dP 
#	                                           .88                                                                                                       
#	                                       d8888P                                                                                                        

const REPAIR_TTIPS = {
	"collapse_dupes": "If the genes to the left and the right of the gap are the same, the break can be repaired by discarding one of the duplicates.",
	"copy_pattern": "If both ends of the gap can be matched to an intact pattern on the other chromosome, you can attempt to copy the pattern. There is a decent chance of complications (duplicates, discarding, etc.).",
	"join_ends": "You can always just attempt to join ends without a template. There is a high chance for complications (duplications, discarding, etc.)."
};

const REPLICATE_TTIPS = {
	"mitosis": "If the genes to the left and the right of the gap are the same, the break can be repaired by discarding one of the duplicates.",
	"meiosis": "If both ends of the gap can be matched to an intact pattern on the other chromosome, you can attempt to copy the pattern. There is a decent chance of complications (duplicates, discarding, etc.).",
	"skip": "You can always choose to not replicate and continue with no offspring."
};

const GENE_NAMES = {
	"Replication": "Replication",
	"Locomotion": "Movement",
	"Manipulation": "Transporter",
	"Sensing": "Sensing",
	"Construction": "Assembly",
	"Deconstruction": "Disassembly",
	"Helper": "Helper",
	"Component": "Component",
	
	"Transposon": "Transposable Element",
	"Pseudogene": "Psuedogene",
	"Blank": "Blank"
};
const BASE_TTIPS = {
	"Replication": "%s genes encode proteins needed to copy (replicate) your genome or repair it when it is broken.",
	"Locomotion": "%s genes encode proteins needed to move your organism around in the world.",
	"Manipulation": "%s genes encode proteins ",
	"Sensing": "%s genes encode proteins that sense resources or dangers either in the world or inside your organism. ",
	"Construction": "%s genes encode proteins required to build all your other proteins or store resources.",
	"Deconstruction": "%s genes encode proteins required to break down complex resources into simpler, usable ones.",
	"Helper": "%s genes encode proteins that help another gene do its job more effectively.",
	"Component": "%s genes encode proteins that are used as building blocks for your organism.",
	
	"Transposon": "%ss are genetic parasites that encode proteins that help them to replicate.",
	"Pseudogene": "%ss are broken genes; they do not encode proteins anymore.",
	"Blank": "%s genes do not encode proteins, but can potentially evolve to encode new proteins."
};

const COMPARE_TTIPS = {
	"up": "This behavior is improved compared to the copied chromosome.",
	"down": "This behavior is worse compared to the copied chromosome.",
	"norm": "This behavior is the same as the copied chromosome.",
	"dead": "This behavior is missing from this chromosome.",
	"base": ""
};

const WORLDMAP_UI_TTIPS = {
	"acquire": "Acquire as many resources as you can on your current tile for %s energy.",
	"title": "Exit to the title screen.",
	"end_turn": "End the current map turn and proceed to the chromosome screen.",
	"energy": "Energy: %.2f",
	"resource": "%s: %.2f",
	"mineral_level": "Current: %.2f\nMaximum: %.2f\nMinimum: %.2f"
};

const WORLDMAP_TTIPS = {
	"resource_on_tile": "This is %s and it is a %s."
};

const GENE_TYPE_DESC = "This is %s %s.";
const UNNAMED_GENES = ["Pseudogene", "Transposon"];
const NO_ACRONYM_GENES = ["Pseudogene", "Blank"];
const GENE_TTIP_FORMAT = "%s\n\n%s";
const STATUS_TTIP_FORMAT = "%s\n\n%s";

func _get_gene_desc(type : String) -> String:
	return BASE_TTIPS[type] % GENE_NAMES[type];

func _get_gene_title(type : String, capitalize_gene := true, incl_acronym := true) -> String:
	var gene_title := " Gene";
	if type in UNNAMED_GENES:
		gene_title = "";
	elif !capitalize_gene:
		gene_title = " gene";
	
	var gene_name : String = GENE_NAMES[type];
	if incl_acronym && !(type in NO_ACRONYM_GENES):
		if type == "Transposon":
			gene_name += " (TE)";
		else:
			gene_name += " (%s)" % gene_name[0];
	
	return gene_name + gene_title;

func get_gene_ttip(type : String) -> String:
	var article = "a";
	if type == "Construction":
		article = "an"; # "this is *an* Assembly gene"
	
	return GENE_TTIP_FORMAT % [(GENE_TYPE_DESC % [article, _get_gene_title(type, false)]), _get_gene_desc(type)];

func get_status_ttip(type : String, compare : String) -> String:
	return STATUS_TTIP_FORMAT % [_get_gene_desc(type), COMPARE_TTIPS[compare]];


#	888888ba  oo                   dP                   
#	88    `8b                      88                   
#	88     88 dP .d8888b. 88d888b. 88 .d8888b. dP    dP 
#	88     88 88 Y8ooooo. 88'  `88 88 88'  `88 88    88 
#	88    .8P 88       88 88.  .88 88 88.  .88 88.  .88 
#	8888888P  dP `88888P' 88Y888P' dP `88888P8 `8888P88 
#	                      88                        .88 
#	                      dP                    d8888P  

# This is the element that currently "drives" the tooltip
var tt_element = null;

func _on_mouse_entered():
	show(tt_element);
func _on_mouse_exited():
	hide();

onready var TooltipPanel := $PnlTooltip;
onready var TooltipTitle := $PnlTooltip/LblTitle;
onready var TooltipBody := $PnlTooltip/LblDesc;
onready var Anim := $anim;

func _perf_hide(): # Called in the animation "BeginHide"
	tt_element = null;
	Anim.play("DoHide");

func hide():
	if (Anim.current_animation == "Show"):
		tt_element = null;
		Anim.play("HideNow");
	else:
		Anim.play("BeginHide");

var set_pos_on_show := true;
var anim_pos_node : CanvasItem = null;
func show(for_node : CanvasItem = null):
	set_pos_on_show = true;
	anim_pos_node = for_node;
	if (for_node == null || for_node == tt_element):
		Anim.play("ShowNow");
		if (for_node == tt_element):
			set_pos_on_show = false;
	else:
		tt_element = for_node;
		Anim.play("Show");

func _anim_set_pos():
	set_pos(anim_pos_node);

func set_pos(for_node : CanvasItem = null):
	if (set_pos_on_show):
		var pos : Vector2;
		if (for_node == null):
			pos = TooltipPanel.get_global_mouse_position();
		else:
			if ("position" in for_node):
				pos = for_node.get_global_transform().get_origin() + Vector2(for_node.size.x, for_node.size.y / 2);
			if ("rect_position" in for_node):
				pos = for_node.get_global_rect().position + Vector2(for_node.rect_size.x, for_node.rect_size.y / 2);
		#pos.y -= TooltipPanel.rect_size.y / 2;
		
		var _px = clamp(pos.x, 0, get_viewport().size.x - TooltipPanel.rect_size.x);
		var _py = clamp(pos.y, 0, get_viewport().size.y - TooltipPanel.rect_size.y);
		TooltipPanel.rect_position = Vector2(_px, _py);

func set_tooltip_text(body : String, title : String = ""):
	if (body == "" && title == ""):
		TooltipPanel.visible = false;
	else:
		TooltipPanel.visible = true;
		TooltipBody.text = body;
		TooltipTitle.text = title;

# Don't use this one for the auto-handled tooltips
func disp_ttip_text(for_node : CanvasItem, body : String, title : String = ""):
	show(for_node);
	set_tooltip_text(body, title);

#	dP     dP           dP                                     
#	88     88           88                                     
#	88aaaaa88a .d8888b. 88 88d888b. .d8888b. 88d888b. .d8888b. 
#	88     88  88ooood8 88 88'  `88 88ooood8 88'  `88 Y8ooooo. 
#	88     88  88.  ... 88 88.  .88 88.  ... 88             88 
#	dP     dP  `88888P' dP 88Y888P' `88888P' dP       `88888P' 
#	                       88                                  
#	                       dP                                  

func set_gene_ttip(type, ph_pref):
	var gene_title = "%s Gene";
	if (type in UNNAMED_GENES):
		gene_title = "%s";
	set_tooltip_text("%s\n\nThis gene operates optimally at a pH of %.2f." % [get_gene_ttip(type), ph_pref], gene_title % GENE_NAMES[type]);

func set_status_ttip(type, compare):
	set_tooltip_text(get_status_ttip(type, compare), GENE_NAMES[type]);



# Rather than setting up mouse_entered and mouse_exited signals on every single node, just
# call setup_delay_handler(self) and include either a
# get_tooltip_data() func (which is preferred) or a tooltip_text String

# get_tooltip_data() should return an array [callback : String, args : Array]
# it can also just return an args array, and it will assume a set_tooltip_text callback

func setup_delayed_tooltip(for_node : Control):
	setup_delayed_tooltip_special(for_node, "mouse_entered", "mouse_exited");

func setup_delayed_tooltip_special(for_node : CanvasItem, enter_signal : String, exit_signal : String):
# warning-ignore:return_value_discarded
	for_node.connect(enter_signal, self, "_handle_mouse_enter", [for_node]);
# warning-ignore:return_value_discarded
	for_node.connect(exit_signal, self, "_handle_mouse_exit");

const DISP_DATA_FUNC_NAME = "get_tooltip_data";
const DISP_DATA_STR_NAME = "tooltip_text";

func _handle_mouse_enter(for_node : CanvasItem):
	if for_node.has_method(DISP_DATA_FUNC_NAME):
		# If the handled node has the get_tooltip_data() method, use it to determine what to display
		show(for_node);
		var data = for_node.call(DISP_DATA_FUNC_NAME);
		if (data.size() > 0):
			# If the data is empty, do nothing
			if (data.size() == 2 && typeof(data[0]) == TYPE_STRING && typeof(data[1]) == TYPE_ARRAY):
				# If the data fits [String, Array], do the explicit callback
				callv(data[0], data[1]);
			else:
				# Otherwise, assume the default callback
				callv("set_tooltip_text", data);
	elif DISP_DATA_STR_NAME in for_node:
		# If the hanlded node doesn't have get_tooltip_data() but does have a tooltip_text var, use it
		disp_ttip_text(for_node, for_node.get(DISP_DATA_STR_NAME));
	else:
		disp_ttip_text(null, "You need to include either String %s or func %s() in nodes that make use of the tooltip auto-handler." % [DISP_DATA_STR_NAME, DISP_DATA_FUNC_NAME], "No data!");
func _handle_mouse_exit():
	hide();
