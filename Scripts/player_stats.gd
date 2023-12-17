extends EntityStats
class_name PlayerStats

func _init()->void:
	name = "Player"
	maxHP = randi_range(5,11)
	hp = maxHP
	atk.x = randi_range(1,4)
	atk.y = randi_range(5,8)
	speed = randi_range(1,5)
