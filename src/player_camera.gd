extends Camera2D
class_name PlayerCamera

@export var allow_camera_control : bool = true

@export var zoom_speed : float = 0.05
@export var min_zoom : float = 0.001
@export var max_zoom : float = 2.0
@export var drag_sensitivity : float = 1.0

var shake_time: float = 0.0
var shake_intensity: float = 0.0
var shake_frequency: float = 0.0
var time_passed: float = 0.0
var original_offset: Vector2

func _ready():
	original_offset = offset

func _physics_process(delta: float) -> void:
	var pos = Utils.get_player().global_position + Vector2(0, -200)
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos, 0.2)
	
func _process(delta: float) -> void:
	if shake_time > 0.0:
		shake_time -= delta
		time_passed += delta * shake_frequency

		var shake_offset = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * shake_intensity

		offset = original_offset + shake_offset
	else:
		offset = original_offset

func start_shake(intensity: float, duration: float, frequency: float = 20.0) -> void:
	shake_intensity = intensity
	shake_time = duration
	shake_frequency = frequency
	time_passed = 0.0
	
