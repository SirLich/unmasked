extends Node2D
class_name Player

@export var speed = 600
@export var hit_box: Area2D
@export var attack_speed = 5.0
@export var attack_animation: AnimationPlayer
@export var attack_damage = 10
@export var health_component: HealthComponent
@export var attack_shape: Attack
@export var dash_speed = 2.5
@export var dash_dur = .10
@export var player_sprite: AnimatedSprite2D

@export var skip_intro_self = false

var can_move = false
var facing_direction = 1
var last_direction:Vector2
var speed_mod = 1
var dash_time = 0

var is_currently_attacking = false

func skip_entrance():
	can_move = true
	
func do_entrance():
	print("DO ENTRANCE")
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
	
	if is_currently_attacking:
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
	if not Global.settings.skip_audio or skip_intro_self:
		do_entrance()
	else:
		skip_entrance()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if not is_currently_attacking:
			do_attack()
	if event.is_action_pressed("dash"):
		do_dash()

func do_dash():
	health_component.i_frames = dash_dur
	dash_time = dash_dur
	
func do_attack():
	print('DO ATTACK')
	is_currently_attacking = true
	attack_shape.process_mode = Node.PROCESS_MODE_ALWAYS
	attack_animation.play("attack", -1, attack_speed)
	await attack_animation.animation_finished
	attack_shape.process_mode = Node.PROCESS_MODE_DISABLED
	is_currently_attacking = false
