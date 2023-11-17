extends Node2D

var alignment = Vector2(0,0)

class RigidBody2DDemoGamepad extends RigidBody2D:	
	@onready var camera: Camera2D = Camera2D.new()
	@onready var label: Label  = Label.new()
	@onready var force: Vector2 = Vector2(0, 0)
	
	func _ready():
		add_child(camera)
		add_child(label)
		camera.make_current()
		
		gravity_scale = 0
		linear_damp = 0.5
		
	func _input(event):
		if event is InputEventJoypadMotion:
			var tforce = event.axis_value
			if abs(tforce) < 0.5:
				tforce = 0
			else:
				tforce = tforce * 100000
			if event.axis == JOY_AXIS_LEFT_X:
				force.x = tforce
			else:
				force.y = tforce

	func _process(delta):
		label.text = "(%0.2f,%0.2f)" % [position.x, position.y]
		apply_force(force * delta)
		queue_redraw()
		
	func _draw():
		draw_line(Vector2(), linear_velocity, "#f00", log(linear_velocity.length()))
		draw_circle(Vector2(), 16, "#f80")

@onready var dummy: RigidBody2DDemoGamepad = RigidBody2DDemoGamepad.new()

func _ready():
	RenderingServer.set_default_clear_color("#000")
	get_viewport().size = Vector2(800, 600)	
	add_child(dummy)
	
func _process(_delta):
	var new_alignment = dummy.position.snapped(Vector2(200, 200))
	if alignment != new_alignment:
		alignment = new_alignment
		queue_redraw()
	
func _draw():
	for i in range(-8, 8):
		draw_line(alignment  + Vector2(i * 100, -600), alignment + Vector2(i * 100, 600), "#fff")
	for j in range(-6, 6):
		draw_line(alignment + Vector2(-800, j * 100), alignment + Vector2(800, j * 100), "#fff")
