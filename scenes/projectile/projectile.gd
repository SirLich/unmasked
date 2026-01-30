extends Node2D
class_name ProjectileComponent

enum ProjectileType {
	## Flies in Arc
	PROJECTILE,
	
	## Flies straight
	BULLET
}

enum ProjectileState {
	PREFIRE,
	FLYING,
	HIT
}

var projectile_state : ProjectileState = ProjectileState.PREFIRE
@export var destroy_on_hit : bool = true

@export var animate_height : bool = true
@export var animate_rotation : bool = true
	
@export var projectile_type : ProjectileType = ProjectileType.PROJECTILE

@export var launch_angle_degrees : float = 65.0  # choose angle

@export_group("Private")
@export var shadow : Node2D
@export var body_shape_component : Node2D
@export var graphics : Node2D

## Bullet vars
var speed = 600
var max_range = 500
@export var multi_phase : bool = false
	
## Configured values
var damage = 1
var original_shadow_size : int
var target_location : Vector2
var starting_location : Vector2

## Shared values
var gravity = 980

## Runtime valyes
var horizontal_velocity : float
var vertical_velocity : float
var height : float = 0.0

signal on_hit_ground(position : Vector2)

func is_arrow_close_to_hitting():
	var is_going_down = vertical_velocity < 0
	var is_close_to_ground = height < 150
	return is_going_down and is_close_to_ground
	
func on_body_entered(body : Node):
	try_damage_actor(body)
	
func on_area_entered(area):
	pass
	#var actor = Utils.get_actor_from_area(area)
	#if actor:
		#try_damage_actor(actor)
	
func try_damage_actor(body):
	pass
	#if is_valid_target(body):
		#body.damage(damage)
		#
		### Single-phase bullets are destroyed on hit.
		#if not multi_phase:
			#destroy_projectile()

func destroy_projectile():
	if destroy_on_hit:
		get_parent().queue_free()
	
func configure(target_loc : Vector2):
	#targets = valid_targets
	
	if shadow:
		original_shadow_size = shadow.shadow_size
	
	starting_location = global_position
	target_location = target_loc
	
	var distance = target_location.distance_to(global_position)
	
	# Convert angle to radians
	var theta = deg_to_rad(launch_angle_degrees)
	
	# Calculate required initial speed
	var velocity = sqrt((distance * gravity) / sin(2.0 * theta))
	
	# Decompose into components
	horizontal_velocity = velocity * cos(theta)
	vertical_velocity = velocity * sin(theta)
	
	height = 0.0

func fire():
	projectile_state = ProjectileState.FLYING
	
func _process(delta: float) -> void:
	if projectile_state == ProjectileState.FLYING:
		var shadow_size_factor = 20.0
		if shadow:
			shadow.shadow_size = original_shadow_size - (height / shadow_size_factor)
		
		var direction = (target_location - starting_location).normalized()

		# --- Rotate graphics along trajectory ---
		if animate_rotation:
			if projectile_type == ProjectileType.PROJECTILE:
				var velocity_vec = direction * horizontal_velocity + Vector2(0, -vertical_velocity)
				if velocity_vec.length() > 0.001:
					graphics.rotation = velocity_vec.angle()
			else:
				graphics.rotation = starting_location.direction_to(target_location).angle() + PI/2
		
	
func _physics_process(delta: float) -> void:
	if projectile_state == ProjectileState.FLYING:
		if projectile_type == ProjectileType.PROJECTILE:
			move_projectile(delta)
		elif projectile_type == ProjectileType.BULLET:
			move_bullet(delta)
		else:
			push_error("Did you update ProjectileType recently?")

func move_bullet(delta: float):
	var direction = starting_location.direction_to(target_location)
	get_parent().global_position += direction * speed * delta
	
	if starting_location.distance_to(get_parent().global_position) > max_range + 30: ## A bit of leeway
		destroy_projectile()
	
func move_projectile(delta: float):
	# --- Horizontal shadow movement ---
	var direction = (target_location - starting_location).normalized()
	get_parent().global_position += direction * horizontal_velocity * delta
	
	# --- Vertical arc ---
	height += vertical_velocity * delta
	vertical_velocity -= gravity * delta
	
	# Apply height visually
	graphics.position.y = -height   # negative so upward = up
	
	if height < 0:
		on_hit_ground.emit(global_position)
		destroy_projectile()
		projectile_state = ProjectileState.HIT
