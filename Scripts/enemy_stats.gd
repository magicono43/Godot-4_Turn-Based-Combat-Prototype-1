extends EntityStats
class_name EnemyStats

func _init()->void:
	Glo.enemyCounter += 1
	name = "Enemy" + str(Glo.enemyCounter)
	maxHP = randi_range(2,7)
	hp = maxHP
	maxMP = randi_range(0,1)
	mp = maxMP
	atk.x = randi_range(1,2)
	atk.y = randi_range(3,4)
	speed = randi_range(1,5)
