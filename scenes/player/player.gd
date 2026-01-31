extends Node2D
class_name Player

@export var speed = 600
@export var hit_box: Area2D
@export var attack_speed = 5.0
@export var attack_animation: AnimationPlayer
@export var attack_damage = 10
@export var health_component: HealthComponent
@export var attack_shape: Attack
@export var dash_speed = 4.5
@export var dash_dur = .25
@export var player_sprite: AnimatedSprite2D


var can_move = false
var facing_direction = 1
var last_direction:Vector2
var speed_mod = 1
var dash_time = 0

func do_entrance():	
	attack_animation.play("entrance")
	player_sprite.play("entrance")
	await attack_animation.animation_finished
	player_sprite.play("hood")
	await player_sprite.animation_finished
	await Utils.wait(3)
	can_move = true
	
func _physics_process(delta: float) -> void:
	if not can_move:
		return 
		
	var direction:Vector2
	var actual_speed = speed
	if dash_time >= 0:
		direction = last_direction
		actual_speed *= dash_speed
		dash_time -= delta
	else:
		direction = Input.get_vector("left","right", "up", "down")
	
	global_position += direction * actual_speed * delta
	
	if direction.length() > 0.1:
		last_direction = direction
		if direction.x > 0:
			facing_direction = -1
		if direction.x < 0:
			facing_direction = 1

		scale.x = facing_direction
		queue_redraw()
	
	var x_size = abs(direction.x)
	var y_size = abs(direction.y)
	
	if is_attacking():
		if y_size > x_size:
			if direction.y < 0:
				player_sprite.play("attack_up")
			else:
				player_sprite.play("attack_down")
		else:
			player_sprite.play("attack_sideways")
	else:
		if y_size > x_size:
			if direction.y < 0:
				player_sprite.play("move_up")
			else:
				player_sprite.play("move_down")
		else:
			player_sprite.play("move_sideways")
	
func _ready() -> void:
	do_entrance()
	hit_box.area_entered.connect(on_took_damage)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if not is_attacking():
			do_attack()
	if event.is_action_pressed("dash"):
		do_dash()
			
func is_attacking() -> bool:
	return attack_animation.is_playing()

func do_dash():
	health_component.i_frames = dash_dur
	dash_time = dash_dur
	
func do_attack():
	
	attack_animation.play("attack", -1, attack_speed)
	
func on_took_damage(area: Area2D) -> void:
	pass
	### TODO: Configure how much damage the player will take
	#health -= 10
	#i_frames = invincibility_time
	#Utils.get_camera().start_shake(5.0, 0.2, 20)
	#
	#if health <= 0:
		### TODO: Configure player death animation or scene
		#queue_free()
