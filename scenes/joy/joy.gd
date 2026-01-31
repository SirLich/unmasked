extends Node2D
class_name Joy

var phase = JoyPhase.MOVE

@export var move_speed = 200
@export var damage_marker_prototype : PackedScene
@export var small_jump_distance = 200
@export var small_jump_delay = 0.5
@export var animation_player: AnimationPlayer

@export_group("Components")
@export var jump_projectile: ProjectileComponent
@export var big_jump_timer: Timer

enum JoyPhase {
	IDLE,
	MOVE,
	BIG_JUMP
}

func _ready() -> void:
	await Utils.wait(1)
	for i in range(100):
		await do_small_jump()
	
func _physics_process(delta: float) -> void:
	if phase == JoyPhase.IDLE:
		pass
	elif phase == JoyPhase.MOVE:
		do_move(delta)


func do_move(delta):
	var player_direction = global_position.direction_to(Utils.get_player().global_position)
	global_position += player_direction * delta * move_speed

func do_idle():
	phase = JoyPhase.IDLE
	await Utils.wait(1.0)
	do_big_jump()
	
func do_small_jump():
	phase = JoyPhase.IDLE
	var dir = self.global_position.direction_to(Utils.get_player().global_position)
	var pos = self.global_position + (dir * small_jump_distance)
	jump_projectile.configure(pos)
	jump_projectile.fire()
	await jump_projectile.on_hit_ground
	animation_player.play("small_jump_attack")
	await Utils.wait(small_jump_delay)

func do_big_jump():
	phase = JoyPhase.BIG_JUMP
	var attack_pos = Utils.get_player().global_position
	var new_damage_marker = damage_marker_prototype.instantiate() as Node2D
	add_sibling(new_damage_marker)
	new_damage_marker.global_position = attack_pos
	
	await Utils.wait(2.0)
	jump_projectile.configure(attack_pos)
	jump_projectile.fire()
	
	new_damage_marker.queue_free()
	phase = JoyPhase.IDLE
	
	await jump_projectile.on_hit_ground
	do_idle()
	
	
		
		
