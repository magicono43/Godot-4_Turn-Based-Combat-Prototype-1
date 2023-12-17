class_name EntityStats

signal name_changed(new_name)
var name:String = "" : set = _set_name
func _set_name(value):
	if name != value:
		name = str(value)
		emit_signal("name_changed", name)

signal hp_changed(new_hp:int)
var hp:int = 0 : set = _set_hp
func _set_hp(value):
	if hp != value:
		hp = clampi(value, 0, maxHP)
		emit_signal("hp_changed", hp)

signal maxHP_changed(new_maxHP:int)
var maxHP:int = 0 : set = _set_maxHP
func _set_maxHP(value):
	if maxHP != value:
		maxHP = maxi(0, value)
		emit_signal("maxHP_changed", maxHP)

signal died(partyIndex:int)

var atk:Vector2i = Vector2i(0,0)
var speed:int = 0

var turn:int = 0

var sprite:AnimatedSprite2D

func _init()->void:
	name = "Name"
	maxHP = randi_range(2,6)
	hp = maxHP
	atk.x = randi_range(1,3)
	atk.y = randi_range(4,6)
	speed = randi_range(1,5)

	turn = 0
