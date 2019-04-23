extends Panel

signal loaded();

func new_save(save):
	$tbox_save.text += save + "\n";
	print("New save: ", save);

func _on_btn_load_pressed():
	if ($tbox_load.text != ""):
<<<<<<< HEAD
		Game.load_from_save($tbox_load.text);
		emit_signal("loaded");
=======
		Game.load_from_save($tbox_load.text.strip_edges());
		emit_signal("loaded");
>>>>>>> 036ba4f46195ece332bd6144d13585708fc8b005
