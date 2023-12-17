extends ProgressBar

@onready var entity:AnimatedSprite2D = get_parent()
@onready var namePlate:Label = get_child(0)

var eStats:EntityStats

func _ready() -> void:
	eStats = entity.stats
	namePlate.text = eStats.name
	max_value = eStats.maxHP
	value = eStats.hp
	position = Vector2(-23,-30)
	eStats.connect("name_changed", _on_name_changed)
	eStats.connect("maxHP_changed", _on_maxHP_changed)
	eStats.connect("hp_changed", _on_hp_changed)

func _on_name_changed(new_name):
	namePlate.text = new_name

func _on_maxHP_changed(new_maxHP:int):
	max_value = new_maxHP

func _on_hp_changed(new_hp:int):
	value = new_hp
