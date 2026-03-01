##extends AnimatedSprite2D
##
##@export var id = 1
##
##var health = 10
##var max_health = 10
##
##func _ready():
	##$TextureProgressBar.max_value = max_health
	##$TextureProgressBar.value = health
##
##func _on_area_2d_area_entered(area: Area2D) -> void:
	##if id == 1:
		##if area.get_parent().is_in_group("fish-1"):
			##
			###print(health)
			##health -= 1
			##print(health)
			##area.get_parent().queue_free()
			##$TextureProgressBar.value = health
			##
			##if health <= 0:
				##destroy()
		##
	##if id == 2:
		##if area.get_parent().is_in_group("fish-2"):
			###print(health)
			##health -= 1
			##print(health)
			##$TextureProgressBar.value = health
			##
			##if health <= 0:
				##destroy()
				##
				##
	##if id == 3:
		##if area.get_parent().is_in_group("fish-3"):
			###print(health)
			##health -= 1
			##print(health)
			##$TextureProgressBar.value = health
			##
			##if health <= 0:
				##destroy()
		##
		##
		##
##func destroy():
	### 1. Turn off the hitbox immediately so we don't trigger destroy() again while flashing
	##$Area2D.set_deferred("monitoring", false)
	##$Area2D.set_deferred("monitorable", false)
	##
	### 2. Hide the health bar so only the castle sprite flashes
	##$TextureProgressBar.hide()
	##
	### 3. Setup our flashing variables
	##var flash_delay = 0.4      # Start with a slow 0.4 second delay
	##var minimum_delay = 0.04   # Cap the fastest flash at 0.04 seconds so it doesn't break
	##var speed_up_factor = 0.8  # Multiply the delay by this each loop to shrink the time
	##
	### 4. Loop 15 times to create the sequence
	##for i in range(15):
		##visible = not visible # Toggle between true and false
		##
		### Wait for the current delay time
		##await get_tree().create_timer(flash_delay).timeout
		##
		### Shrink the delay for the next loop, stopping at our minimum limit
		##flash_delay = max(flash_delay * speed_up_factor, minimum_delay)
##
	### 5. Ensure it's invisible at the very end
	##visible = false
	##
	### Optional: Add a tiny pause here before deleting it for dramatic timing
	##await get_tree().create_timer(0.2).timeout 
	##
	### 6. Finally, delete the castle from the game
	##queue_free()
#
#
#extends AnimatedSprite2D
#
#@export var id = 1
#
#var health = 10
#var max_health = 10
#
#func _ready():
	#$TextureProgressBar.max_value = max_health
	#$TextureProgressBar.value = health
	#
	## --- NEW: Sync the Castle to its specific layer! ---
	## Turn off the default Layer 1
	#$Area2D.set_collision_layer_value(1, false)
	#$Area2D.set_collision_mask_value(1, false)
	#
	## Turn on the layer that perfectly matches this Castle's ID
	#$Area2D.set_collision_layer_value(id, true)
	#$Area2D.set_collision_mask_value(id, true)
#
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#if id == 1:
		#if area.get_parent().is_in_group("fish-1"):
			#health -= 1
			#area.get_parent().queue_free()
			#$TextureProgressBar.value = health
			#if health <= 0:
				#destroy()
		#
	#elif id == 2:
		#if area.get_parent().is_in_group("fish-2"):
			#health -= 1
			#area.get_parent().queue_free() # <--- Added this back!
			#$TextureProgressBar.value = health
			#if health <= 0:
				#destroy()
				#
	#elif id == 3:
		#if area.get_parent().is_in_group("fish-3"):
			#health -= 1
			#area.get_parent().queue_free() # <--- Added this back!
			#$TextureProgressBar.value = health
			#if health <= 0:
				#destroy()
		#
#func destroy():
	#$Area2D.set_deferred("monitoring", false)
	#$Area2D.set_deferred("monitorable", false)
	#$TextureProgressBar.hide()
	#
	#var flash_delay = 0.4      
	#var minimum_delay = 0.04   
	#var speed_up_factor = 0.8  
	#
	#for i in range(15):
		#visible = not visible 
		#await get_tree().create_timer(flash_delay).timeout
		#flash_delay = max(flash_delay * speed_up_factor, minimum_delay)
#
	#visible = false
	#await get_tree().create_timer(0.2).timeout 
	#queue_free()


extends AnimatedSprite2D

@export var id = 1

var health = 10
var max_health = 10

func _ready():
	$TextureProgressBar.max_value = max_health
	$TextureProgressBar.value = health
	
	# --- PERFECT LAYER SYNC ---
	# This loop forces the Castle to ONLY exist on the collision layer 
	# that perfectly matches its ID. (Castle 2 = Layer 2).
	for i in range(1, 4):
		var is_current = (i == id)
		$Area2D.set_collision_layer_value(i, is_current)
		$Area2D.set_collision_mask_value(i, is_current)

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Get the root node of whatever just hit us
	var fish = area.get_parent()
	
	# 1. Check if the object that hit us actually has a "layer" variable
	if "layer" in fish:
		
		# 2. Check if the fish's layer perfectly matches this Castle's ID
		if fish.layer == id:
			
			# It's a match! Take damage and delete the fish.
			health -= 1
			print("Castle ", id, " took damage! Health: ", health)
			
			fish.queue_free()
			$TextureProgressBar.value = health
			
			if health <= 0:
				destroy()

func destroy():
	$Area2D.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitorable", false)
	$TextureProgressBar.hide()
	
	var flash_delay = 0.4      
	var minimum_delay = 0.04   
	var speed_up_factor = 0.8  
	
	for i in range(15):
		visible = not visible 
		await get_tree().create_timer(flash_delay).timeout
		flash_delay = max(flash_delay * speed_up_factor, minimum_delay)

	visible = false
	await get_tree().create_timer(0.2).timeout 
	
	queue_free()
