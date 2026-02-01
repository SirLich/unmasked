extends Node2D
class_name Player

@export var speed = 600
@export var hit_box: Area2D
@export var attack_speed = 10.0
@export var attack_animation: AnimationPlayer
@export var attack_damage = 10
@export var health_component: HealthComponent
@export var attack_shape: Attack
@export var dash_speed = 2.5
@export var dash_dur = .10
@export var player_sprite: AnimatedSprite2D

@export var skip_intro_self = false
@export var player_attack_sound : AudioStream

var can_move = false
var facing_direction = 1
var last_direction:Vector2
var speed_mod = 1
var dash_time = 0
enum AnimDirection {
	UP,
	DOWN,
	SIDEWAYS,
	IDLE
}
var current_anim_direction = AnimDirection.SIDEWAYS

var is_currently_attacking = false

func skip_entrance():
	can_move = true
	
func do_entrance():
	attack_animation.play("entrance")
	player_sprite.play("entrance")
	await attack_animation.animation_finished
	player_sprite.play("hood")
	await player_sprite.animation_finished
	await Utils.wait(3)
	can_move = true
	
func get_anim_direction(direction: Vector2) -> AnimDirection:
	var anim_direction = AnimDirection.SIDEWAYS
	var x_size = abs(direction.x)
	var y_size = abs(direction.y)
	
	if y_size > x_size:
		if direction.y < 0:
			anim_direction = AnimDirection.UP
		else:
			anim_direction = AnimDirection.DOWN
			
	return anim_direction
	
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
	
	current_anim_direction = get_anim_direction(last_direction)
	
	if is_currently_attacking:
		if current_anim_direction == AnimDirection.UP:
			player_sprite.play("attack_up")
		elif current_anim_direction == AnimDirection.DOWN:
			player_sprite.play("attack_down")
		else:
			player_sprite.play("attack_sideways")
	else:
		if current_anim_direction == AnimDirection.UP:
			player_sprite.play("move_up")
		elif current_anim_direction == AnimDirection.DOWN:
			player_sprite.play("move_down")
		else:
			player_sprite.play("move_sideways")
	
func _ready() -> void:
	health_component.died.connect(died)
	if not Global.settings.skip_audio and not skip_intro_self:
		do_entrance()
	else:
		skip_entrance()

func died():
	print("Player died")
	can_move = false
	player_sprite.play("die")
	SoundManager.stop_music(3.0)
	await Utils.wait(3.0)
	Global.player_dead.emit()
	await Utils.wait(3)
	player_sprite.play("move_down")
	health_component.heal_full()
	Utils.get_first_of_type(VoiceOverManager).play_music()

	can_move = true
	
	global_position += Vector2(0, -500)
	
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
	SoundManager.play_sound(player_attack_sound)
	is_currently_attacking = true
	attack_shape.process_mode = Node.PROCESS_MODE_ALWAYS
	if current_anim_direction == AnimDirection.UP:
		attack_animation.play("attack_up", -1, attack_speed)
	elif current_anim_direction == AnimDirection.DOWN:
		attack_animation.play("attack_down", -1, attack_speed)
	else:
		attack_animation.play("attack", -1, attack_speed)
	await attack_animation.animation_finished
	attack_shape.process_mode = Node.PROCESS_MODE_DISABLED
	await Utils.wait(0.4)
	is_currently_attacking = false
