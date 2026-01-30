extends Area2D
class_name HitBox

@export var contact_damage = 10

func _ready() -> void:
	area_entered.connect(on_took_damage)
	
func on_took_damage(area: Area2D) -> void:
	var damage = 0
	var attack = area as Attack
	if attack:
		damage = attack.damage
	var hit_box = area as HitBox
	if hit_box:
		damage = hit_box.contact_damage
		
	var health_component = Utils.get_component_by_type(get_parent(), HealthComponent) as HealthComponent
	health_component.take_damage(damage)
