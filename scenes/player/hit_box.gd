extends Area2D
class_name HitBox

@export var contact_damage = 10
@export var contact_knockback = 200
@export var take_knockback = true

func _ready() -> void:
	area_entered.connect(on_took_damage)
	
func on_took_damage(area: Area2D) -> void:
	var damage = 0
	var attack = area as Attack
	var knockback = 0
	if attack:
		damage = attack.damage
		knockback = attack.knockback
	var hit_box = area as HitBox
	if hit_box:
		knockback = hit_box.contact_knockback
		damage = hit_box.contact_damage
		
	if damage == 0:
		return
		
	var health_component = Utils.get_component_by_type(get_parent(), HealthComponent) as HealthComponent
	health_component.take_damage(damage)
	
	if take_knockback and not health_component.invulnerable:
		print("taking knockback")
		var parent = get_parent() as Node2D
		var dir = area.global_position.direction_to(parent.global_position)
		var knockback_power = knockback
		var tween = get_tree().create_tween()
		var loc = parent.global_position + (dir * knockback_power)
		tween.tween_property(parent, "global_position", loc, 0.2)
