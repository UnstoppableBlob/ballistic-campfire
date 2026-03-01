extends Node

@onready var label = $Label

# Preload all fish types
var fish_scenes = {
	"castle1": preload("res://scenes/test.tscn"),
	"castle2": preload("res://scenes/salmon.tscn"),
	"castle3": preload("res://scenes/trout.tscn")
}

# Track data for each active siege
var sieges = {
	"castle1": {"castle": null, "fish_list": [], "amount": 3},
	"castle2": {"castle": null, "fish_list": [], "amount": 3},
	"castle3": {"castle": null, "fish_list": [], "amount": 3}
}

var time_elapsed: float = 0.0
var game_over: bool = false

func _ready():
	# Wait a moment for all objects to initialize in the scene
	await get_tree().create_timer(1.0).timeout
	
	# Start the siege for every castle found in the groups
	for group_name in sieges.keys():
		var castle_node = get_tree().get_first_node_in_group(group_name)
		if is_instance_valid(castle_node):
			sieges[group_name].castle = castle_node
			spawn_wave(group_name)

func spawn_wave(group_name: String):
	var data = sieges[group_name]
	var castle = data.castle
	
	if not is_instance_valid(castle) or castle.health <= 0:
		return

	var radius = 70.0
	var angle_step = TAU / data.amount
	
	for i in range(data.amount):
		var fish = fish_scenes[group_name].instantiate()
		fish.target = castle
		
		var offset = Vector2.RIGHT.rotated(angle_step * i) * radius
		fish.global_position = castle.global_position + offset
		
		# Set the layer based on the group name (castle1 = 1, etc)
		if "layer" in fish:
			fish.layer = int(group_name.right(1))
			
		data.fish_list.append(fish)
		get_tree().current_scene.add_child(fish)

func _process(delta: float):
	if not game_over:
		time_elapsed += delta
		update_label_text()
		
	# Check every siege independently
	for group_name in sieges.keys():
		var data = sieges[group_name]
		if data.castle == null: continue
		
		# 1. If this specific castle died, clear its fish and stop its siege
		if not is_instance_valid(data.castle) or data.castle.health <= 0:
			for fish in data.fish_list:
				if is_instance_valid(fish): fish.queue_free()
			data.fish_list.clear()
			data.castle = null
			check_total_game_over()
			continue
			
		# 2. If the castle is alive, check if its specific wave of fish is dead
		var alive_count = 0
		for fish in data.fish_list:
			if is_instance_valid(fish):
				alive_count += 1
		
		# If this specific castle's wave is gone, spawn a bigger one for ONLY this castle
		if alive_count == 0:
			data.amount += 2
			data.fish_list.clear()
			# Small delay before the next wave for this specific castle
			get_tree().create_timer(2.0).timeout.connect(func(): spawn_wave(group_name))

func check_total_game_over():
	# If all castles are null, the game is over
	for group_name in sieges.keys():
		if sieges[group_name].castle != null:
			return # Someone is still alive!
			
	game_over = true
	print("All bases lost. Final survival time: ", label.text)

func update_label_text():
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	label.text = "%02d:%02d" % [minutes, seconds]
