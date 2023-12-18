class_name EntityStats

signal name_changed(new_name)
var name:String = "" : set = _set_name
func _set_name(value):
	if name != value:
		name = str(value)
		emit_signal("name_changed", name)

signal maxHP_changed(new_maxHP:int)
var maxHP:int = 0 : set = _set_maxHP
func _set_maxHP(value):
	if maxHP != value:
		maxHP = maxi(0, value)
		emit_signal("maxHP_changed", maxHP)

signal hp_changed(new_hp:int)
var hp:int = 0 : set = _set_hp
func _set_hp(value):
	if hp != value:
		hp = clampi(value, 0, maxHP)
		emit_signal("hp_changed", hp)

signal maxMP_changed(new_maxMP:int)
var maxMP:int = 0 : set = _set_maxMP
func _set_maxMP(value):
	if maxMP != value:
		maxMP = maxi(0, value)
		emit_signal("maxMP_changed", maxMP)

signal mp_changed(new_mp:int)
var mp:int = 0 : set = _set_mp
func _set_mp(value):
	if mp != value:
		mp = clampi(value, 0, maxMP)
		emit_signal("mp_changed", mp)

signal died(partyIndex:int)

var atk:Vector2i = Vector2i(0,0)
var speed:int = 0

var turn:int = 0

var sprite:AnimatedSprite2D

func _init()->void:
	name = "Name"
	maxHP = randi_range(2,6)
	hp = maxHP
	maxMP = randi_range(2,6)
	mp = maxMP
	atk.x = randi_range(1,3)
	atk.y = randi_range(4,6)
	speed = randi_range(1,5)

	turn = 0
