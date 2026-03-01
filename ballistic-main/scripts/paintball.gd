extends Area2D

@export var speed: float = 160.0

# These are set by the player right after the paintball is fired
var direction: Vector2 = Vector2.ZERO
var current_layer: int = 1 

# Visual settings
var base_scale: float = 1.0
var scale_step: float = 0.25 
var radius = 2
var color: Color

func _ready():
	# Generate a completely random color for this specific paintball
	color = Color(randf(), randf(), randf())
	
	# Match the visual size of the layer it was fired on
	var target_scale_value = base_scale - ((current_layer - 1) * scale_step)
	scale = Vector2(target_scale_value, target_scale_value)
	
	# Apply the depth fade/darkness
	modulate = Color(1, 1, 1, 1.0 - ((current_layer - 1) * 0.25))
	
	# --- NEW: Automatically sync physics layers to the depth layer ---
	for i in range(1, 4):
		var is_current = (i == current_layer)
		set_collision_layer_value(i, is_current)
		set_collision_mask_value(i, is_current)
	
	# Tell Godot to run the _draw() function
	queue_redraw()
	
	# Destroy the paintball after 2 seconds so it doesn't fly infinitely
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(queue_free)

func _physics_process(delta):
	# Move the paintball continuously in the fired direction
	global_position += direction * speed * delta

func _draw():
	# Draws the actual paintball using the randomly generated color
	draw_circle(Vector2.ZERO, radius, color)
