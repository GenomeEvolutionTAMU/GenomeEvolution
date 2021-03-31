extends Node
#is_viable will determine whether or not death in card table. 
#replicate in organism, look for a successful reproduction 

#TO DIE FAST: 
var temperature_preference ={};
var ph_preference = {};
#delete genes using command console
var temperature_array = [];
#Declaring/initializing variables to keep track of: 
var tiles_traveled = 0
var resources_consumed = 0
var resources_converted = 0
var rounds_run = 0
var progeny_made = 0
var energy_value = 0
var times_energy_added = 0
var reproduction_times = 0
var dmg_genes_no_error = 0
var dmg_genes_error = 0
var breaks_join_no_error = 0
var breaks_join_error = 0
var breaks_cpyRepair_no_error = 0
var breaks_cpyRepair_error = 0
var tiles_copied_cpyRepair = 0
var genes_copied_cpyRepair = 0
var tiles_crctd_cpyRepair = 0
var breaks_repaired_collapseDuplicates = 0
var removed_collapseDuplicates = 0
var majorUpgrades = 0
var minorUpgrades = 0
var majorDowngrades = 0
var minorDowngrades = 0
var majorUpgrades_blankTiles_newGene = 0
var num_skills = 0
var skills_gained = 0
var skills_lost = 0
var maxVal_cat1 = 0
var maxVal_essential = 0
var maxVal_ate = 0
var maxVal_pseudo = 0
#might have to have more, try and figure out how many gene categories there are. 
var finalVal_essential = 0
var finalVal_ate = 0
var finalVal_pseudo = 0
#same thing as the comment above. 
var max_transposon_tiles = 0
var current_transposon_tiles = 0
var max_blank_tiles = 0
var final_blank_tiles = 0
var finalVal_blank = 0
var death_reason
var current_pseudo = 0
var trimmedTiles = 0
var splitGene = 0
var numInversions = 0
var tilesInverted = 0
var downToPseudo = 0;

var current_classicTE = 0
var current_zigzagTE = 0
var current_assistTE = 0
var current_buddyTE = 0
var current_nestlerTE = 0
var current_commuterTE = 0
var current_buncherTE = 0
var current_jumperTE = 0

var max_classicTE = 0
var max_zigzagTE = 0
var max_assistTE = 0
var max_buddyTE = 0
var max_nestlerTE = 0
var max_commuterTE = 0
var max_buncherTE = 0
var max_jumperTE = 0
# replication, locomotion, helper, manipulation, sensing, component, construction, deconstruction, ate

var currentReplication = 0
var currentLocomotion = 0
var currentHelper = 0
var currentManipulation = 0
var currentSensing = 0
var currentComponent = 0
var currentConstruction = 0
var currentDeconstruction = 0
var currentBlank = 0
var currentAte = 0
var maxReplic = 0
var maxLocomo = 0
var maxHelp = 0
var maxManipul = 0
var maxSens = 0
var maxComponent = 0
var maxConstruc = 0
var maxDeconstruc = 0
var maxAte =0
var transposonFuse = 0
var turns_taken = 0

var energy_to_sugar = false
var sugar_to_carb = false
var sugar_to_fatAcid = false
var sugar_to_amAcid = false
var fatAcid_to_fat = false
var fatAcid_to_energy = false
var amAcid_to_protein = false
var amAcid_to_sugar = false
var carb_to_sugar = false
var fat_to_fatAcid = false
var protein_to_amAcid = false

#setting up the first iteration of the chromosome
var first_replication=0
var first_sensing=0
var first_manipulaiton=0
var first_component=0
var first_construction=0
var first_deconstruction=0
var first_helper=0
var first_locomotion=0
var first_pseudo =0
var first_blank=0
var first_ate=0
var first_sum =0
var counter = 0

var gc_rep = 0
var gc_loc = 0
var gc_help = 0
var gc_man = 0
var gc_sens = 0
var gc_comp = 0
var gc_con = 0
var gc_decon = 0
var gc_ate = 0

var first_temp =0

func get_pH_dict():
	return ph_preference;

func get_temp_dict():
	return temperature_preference

func update_temperature(id, value):
	print("Function called")
	if !temperature_preference.has(id):
		print("value taken in: "+str(value))
		temperature_preference[id] = value

func get_temperature_dict_value(id):
	if temperature_preference.has(id):
		print("value out: " + str(temperature_preference[id]))
		return temperature_preference[id]
		
func update_pH(id, value):
	if !ph_preference.has(id):
		ph_preference[id] = value

func get_pH_dict_value(id):
	return ph_preference[id]

func get_total_JE():
	return breaks_join_error + breaks_join_no_error;

func get_total_CPR():
	return breaks_cpyRepair_error + breaks_cpyRepair_no_error;


func get_all_JE_unlocked():
	if(breaks_join_error + breaks_join_no_error >= 19):
		return true;
	else:
		return false;

func get_all_CD_unlocked():
	if(breaks_repaired_collapseDuplicates >= 19):
		return true;
	else:
		return false;

func get_all_CPR_unlocked():
	if(breaks_cpyRepair_error + breaks_cpyRepair_no_error >= 19):
		return true;
	else:
		return false;

func get_all_fix_damage_genes():
	if(dmg_genes_error + dmg_genes_no_error >= 19):
		return true;
	else:
		false

func get_temp_array():
	return temperature_array[0];

func append_temp_array(val):
	temperature_array.append(val);

func print_temp_array():
	print("Printing temperature array: ")
	for i in temperature_array:
		print(str(i)+", ")


func set_first_temp(temp):
	first_temp = temp;
func get_first_temp():
	return first_temp;

func print_me(me):
	print("This is it: ")
	print(str(me))

func set_gc_rep(rep):
	gc_rep = rep;
func set_gc_loc(loc):
	gc_loc = loc;
func set_gc_help(help):
	gc_help = help;
func set_gc_man(man):
	gc_man = man;
func set_gc_sens(sens):
	gc_sens = sens;
func set_gc_comp(comp):
	gc_comp = comp;
func set_gc_con(con):
	gc_con = con;
func set_gc_decon(decon):
	gc_decon = decon;
func set_gc_ate(ate):
	gc_ate = ate;

func get_gc_rep():
	if(gc_rep > 0.1):
		return stepify(gc_rep, 0.1);
	else:
		return gc_rep;

func get_gc_loc():
	if(gc_loc > 0.1):
		return stepify(gc_loc, 0.1);
	else:
		return gc_loc;

func get_gc_help():
	if(gc_help > 0.1):
		return stepify(gc_help, 0.1);
	else:
		return gc_help;

func get_gc_man():
	if(gc_man > 0.1):
		return stepify(gc_man, 0.1);
	else:
		return gc_man;

func get_gc_sens():
	if(gc_sens > 0.1):
		#print("gc_sens: "+str(gc_sens))
		return stepify(gc_sens, 0.1);
	else:
		return gc_sens;

func get_gc_comp():
	if(gc_comp > 0.1):
		return stepify(gc_comp, 0.1);
	else:
		return gc_comp;

func get_gc_con():
	if(gc_con > 0.1):
		return stepify(gc_con, 0.1);
	else:
		return gc_con;

func get_gc_decon():
	if(gc_decon > 0.1):
		return stepify(gc_decon, 0.1);
	else:
		return gc_decon;

func get_gc_ate():
	if(gc_ate > 0.1):
		return stepify(gc_ate, 0.1);
	else:
		return gc_ate;

func set_firsts():
	if(counter == 0):
		first_replication = currentReplication;
		first_sensing = currentSensing;
		first_manipulaiton = currentManipulation;
		first_component = currentComponent;
		first_construction = currentConstruction;
		first_deconstruction = currentDeconstruction;
		first_helper = currentHelper;
		first_locomotion = currentLocomotion;
		first_blank = currentBlank;
		first_pseudo = current_pseudo
		first_ate= currentAte
	first_sum = first_replication + first_sensing + first_manipulaiton + first_component + first_construction + first_deconstruction + first_helper + first_locomotion
	counter +=1;

func get_first_sum():
	return first_sum;
func get_first_replication():
	return first_replication
func get_first_sensing():
	return first_sensing;
func get_first_manipulation():
	return first_manipulaiton;
func get_first_component():
	return first_component;
func get_first_construction():
	return first_construction;
func get_first_deconstruction():
	return first_deconstruction;
func get_first_helper():
	return first_helper;
func get_first_locomotion():
	return first_locomotion;
func get_first_pseudo():
	return first_pseudo;
func get_first_blank():
	return first_blank;
func get_first_ate():
	return first_ate;

func get_current_pseudo():
	return current_pseudo;
func get_maxVal_pseudo():
	return maxVal_pseudo;


func get_current_classicTE():
	return current_classicTE
func get_current_zigzagTE():
	return current_zigzagTE;
func get_current_assistTE():
	return current_assistTE
func get_current_buddyTE():
	return current_buddyTE
func get_current_nestlerTE():
	return current_nestlerTE
func get_current_commuterTE():
	return current_commuterTE
func get_current_buncherTE():
	return current_buncherTE
func get_current_jumperTE():
	return current_jumperTE

func increment_downToPseudo():
	downToPseudo += 1
func get_downToPseudo():
	return downToPseudo;
func increment_turns():
	turns_taken += 1
func get_turns():
	return turns_taken
func get_currentRep():
	return currentReplication
func get_currentLoc():
	return currentLocomotion
func get_currentHelp():
	return currentHelper
func get_currentManip():
	return currentManipulation
func get_currentSens():
	return currentSensing
func get_currentComp():
	return currentComponent
func get_currentCon():
	return currentConstruction
func get_currentDeCon():
	return currentDeconstruction
func get_currentAte():
	return currentAte
func get_currentBlank():
	return currentBlank;
func get_maxRep():
	if(maxReplic > 0.1):
		return stepify(maxReplic, 0.1);
	else:
		return maxReplic

func get_maxLocomo():
	if(maxLocomo > 0.1):
		return stepify(maxLocomo,0.1)
	else:
		return maxLocomo

func get_maxHelp():
	if(maxHelp > 0.1):
		return stepify(maxHelp, 0.1)
	else:
		return maxHelp

func get_maxManip():
	if(maxManipul > 0.1):
		return stepify(maxManipul, 0.1)
	else:
		return maxManipul

func get_maxSens():
	if(maxSens > 0.1):
		return stepify(maxSens, 0.1)
	else:
		return maxSens

func get_maxComp():
	if(maxComponent > 0.1):
		return stepify(maxComponent, 0.1)
	else:
		return maxComponent

func get_maxCon():
	if(maxConstruc > 0.1):
		return stepify(maxConstruc, 0.1)
	else:
		return maxConstruc

func get_maxDecon():
	if(maxDeconstruc > 0.1):
		return stepify(maxDeconstruc, 0.1)
	else: 
		return maxDeconstruc

func get_maxAte():
	return maxAte

func get_d():
	return max_blank_tiles;

func _reset_game():
	#Declaring/initializing variables to keep track of: 
	gc_ate = 0
	gc_comp=0
	gc_con=0
	gc_decon =0
	gc_help=0
	gc_loc=0
	gc_man = 0
	gc_rep = 0
	gc_sens=0
	first_replication=0
	first_sensing=0
	first_manipulaiton=0
	first_component=0
	first_construction=0
	first_deconstruction=0
	first_helper=0
	first_locomotion=0
	first_pseudo =0
	first_blank=0
	first_ate=0
	first_sum =0
	counter = 0
	tiles_traveled = 0
	resources_consumed = 0
	resources_converted = 0
	rounds_run = 0
	progeny_made = 0
	energy_value = 0
	times_energy_added = 0
	reproduction_times = 0
	dmg_genes_no_error = 0
	dmg_genes_error = 0
	breaks_join_no_error = 0
	breaks_join_error = 0
	breaks_cpyRepair_no_error = 0
	breaks_cpyRepair_error = 0
	tiles_copied_cpyRepair = 0
	genes_copied_cpyRepair = 0
	tiles_crctd_cpyRepair = 0
	breaks_repaired_collapseDuplicates = 0
	removed_collapseDuplicates = 0
	majorUpgrades = 0
	minorUpgrades = 0
	majorDowngrades = 0
	minorDowngrades = 0
	majorUpgrades_blankTiles_newGene = 0
	num_skills = 0
	skills_gained = 0
	skills_lost = 0
	maxVal_cat1 = 0
	maxVal_essential = 0
	maxVal_ate = 0
	maxVal_pseudo=0
	#might have to have more, try and figure out how many gene categories there are. 
	finalVal_essential = 0
	finalVal_ate = 0
	finalVal_pseudo = 0
	#same thing as the comment above. 
	max_transposon_tiles = 0
	current_transposon_tiles = 0
	max_blank_tiles = 0
	final_blank_tiles = 0
	finalVal_blank = 0
	death_reason
	current_pseudo = 0
	trimmedTiles = 0
	splitGene = 0
	numInversions = 0
	tilesInverted = 0
	downToPseudo = 0;
	current_classicTE = 0
	current_zigzagTE = 0
	current_assistTE = 0
	current_buddyTE = 0
	current_nestlerTE = 0
	current_commuterTE = 0
	current_buncherTE = 0
	current_jumperTE = 0
	max_classicTE = 0
	max_zigzagTE = 0
	max_assistTE = 0
	max_buddyTE = 0
	max_nestlerTE = 0
	max_commuterTE = 0
	max_buncherTE = 0
	max_jumperTE = 0
	# replication, locomotion, helper, manipulation, sensing, component, construction, deconstruction, ate
	currentReplication = 0
	currentLocomotion = 0
	currentHelper = 0
	currentManipulation = 0
	currentSensing = 0
	currentComponent = 0
	currentConstruction = 0
	currentDeconstruction = 0
	currentBlank = 0
	currentAte = 0
	maxReplic = 0
	maxLocomo = 0
	maxHelp = 0
	maxManipul = 0
	maxSens = 0
	maxComponent = 0
	maxConstruc = 0
	maxDeconstruc = 0
	maxAte =0
	transposonFuse = 0
	turns_taken = 0

func increment_currentReplication():
	currentReplication += 1;
func increment_currentLocomotion():
	currentLocomotion += 1;
func increment_currentHelper():
	currentHelper += 1;
func increment_currentManipulation():
	currentManipulation += 1;
func increment_currentSensing():
	currentSensing += 1;
func increment_currentComponent():
	currentComponent += 1;
func increment_currentConstruction():
	currentConstruction += 1;
func increment_currentDeconstruction():
	currentDeconstruction += 1;
func increment_currentAte():
	currentAte += 1;
func increment_currentBlank():
	currentBlank += 1;
	
func clear_currentGenes():
	currentReplication = 0;
	currentLocomotion = 0;
	currentHelper = 0;
	currentManipulation = 0;
	currentSensing = 0;
	currentComponent = 0;
	currentConstruction = 0;
	currentDeconstruction = 0;
	currentAte = 0;
	currentBlank = 0;
	current_pseudo = 0;

func update_maxType():
	if(gc_rep > maxReplic):
		maxReplic = gc_rep
	if(gc_loc > maxLocomo):
		maxLocomo = gc_loc 
	if(gc_help > maxHelp):
		maxHelp = gc_help
	if(gc_man > maxManipul):
		maxManipul = gc_man
	if(gc_sens > maxSens):
		maxSens = gc_sens
	if(gc_comp > maxComponent):
		maxComponent = gc_comp
	if(gc_con > maxConstruc):
		maxConstruc = gc_con
	if(gc_decon > maxDeconstruc):
		maxDeconstruc = gc_decon
	if(gc_ate > maxAte):
		maxAte = gc_ate
	if(currentBlank > max_blank_tiles):
		max_blank_tiles = currentBlank
	if(current_pseudo > maxVal_pseudo):
		maxVal_pseudo = current_pseudo


func increment_transposonFuse():
	transposonFuse += 1
func get_TEFuse():
	return transposonFuse;
	
func compare_maxTE():
	if(current_classicTE > max_classicTE):
		max_classicTE = current_classicTE
	if(current_zigzagTE > max_zigzagTE):
		max_zigzagTE = current_zigzagTE
	if(current_assistTE > max_assistTE):
		max_assistTE = current_assistTE
	if(current_buddyTE > max_buddyTE):
		max_buddyTE = current_buddyTE
	if(current_nestlerTE > max_nestlerTE):
		max_nestlerTE = current_nestlerTE
	if(current_commuterTE > max_commuterTE):
		max_commuterTE = current_commuterTE
	if(current_buncherTE > max_buncherTE):
		max_buncherTE = current_buncherTE
	if(current_jumperTE > max_jumperTE):
		max_jumperTE = current_jumperTE


#get_max_assistTE()
func get_max_classicTE():
	return max_classicTE;
func get_max_zigzagTE():
	return max_zigzagTE;
func get_max_assistTE():
	return max_assistTE;
func get_max_buddyTE():
	return max_buddyTE;
func get_max_nestlerTE():
	return max_nestlerTE;
func get_max_commuterTE():
	return max_commuterTE;
func get_max_buncherTE():
	return max_buncherTE;
func get_max_jumperTE():
	return max_jumperTE;

func clear_currentTE():
	current_assistTE = 0
	current_buddyTE = 0
	current_buncherTE = 0
	current_classicTE = 0
	current_commuterTE = 0
	current_jumperTE = 0
	current_nestlerTE = 0
	current_zigzagTE = 0
#card, superjump, closefar, budding, cnearjfar, commuter, zigzag, buncher\n
func update_currentTE(TE):
	if(TE.ate_personality["key"] == "zigzag"):#
		current_zigzagTE += 1
	elif(TE.ate_personality["key"] == "card"): #
		current_classicTE += 1
	elif(TE.ate_personality["key"] == "superjump"): #
		current_jumperTE += 1
	elif(TE.ate_personality["key"] == "budding"): #
		current_buddyTE += 1
	elif(TE.ate_personality["key"] == "commuter"): #
		current_commuterTE +=1
	elif(TE.ate_personality["key"] == "buncher"):# 
		current_buncherTE += 1
	elif(TE.ate_personality["key"] == "cnearjfar"):
		current_nestlerTE += 1
	elif(TE.ate_personality["key"] == "closefar"):
		current_assistTE += 1 

func increment_tilesInverted():
	tilesInverted += 1
func increment_numInversions():
	numInversions += 1

func increment_geneSplits():
	splitGene += 1
func get_geneSplit():
	return splitGene;
func increment_trimmedTiles():
	trimmedTiles +=1
func get_trimmedTiles():
	return trimmedTiles;
func increment_currentPseudo():
	current_pseudo += 1

func maxBlankTiles():
	if(max_blank_tiles < final_blank_tiles):
		max_blank_tiles = final_blank_tiles

func compare_maxTransposon(TE):
	if(TE > max_transposon_tiles):
		max_transposon_tiles = TE

func set_currentTransposon(TE):
	current_transposon_tiles = TE

func set_reason_death(reason):
	death_reason = reason

func increment_final_blank_tiles():
	final_blank_tiles += 1

#What:Track the final number of blank tiles at game end
#Where: 
func get_final_blank_tiles():
	return final_blank_tiles

#What:Track the final number of blank tiles at game end
#Where: 
func set_final_blank_tiles(tiles):
	final_blank_tiles = tiles

#What: Track the maximum number of blank tiles
#Where: 
func get_max_blank_tiles():
	return max_blank_tiles

#What: Track the maximum number of blank tiles
#Where: 
func increment_max_blank_tiles():
	max_blank_tiles += 1

#What:Track the final number of transposon tiles at game end
#Where: transposon ui, in the setter function.
func get_final_transposon_tiles():
	return current_transposon_tiles
	
#What:Track the final number of transposon tiles at game end
#Where: 
func increment_final_transposon_tiles():
	current_transposon_tiles += 1
	
#What:Track the maximum number of transposon tiles
#Where: 
func get_max_transposon_tiles():
	return max_transposon_tiles

#What:Track the maximum number of transposon tiles
#Where: 
func increment_max_transposon_tiles():
	max_transposon_tiles += 1


#What: Track the final value earned for each gene category end
#Where: 
func get_finalVal_blank():
	return finalVal_blank

#What: Track the final value earned for each gene category end
#Where: 
func set_finalVal_blank(val):
	finalVal_blank = val

#What: Track the final value earned for each gene category end
#Where: 
func get_finalVal_essential():
	return finalVal_essential

#What: Track the final value earned for each gene category end
#Where: 
func set_finalVal_essential(val):
	finalVal_essential = val

#What: Track the final value earned for each gene category end
#Where: 
func get_finalVal_ate():
	return finalVal_ate

#What: Track the final value earned for each gene category end
#Where: 
func set_finalVal_ate(val):
	finalVal_ate = val 

#What: Track the final value earned for each gene category end
#Where: 
func get_finalVal_pseudo():
	return finalVal_pseudo

#What: Track the final value earned for each gene category end
#Where: 
func set_finalVal_pseudo(val):
	finalVal_pseudo = val 

#What:Track the maximum value earned by each gene category
#Where: 
func get_maxVal_cat1():
	return maxVal_cat1

#What:Track the maximum value earned by each gene category
#Where: 
func increment_maxVal_cat1():
	maxVal_cat1 += 1

#What:Track the number of skills learned by genes
#Where: 
func get_num_skills():
	return num_skills

func get_skills_gained():
	return skills_gained;
func get_skills_lost():
	return skills_lost;
#What:Track the number of skills learned by genes
#Where: 
func increment_num_skills():
	num_skills += 1
	skills_gained +=1

func decrement_num_sklls():
	num_skills -= 1
	skills_lost +=1
#What:Track the number of major upgrades received by blank tiles, resulting in a new gene
#Where: 
func get_majorUpgrades_blankTiles_newGene():
	return majorUpgrades_blankTiles_newGene

#What:Track the number of major upgrades received by blank tiles, resulting in a new gene
#Where: SequenceElement in evolve major
func increment_majorUpgrades_blankTiles_newGame():
	majorUpgrades_blankTiles_newGene += 1

#What:   Track the number of minor downgrades received by genes
#Where: 
func get_minorDowngrades():
	return minorDowngrades

#What:   Track the number of minor downgrades received by genes
#Where: 
func increment_minorDowngrades():
	minorDowngrades += 1

#What: Track the number of major downgrades received by genes
#Where: 
func get_majorDowngrades():
	return majorDowngrades

#What:  Track the number of major downgrades received by genes
#Where: 
func increment_majorDowngrades():
	majorDowngrades += 1

#What: Track the number of minor upgrades received by genes
#Where: 
func get_minorUpgrades():
	return minorUpgrades

#What: Track the number of minor upgrades received by genes
#Where: 
func increment_minorUpgrades():
	minorUpgrades += 1

#What Track the number of major upgrades received by genes

#where
func get_majorUpgrades():
	return majorUpgrades

#What:Track the number of major upgrades received by genes
#Where: 
func increment_majorUpgrades():
	majorUpgrades += 1

#what: Track number of tiles removed using collapse duplicates function
#where:
func get_removed_collapseDuplicates():
	return removed_collapseDuplicates

#what: Track number of tiles removed using collapse duplicates function
#where:
func increment_removed_collapseDuplicates():
	removed_collapseDuplicates += 1

#what: Track number of breaks repaired using collapse duplicates function
#where:
func get_break_repaired_collapseDuplicates():
	return breaks_repaired_collapseDuplicates

#what: Track number of breaks repaired using collapse duplicates function
#where:
func increment_break_repaired_collapseDuplicates():
	breaks_repaired_collapseDuplicates += 1

#What:Track number of tile corrected during copy repair
#Where:
func get_tiles_crctd_cpyRepair():
	return tiles_crctd_cpyRepair

#What: Track number of tile corrected during copy repair
#where:
func increment_tiles_crctd_cpyRepair():
	tiles_crctd_cpyRepair += 1

#What:  Track number of genes copied using the copy-repair function
#Where:
func get_genes_copied_cpyRepair():
	return genes_copied_cpyRepair

#What: Track number of genes copied using the copy-repair function
#Where: in repair_gene of organism, copy Pattern switch case 1-3.
func increment_genes_copied_cpyRepair():
	genes_copied_cpyRepair += 1

#What:   Track number of tiles copied using the copy-repair function
#Where: 
func get_tiles_copied_cpyRepair():
	return tiles_copied_cpyRepair

#What:   Track number of tiles copied using the copy-repair function
#Where:  in repair_gene of organism, copy Pattern switch case 1-3.
func increment_tiles_copied_cpyRepair():
	tiles_copied_cpyRepair += 1

#What:   Track number of breaks repaired using copy repair with errors
#where:
func get_breaks_cpyRepair_error():
	return breaks_cpyRepair_error

#What:   Track number of breaks repaired using copy repair with errors
#where: in repair_gene of organism, copy Pattern switch case 1-3.
func increment_breaks_cpyRepair_error():
	breaks_cpyRepair_error += 1

#What:Track number of breaks repaired using copy-repair with no errors
#where:
func get_breaks_cpyRepair_no_error():
	return breaks_cpyRepair_no_error

#What:Track number of breaks repaired using copy-repair with no errors
#where: in repair_gene of organism, copy Pattern switch case zero.
func increment_breaks_cpyRepair_no_error():
	breaks_cpyRepair_no_error += 1

#What:Track number of breaks repaired using join ends with errors
#where:
func get_breaks_join_error():
	return breaks_join_error
	
#What:Track number of breaks repaired using join ends with errors
#where:in repair_gap, in organism
func increment_breaks_join_error():
	breaks_join_error += 1
 
#What: Track number of breaks repaired using join ends with no errors
#where: 
func get_breaks_join():
	return breaks_join_no_error
	
#What: Track number of breaks repaired using join ends with no errors
#where:in repair_gap, in organism
func increment_breaks_join():
	breaks_join_no_error += 1

#What:Track number of damaged genes repaired using fix damaged genes with errors
#where:
func get_dmg_genes_error():
	return dmg_genes_error

#What:Track number of damaged genes repaired using fix damaged genes with errors
#where:in repair_gap, in organism
func increment_dmg_genes_error():
	 dmg_genes_error += 1

#What:Track number of damaged genes repaired using fix damaged genes with no errors
#where:
func get_dmg_genes_no_error():
	return dmg_genes_no_error

#What:Track number of damaged genes repaired using fix damaged genes with no errors
#where:in repair_gap, in organism
func increment_dmg_genes_no_error():
	dmg_genes_no_error += 1 

#What: Returns the number of times that reproduction is called.
#where: 
func get_reproduction_times():
	return reproduction_times

#What: increments the number of times that reproduction is done. 
#Where: Organism, in replicate function 
func increment_reproduction_times():
	reproduction_times += 1

#What: to show how many times a player will update from food to energy
#Where: EnergyBar in add_energy
func increment_times_energy_added():
	times_energy_added += 1

#What: returns the tiles traveled value
#where: 
func get_tiles_traveled():
	return tiles_traveled

#What: Increments the tiles traveled variable
#Where: WorldMap, within the move_player function
func increment_tiles_traveled():
	tiles_traveled += 1

#What: returns the resources consumed
#where: 
func get_resources_consumed():
	return resources_consumed

#What: increments the resouces consumed variable
#where: In Organism, function: add_resource
func increment_resources_consumed():
	resources_consumed += 1
 
#What: returns the resources converted
#where: 
func get_resources_converted():
	return resources_converted

#What:Increments the number of times that the resources have been invcremented. 
#where: In organism, within the use_resource
func increment_resources_converted():
	resources_converted += 1

#What: returns the energy Value
#where: 
func get_Energy():
	return energy_value
#What: Sets the energy to the given value of the energy bar
#Where: EnergyBar.gd in update Energy Allocation

func set_Energy(energy):
	energy_value = energy

#What: returns the number of progeny in a game
#Where: pnl_dead_overview
func get_progeny():
	return progeny_made

#What: Increments progeny by 3 because of meiosis in replicate under Organism
#Where: Replicate() in Organism
func increment_progeny_meiosis():
	progeny_made += 3

#What: Increments progeny by 1 because of mitosis.
#Where: Replicate() in Organism
func increment_progeny_mitosis():
	progeny_made += 1

#what: returns RoundsRun
#Where: pnl_dead_overview
func get_rounds():
	return rounds_run

#What: Increments Rounds by 1
#Where: adv_turn in Card Table
func set_Rounds(rounds):
	rounds_run = rounds

# Called when the node enters the scene tree for the first time, not sure what to do with this guy
func _ready():
	pass # Replace with function body.
