extends EntityStats
class_name AllyStats

func _init()->void:
	Glo.allyCounter += 1
	name = "Ally" + str(Glo.allyCounter)
	maxHP = randi_range(3,9)
	hp = maxHP
	maxMP = randi_range(0,1)
	mp = maxMP
	atk.x = randi_range(1,3)
	atk.y = randi_range(4,6)
	speed = randi_range(1,5)
