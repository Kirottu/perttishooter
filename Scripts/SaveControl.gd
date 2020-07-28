extends Node

var save_path = "user://savegame.save"
var save_data = {"score": 0, "round": 0}

func save(score, rounds):
	save_data["score"] = score
	save_data["round"] = rounds
	var save = File.new()
	save.open(save_path, File.WRITE)
	save.store_var(save_data)
	save.close()
	
func _load():
	var save = File.new()
	if not save.file_exists(save_path):
		save.open(save_path, File.WRITE)
		save.store_var(save_data)
		save.close()
	save.open(save_path, File.READ)
	save_data = save.get_var()
	save.close()
