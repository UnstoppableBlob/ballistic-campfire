extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _draw():
	draw_arc(Vector2.ZERO, 40, deg_to_rad(0), deg_to_rad(120), 2, Color.AQUAMARINE, 2, true)
