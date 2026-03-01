extends CharacterBody2D

@export var player_id : int = 0
@export var paintball_scene : PackedScene
@export var health = 270

# --- Depth Settings ---
var current_layer : int = 1 # 1: Surface, 2: Middle, 3: Deep
var scale_step : float = 0.25 # Shrink amount per layer
var base_scale : float = 1.0

var radius = 4
var color = Color.DODGER_BLUE
var speed: float = 40
var acceleration = 240
var friction = 280

var aim_deadzone = 0.18
var aim_smoothness = 20
var aim_angle = 0

var fire_rate = 0.15
var fire_timer = 0

@onready var aim_cont = $aim_container

var start_position: Vector2

func _ready():
	start_position = global_position 
	
	# --- NEW: Make the player detectable by all 3 fish layers ---
	# We turn on the mask for 1, 2, and 3 so we can "see" all fish
	for i in range(1, 4):
		$Area2D.set_collision_mask_value(i, true)
		$Area2D.set_collision_layer_value(i, true)
	
	update_depth_state(true) 
	queue_redraw()

func _physics_process(delta):
	#print(current_layer)
	handle_depth_input()
	
	# --- Aiming Logic ---
	var aim = get_aim_vector()
	
	if aim != Vector2.ZERO:
		var target_angle = aim.angle()
		aim_angle = lerp_angle(aim_angle, target_angle, 1 - exp(-aim_smoothness * delta))
	elif velocity != Vector2.ZERO: 
		# Snap aim to movement direction if not explicitly aiming
		var target_angle = velocity.angle()
		aim_angle = lerp_angle(aim_angle, target_angle, 1 - exp(-aim_smoothness * delta))
			
	aim_cont.rotation = aim_angle
	
	# --- Movement Logic ---
	var input = get_stick_vector()
	var target_velocity = input * speed
	
	if input != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_slide()
		
	# --- Shooting Logic ---
	fire_timer -= delta
	
	if Input.is_action_pressed("fire") and fire_timer <= 0:
		fire()
		fire_timer = fire_rate
		
	if current_layer == 1:
		WaveManager.background1.visible = true
		WaveManager.background2.visible = false
		WaveManager.background3.visible = false
	if current_layer == 2:
		WaveManager.background1.visible = false
		WaveManager.background2.visible = true
		WaveManager.background3.visible = false
	if current_layer == 3:
		WaveManager.background1.visible = false
		WaveManager.background2.visible = false
		WaveManager.background3.visible = true
	
func handle_depth_input():
	var up_input = "dive_up"
	var down_input = "dive_down"
	
	if Input.is_action_just_pressed(up_input) and current_layer > 1:
		current_layer -= 1
		update_depth_state()
	elif Input.is_action_just_pressed(down_input) and current_layer < 3:
		current_layer += 1
		update_depth_state()

func update_depth_state(instant: bool = false):
	# Calculate visual targets
	var target_scale_value = base_scale - ((current_layer - 1) * scale_step)
	var target_scale = Vector2(target_scale_value, target_scale_value)
	var target_modulate = Color(1, 1, 1, 1.0 - ((current_layer - 1) * 0.25)) # Darken as you go deeper
	
	# Update collision layers (Assuming your game uses Physics Layer 1, 2, and 3 for the depths)
	#if current_layer == 1:
		#set_collision_layer_value()

	# Apply visuals
	if instant:
		scale = target_scale
		modulate = target_modulate
	else:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "scale", target_scale, 0.25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "modulate", target_modulate, 0.25).set_trans(Tween.TRANS_SINE)

func get_stick_vector() -> Vector2:
	var right = "p%s_right" % player_id
	var left = "p%s_left" % player_id
	var up = "p%s_up" % player_id
	var down = "p%s_down" % player_id
	
	var v = Vector2(
		Input.get_action_strength(right) - Input.get_action_strength(left),
		Input.get_action_strength(down) - Input.get_action_strength(up)
	)
	var deadzone := 0.12
	var length = v.length()
	if length < deadzone:
		return Vector2.ZERO
	return v.normalized() * ((length - deadzone) / (1 - deadzone))

func get_aim_vector() -> Vector2:
	var right_aim = "p%s_right_aim" % player_id
	var left_aim = "p%s_left_aim" % player_id
	var up_aim = "p%s_up_aim" % player_id
	var down_aim = "p%s_down_aim" % player_id
	
	var v = Vector2(
		Input.get_action_strength(right_aim) - Input.get_action_strength(left_aim),
		Input.get_action_strength(down_aim) - Input.get_action_strength(up_aim)
	)
	var length = v.length()
	if length < aim_deadzone:
		return Vector2.ZERO
	return v.normalized() * ((length - aim_deadzone) / (1 - aim_deadzone))

func fire():
	#print("fired1")
	if paintball_scene:
		#Input.start_joy_vibration(1, 1.0, 1.0, 0.5)
		#print("fired2")
		var paintball = paintball_scene.instantiate()
		
		# 1. SET ALL PROPERTIES FIRST
		paintball.global_position = $aim_container/spawner.global_position
		paintball.direction = Vector2.RIGHT.rotated(aim_angle)
		if "current_layer" in paintball:
			paintball.current_layer = current_layer
			
		# 2. THEN ADD IT TO THE SCENE LAST
		get_tree().current_scene.add_child(paintball)

func _draw():
	draw_circle(Vector2.ZERO, radius, color)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("fish"):
		die()
	
	
	
func die():
	set_physics_process(false)
	set_process_unhandled_input(false)
	
	$Area2D.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitorable", false)
	
	var death_tween = create_tween().set_parallel(true)
	var duration_in_seconds = 1.5 
	
	death_tween.tween_property(self, "scale", scale * 3.0, duration_in_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	death_tween.tween_property(self, "modulate", Color(1, 0, 0, 0), duration_in_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	death_tween.tween_property(self, "rotation", rotation + (PI * 8), duration_in_seconds)
	death_tween.tween_property(self, "global_position", global_position + Vector2(0, -50), duration_in_seconds).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# --- CHANGED: Call respawn instead of queue_free! ---
	death_tween.chain().tween_callback(respawn)


func respawn():
	# 1. Reset physical position and movement
	global_position = start_position
	velocity = Vector2.ZERO
	rotation = 0
	aim_angle = 0
	health = 270
	
	# 2. Reset visuals (Your update_depth_state function perfectly handles scale and modulate!)
	update_depth_state(true)
	
	# 3. Turn physics and inputs back on
	set_physics_process(true)
	set_process_unhandled_input(true)
	
	# 4. Turn hitboxes back on safely
	$Area2D.set_deferred("monitoring", true)
	$Area2D.set_deferred("monitorable", true)
