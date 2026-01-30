extends Node2D
class_name Player

@export var speed = 600
@export var hit_box: Area2D
@export var max_health = 100
@export var attack_speed = 5.0
@export var attack_animation: AnimationPlayer

## How long the player is invincible, in seconds
@export var invincibility_time = 0.5
@onready var health = max_health
var i_frames = 0
var facing_direction = 1

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left","right", "up", "down")
	global_position += direction * speed * delta
	
	if is_invincible():
		i_frames -= delta
		
	if direction.length() > 0.1:
		if direction.x > 0:
			facing_direction = -1
		if direction.x < 0:
			facing_direction = 1
		scale.x = facing_direction
		queue_redraw()

	
func _ready() -> void:
	hit_box.area_entered.connect(on_took_damage)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if not is_attacking():
			attack_animation.play("attack", -1, attack_speed)
			
func is_attacking() -> bool:
	return attack_animation.is_playing()
	
func is_invincible():
	return i_frames > 0
	
func on_took_damage(area: Area2D) -> void:
	## TODO: Configure how much damage the player will take
	health -= 10
	i_frames = invincibility_time
	Utils.get_camera().start_shake(5.0, 0.2, 20)
	
	if health <= 0:
		## TODO: Configure player death animation or scene
		queue_free()
