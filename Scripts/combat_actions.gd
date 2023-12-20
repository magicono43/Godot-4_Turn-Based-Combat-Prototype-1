extends HBoxContainer

@export var CombatActionsButtons:VBoxContainer
@export var attackButton:Button
@export var magicButton:Button
@export var passButton:Button
@export var ActionSubMenu:ScrollContainer
@export var SubMenu:VBoxContainer
@export var SubMenuHeaderLabel:Label
@export var ItemListNode:ItemList

@onready var mainNode:Node2D = $".."

var actions:Array
var spells:Array
var inSubMenu:bool = false
var subMenuIndex:int = 0

func _ready() -> void:
	actions = CombatActionsButtons.get_children()
	spells = ["Heal","Fire","Lightning","Ice","Earth","Heart"]
	visibility_changed.connect(GrabFocus_OnChangedVisibility)
	ActionSubMenu.visibility_changed.connect(SelectFirstItem_OnChangedVisibility)

func GrabFocus_OnChangedVisibility()->void:
	attackButton.grab_focus()

func SelectFirstItem_OnChangedVisibility()->void:
	if subMenuIndex <= 0:
		ItemListNode.deselect_all()
		ItemListNode.select(0)

func ShiftActionSelection(up:bool)->void:
	if inSubMenu: return
	var min:int = 0
	var max:int = CombatActionsButtons.get_child_count() - 1
	if not up:
		if mainNode.combat.actionSelectIndex+1 > max: mainNode.combat.actionSelectIndex = min
		else: mainNode.combat.actionSelectIndex += 1
	else:
		if mainNode.combat.actionSelectIndex-1 < min: mainNode.combat.actionSelectIndex = max
		else: mainNode.combat.actionSelectIndex -= 1
	mainNode.changeSelectSound.play()
	actions[mainNode.combat.actionSelectIndex].grab_focus()

func ShiftSubMenuSelection(up:bool)->void:
	if not inSubMenu: return
	var min:int = 0
	var max:int = ItemListNode.item_count - 1
	if not up:
		if subMenuIndex+1 > max: subMenuIndex = min
		else: subMenuIndex += 1
	else:
		if subMenuIndex-1 < min: subMenuIndex = max
		else: subMenuIndex -= 1
	#TODO Continue working on implementing spells and such tomorrow.
	# Likely make a new "Spells" class or something, then just have the
	# actual spells inherit from that, similar to the "entity" thing, will see.
	#var items:Array[String] = []
	#for r:int in ItemListNode.item_count:
		#var itemText:String = ItemListNode.get_item_text(r)
		#if not itemText.is_empty():
			#items.append(itemText)
	mainNode.changeSelectSound.play()
	ItemListNode.deselect_all()
	ItemListNode.select(subMenuIndex)
	ItemListNode.ensure_current_is_visible()

func TargetSelectOrSubmenu()->void:
	var action:int = mainNode.combat.actionSelectIndex
	if action == 0: # Attack
		mainNode.combat.pickingAction = false
		visible = false
		mainNode.combat.actionSelectIndex = 0
		if not mainNode.combat.selectedTarget == null:
			mainNode.combat.selectedTarget.get_child(2).visible = true # Selection Cursor
		else:
			mainNode.combat.selectedTarget = Glo.enemyParty[0]
			mainNode.combat.selectedTarget.get_child(2).visible = true # Selection Cursor
		mainNode.changeSelectSound.play()
	elif action == 1: # Magic, nothing for now
		inSubMenu = true
		ActionSubMenu.visible = true
		ItemListNode.grab_focus()
		mainNode.changeSelectSound.play()
	else: # Pass
		mainNode.combat.playerTurn = false
		mainNode.combat.pickingAction = false
		visible = false
		mainNode.combat.actionSelectIndex = 0
		mainNode.changeSelectSound.play()
		await get_tree().create_timer(0.4).timeout
		mainNode.combat.emit_signal("turn_ended")

func UnconfirmAction()->void:
	if inSubMenu:
		inSubMenu = false
		ActionSubMenu.visible = false
		actions[mainNode.combat.actionSelectIndex].grab_focus()
		mainNode.changeSelectSound.play()
	else:
		mainNode.combat.pickingAction = true
		visible = true
		mainNode.combat.selectedTarget.get_child(2).visible = false # Selection Cursor
		mainNode.combat.selectionIndex = 0
		mainNode.combat.selectedTarget = null
		mainNode.changeSelectSound.play()
