#extends Node2D
#
#var health = 10
#var max_health = 10
#
## 1. ADD THIS VARIABLE HERE AT THE TOP
#var is_invincible = false 
#
#@export var speed: float = 40.0
#@export var rotation_speed: float = 5.0
#
#@onready var sprite = $AnimatedSprite2D 
#var target: Node2D 
#
#@onready var health_bar = $TextureProgressBar
#
#func _ready() -> void:
	#health_bar.max_value = max_health
	#health_bar.value = health
	#target = get_tree().get_first_node_in_group("castle1")
#
#func _process(delta: float) -> void:
	#health_bar.rotation_degrees = 0
	#if is_instance_valid(target):
		#var direction = global_position.direction_to(target.global_position)
		#var target_angle = direction.angle()
		#rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
		#
		#if abs(rotation) > PI / 2.0:
			#sprite.flip_v = true
		#else:
			#sprite.flip_v = false
			#
		#var step = speed * delta
		#global_position = global_position.move_toward(target.global_position, step)
#
#
## 2. REPLACE YOUR ENTIRE AREA ENTERED FUNCTION WITH THIS
#func _on_area_2d_area_entered(area: Area2D) -> void:
	## If the fish is currently invincible, ignore the hit and stop the function
	##if is_invincible:
		##return
		#
	## If not invincible, take damage!
	#health -= 1
	#health_bar.value = health
	#print(health)
	#print(health_bar.value)
	#
	#if health <= 0:
		#queue_free()
		#return # Make sure we exit the function if the fish dies!
		#
	## --- TRIGGER INVINCIBILITY ---
	#is_invincible = true
	#
	## Wait for 0.2 seconds (you can change this number to make it longer or shorter)
	#await get_tree().create_timer(0.2).timeout
	#
	## Turn invincibility back off so it can take damage again
	#is_invincible = false
extends Node2D



var health = 5
var max_health = 5

var layer = 1
var is_invincible = false 

@export var speed: float = 155.0
@export var rotation_speed: float = 5.0

@onready var sprite = $AnimatedSprite2D 
var target: Node2D 

@onready var health_bar = $TextureProgressBar

func _ready() -> void:
	add_to_group("fish-1")
	health_bar.max_value = max_health
	health_bar.value = health
	#target = get_tree().get_first_node_in_group("castle1")
	
	# --- NEW: Sync the Fish's Area2D to its depth layer ---
	# This guarantees it will only ever touch things on the same layer
	for i in range(1, 4):
		var is_current = (i == layer)
		$Area2D.set_collision_layer_value(i, is_current)
		$Area2D.set_collision_mask_value(i, is_current)

func _process(delta: float) -> void:
	health_bar.rotation_degrees = 0
	
	if is_instance_valid(target):
		var direction = global_position.direction_to(target.global_position)
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
		
		if abs(rotation) > PI / 2.0:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
			
		var step = speed * delta
		global_position = global_position.move_toward(target.global_position, step)

func _on_area_2d_area_entered(area: Area2D) -> void:
	# 1. If invincible, ignore the hit entirely
	#if is_invincible:
		#return
		
	# 2. Take damage (No layer checking needed anymore!)
	health -= 1
	health_bar.value = health
	
	if health <= 0:
		queue_free()
		return 
		
	# 3. Trigger Invincibility frames
	is_invincible = true
	await get_tree().create_timer(0.2).timeout
	is_invincible = false
