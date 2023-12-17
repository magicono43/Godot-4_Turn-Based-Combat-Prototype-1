extends AnimatedSprite2D

@export var deathSound:AudioStreamPlayer

var stats:EntityStats

func _init()->void:
	stats = EnemyStats.new()
	stats.connect("died", _on_death)

func _on_death(index:int):
	Glo.enemyParty.remove_at(index)
	PlayDeathAnimation()
	await get_tree().create_timer(1.5).timeout
	queue_free()

func PlayDeathAnimation()->void:
	deathSound.play()
	var alpha:float = 1.0
	while alpha > 0:
		await get_tree().create_timer(0.02).timeout
		alpha -= 0.04
		modulate = Color(1, 1, 1, alpha)
