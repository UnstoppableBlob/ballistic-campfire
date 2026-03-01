extends Node

@onready var label = $Label


@onready var background1
@onready var background2
@onready var background3

# 1. Preload scenes (Double-check these paths in your FileSystem!)
var fish_scene_l1 = preload("res://scenes/test.tscn") 
var fish_scene_l2 = preload("res://scenes/salmon.tscn") 
var fish_scene_l3 = preload("res://scenes/trout.tscn") 

var current_phase: int = 1
var current_fish_scene: PackedScene
var target_group: String

var castle: Node2D
var spawned_fish: Array = []
var is_active: bool = false 
var current_amount: int = 3

var time_elapsed: float = 0.0
var game_over: bool = false
var wave_timer: Timer 

func _ready():
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.timeout.connect(start_wave)
	add_child(wave_timer)
	
	setup_phase(current_phase)
	wave_timer.start(1.0)

func setup_phase(phase: int):
	if phase == 1:
		current_fish_scene = fish_scene_l1
		target_group = "castle1"
	elif phase == 2:
		current_fish_scene = fish_scene_l2
		target_group = "castle2"
	elif phase == 3:
		current_fish_scene = fish_scene_l3
		target_group = "castle3"
	
	current_amount = 3 # Reset count for new base
	print("Switched to Phase: ", phase, " | Target: ", target_group)

func start_wave():
	# Find the base
	castle = get_tree().get_first_node_in_group(target_group)
	
	# SAFETY: If we can't find the castle yet, wait and try again
	if not is_instance_valid(castle):
		print("Waiting for ", target_group, " to appear...")
		wave_timer.start(0.5)
		return
		
	var radius = 80.0 # Slightly larger radius to prevent bunching
	var angle_step = TAU / current_amount 
	
	spawned_fish.clear()
	
	for i in range(current_amount):
		var fish = current_fish_scene.instantiate()
		fish.target = castle # Assign the castle object directly
		
		var offset = Vector2.RIGHT.rotated(angle_step * i) * radius
		fish.global_position = castle.global_position + offset
		
		# Give them their speed and layer
		if "speed" in fish:
			fish.speed += randf_range(-4.0, 4.0)
		
		spawned_fish.append(fish)
		get_tree().current_scene.add_child(fish)
		
	is_active = true

func _process(delta: float) -> void:
	if not game_over:
		time_elapsed += delta
		update_label_text()

	if not is_active: return

	# CHECK 1: DID THE CURRENT CASTLE DIE?
	if not is_instance_valid(castle) or castle.health <= 0:
		transition_to_next_phase()
		return

	# CHECK 2: ARE THE FISH DEAD?
	var alive_count = 0
	for fish in spawned_fish:
		if is_instance_valid(fish):
			alive_count += 1
			
	if alive_count == 0:
		is_active = false 
		current_amount += 2 
		wave_timer.start(2.0)

func transition_to_next_phase():
	is_active = false
	wave_timer.stop()
	
	# Clean up leftover fish
	for fish in spawned_fish:
		if is_instance_valid(fish):
			fish.queue_free()
	spawned_fish.clear()
	
	current_phase += 1
	
	if current_phase > 3:
		game_over = true
		print("Victory! All bases defended.")
		set_process(false)
		return
	
	setup_phase(current_phase)
	wave_timer.start(3.0) # 3 second breather between bases

func update_label_text():
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	label.text = "%02d:%02d" % [minutes, seconds]
