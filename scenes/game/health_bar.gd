extends ProgressBar

func _ready() -> void:
	Global.enemy_took_damage.connect(enemy_damage)
	Global.fight_started.connect(fight_started)
	
func enemy_damage(new_percent):
	value = new_percent

func fight_started(f):
	value = 1
