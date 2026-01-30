extends Node2D
class_name Player

@export var speed = 600
@export var hit_box: Area2D
@export var attack_speed = 5.0
@export var attack_animation: AnimationPlayer
@export var attack_damage = 10
@export var health_component: HealthComponent
@export var attack_shape: Attack

var facing_direction = 1

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left","right", "up", "down")
	global_position += direction * speed * delta
		
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
			do_attack()
			
func is_attacking() -> bool:
	return attack_animation.is_playing()

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
