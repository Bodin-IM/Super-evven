extends Area2D

export(String, FILE, "*.tcsn") var target_level_path = ""

func _on_Door_body_entered(body):
	if not body is Player: return #if its not a player dont do anything
	if target_level_path.empty(): return #if no path return
	get_tree().change_scene(target_level_path)
	
