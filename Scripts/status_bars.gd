extends VBoxContainer

@onready var entity:AnimatedSprite2D = get_parent()
@export var namePlate:Label
@export var hpBar:ProgressBar
@export var mpBar:ProgressBar

var eStats:EntityStats

func _ready() -> void:
	eStats = entity.stats
	namePlate.text = eStats.name
	hpBar.max_value = eStats.maxHP
	hpBar.value = eStats.hp
	mpBar.max_value = eStats.maxMP
	mpBar.value = eStats.mp
	position = Vector2(-23,-50)
	if eStats.maxMP <= 0: NoManaBar()
	eStats.connect("name_changed", _on_name_changed)
	eStats.connect("maxHP_changed", _on_maxHP_changed)
	eStats.connect("hp_changed", _on_hp_changed)
	eStats.connect("maxMP_changed", _on_maxMP_changed)
	eStats.connect("mp_changed", _on_mp_changed)

func NoManaBar()->void:
	mpBar.hide()
	hpBar.size_flags_stretch_ratio = 0.45
	position = Vector2(-23,-61)

func _on_name_changed(new_name):
	namePlate.text = new_name

func _on_maxHP_changed(new_maxHP:int):
	hpBar.max_value = new_maxHP

func _on_hp_changed(new_hp:int):
	hpBar.value = new_hp

func _on_maxMP_changed(new_maxMP:int):
	mpBar.max_value = new_maxMP

func _on_mp_changed(new_mp:int):
	mpBar.value = new_mp
