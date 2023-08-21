extends Node2D

const BULLET_SPEED = 300 # set to > 10,000 to ensure raycast's are required

class Bullet extends Node2D:
	var direction: Vector2
	var speed: float
	
	func _init(direction: Vector2, speed: float = BULLET_SPEED):
		self.direction = direction.normalized()
		self.speed = speed
	
	func _process(delta):
		var next = global_position + direction * delta * speed
		
		# Bullets may skip collision objects, so we need a raycast here.
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, next)
		query.collide_with_areas = true
		
		var result = space_state.intersect_ray(query)
		
		if result:
			if result.collider is Enemy:
				result.collider.hit()
			queue_free()
		
		global_position = next
	
	func _draw():
		draw_circle(Vector2(), 8, "#f00")

class Enemy extends Area2D:
	class EnemySprite extends Node2D:
		func _draw():
			draw_circle(Vector2(), 8, "#0f0")
			
	func hit():
		queue_free()
	
	func _process(delta):
		global_position = global_position.move_toward(Vector2(), delta * 10)

	func _ready():
		position = Vector2(randf_range(150,500), 0).rotated(randf_range(0,360))
		
		var collision_shape_wrapper = CollisionShape2D.new()
		collision_shape_wrapper.shape = CircleShape2D.new()
		(collision_shape_wrapper.shape as CircleShape2D).radius = 16
		add_child(collision_shape_wrapper)
		add_child(EnemySprite.new())

class Player extends StaticBody2D:
	var reload: float = 0

	func _ready():
		add_child(Camera2D.new())

	func _input(event):
		if event is InputEventKey:
			if event.keycode == 32:
				shoot_circle()
		if event is InputEventMouseButton:
			shoot_to(get_global_mouse_position())
	
	func shoot_circle():
		if reload <= 0:
			for j in range(360):
				var bullet = Bullet.new(Vector2(1,0).rotated(j))
				add_child(bullet)
			reload = 0.1

	func shoot_to(target: Vector2):
		if reload <= 0:
			var bullet = Bullet.new(target)
			add_child(bullet)
			reload = 0.1

	func _process(delta):
		reload -= delta

	func _draw():
		draw_circle(Vector2(), 16, "#f80")

func _ready():
	RenderingServer.set_default_clear_color("#000")
	get_viewport().size = Vector2(800, 600)	
	add_child(Player.new())
	
	var timer = Timer.new()
	add_child(timer)	
	timer.connect("timeout", func(): add_child(Enemy.new()))
	timer.start(0.25)

func _draw():
	for i in range(-8, 8):
		draw_line(Vector2(i * 100, -600), Vector2(i * 100, 600), "#fff")
	for j in range(-6, 6):
		draw_line(Vector2(-800, j * 100), Vector2(800, j * 100), "#fff")
