extends Control

signal combat_ended
signal round_ended
signal turn_ended
signal you_lost
signal you_won
signal target_shifted(right:bool)
signal target_confirmed

@export var panel:Panel
@export var arena:TileMap
@export var changeSelectSound:AudioStreamPlayer
@export var confirmSelectSound:AudioStreamPlayer
@export var aiAttackSound:AudioStreamPlayer
@export var roundNumText:Label
@export var turnNumText:Label
@export var arenaText:Label
@export var combatActionUI:HBoxContainer
@export var damText:Sprite2D

var roundNum:int = 0
var turnCnt:int = 0
var turnTaker
var highestTurn:int = 0
var playerTurn:bool = false
var pickingAction:bool = false
var actionSelectIndex:int = 0
var selectionIndex:int = 0
var selectedTarget
var afterCombat:bool = false
var victory:bool = false

func _ready() -> void:
	round_ended.connect(NextRound_OnRoundEnd)
	turn_ended.connect(NextTurn_OnTurnEnded)
	you_lost.connect(ShowLossText_OnLosing)
	you_won.connect(ShowVictoryText_OnWinning)
	target_shifted.connect(TargetSelection_OnSelectionShifted)
	target_confirmed.connect(PerformAction_OnTargetConfirmed)
	set_process_input(false)
	set_process(false)
	set_physics_process(false)
	hide()

func _input(event:InputEvent)->void:
	if event.is_action_pressed("ui_accept"):
		GloFuncs.ClearGlobalVars()
		get_tree().reload_current_scene()

	if afterCombat:
		if event.is_action_released("ui_up"):
			if victory:
				ResetCombatVariables()
				emit_signal("combat_ended")
			else:
				GloFuncs.ClearGlobalVars()
				get_tree().reload_current_scene()
	else:
		if event.is_action_released("ui_end"):
			HurtEveryone()

		if playerTurn:
			if pickingAction:
				if combatActionUI.inSubMenu:
					if event.is_action_released("ui_down"):
						combatActionUI.ShiftSubMenuSelection(false)
					elif event.is_action_released("ui_up"):
						combatActionUI.ShiftSubMenuSelection(true)
					elif event.is_action_released("ui_left"):
						combatActionUI.UnconfirmAction()
				else:
					if event.is_action_released("ui_down"):
						combatActionUI.ShiftActionSelection(false)
					elif event.is_action_released("ui_up"):
						combatActionUI.ShiftActionSelection(true)
					elif event.is_action_released("ui_right"):
						combatActionUI.TargetSelectOrSubmenu()
			else:
				if event.is_action_released("ui_left"):
					emit_signal("target_shifted", false)
				elif event.is_action_released("ui_right"):
					emit_signal("target_shifted", true)
				elif event.is_action_released("ui_down"):
					emit_signal("target_confirmed")
				elif event.is_action_released("ui_up"):
					combatActionUI.UnconfirmAction()

func ResetCombatVariables()->void:
	roundNum = 0
	turnCnt = 0
	turnTaker = null
	highestTurn = 0
	playerTurn = false
	pickingAction = false
	actionSelectIndex = 0
	selectionIndex = 0
	selectedTarget = null
	afterCombat = false
	victory = false
	arenaText.visible = false

func SetupCombat()->void:
	DrawCombatants()
	roundNumText.text = "Round: " + str(roundNum)
	turnNumText.text = "Turn: " + str(turnCnt)
	await get_tree().create_timer(0.8).timeout
	emit_signal("round_ended")

func ShowLossText_OnLosing()->void:
	afterCombat = true
	victory = false
	await get_tree().create_timer(0.4).timeout
	var party:Node2D = arena.get_node("PlayerParty")
	party.queue_free()
	arenaText.text = "Defeat..."
	arenaText.visible = true

func ShowVictoryText_OnWinning()->void:
	afterCombat = true
	victory = true
	Glo.enemyCounter = 0
	await get_tree().create_timer(0.4).timeout
	var party:Node2D = arena.get_node("EnemyParty")
	party.queue_free()
	arenaText.text = "Victory!"
	arenaText.visible = true

func NextRound_OnRoundEnd():
	turnCnt = 0
	roundNum += 1
	roundNumText.text = "Round: " + str(roundNum)
	turnNumText.text = "Turn: " + str(turnCnt)
	DetermineTurnOrder()
	emit_signal("turn_ended")

func NextTurn_OnTurnEnded():
	if Glo.party.is_empty(): emit_signal("you_lost"); return
	elif Glo.enemyParty.is_empty(): emit_signal("you_won"); return
	turnCnt += 1
	turnNumText.text = "Turn: " + str(turnCnt)
	if turnCnt > highestTurn: emit_signal("round_ended"); return
	var who = null
	for r:int in Glo.party.size():
		if not who == null: break
		if Glo.party[r].stats.turn == turnCnt: who = Glo.party[r]
	for r:int in Glo.enemyParty.size():
		if not who == null: break
		if Glo.enemyParty[r].stats.turn == turnCnt: who = Glo.enemyParty[r]
	if who == null: emit_signal("turn_ended"); return

	if who.stats is PlayerStats:
		playerTurn = true
		pickingAction = true
	else:
		playerTurn = false
	turnTaker = who
	if playerTurn == false:
		await TakeTurnAI()
		emit_signal("turn_ended"); return
	else:
		if selectionIndex > Glo.enemyParty.size()-1:
			selectionIndex = Glo.enemyParty.size()-1
		selectedTarget = Glo.enemyParty[selectionIndex]
		combatActionUI.position = turnTaker.global_position + Vector2(-20,26)
		combatActionUI.visible = true

func TakeTurnAI():
	var attacker = turnTaker
	var target
	if attacker.stats is AllyStats: target = Glo.enemyParty.pick_random()
	else: target = Glo.party.pick_random()
	var dam:int = randi_range(attacker.stats.atk.x,attacker.stats.atk.y)
	await PlayAttackAnimation(attacker,0.15)
	DamageTarget(target,dam)
	ShowDamageText(target,dam)
	await get_tree().create_timer(0.6).timeout

func DamageTarget(target,dam:int)->void:
	if dam > 0:
		aiAttackSound.play()
	target.stats.hp -= dam
	if target.stats.hp <= 0:
		var partyIndex:int = 0
		if Glo.party.has(target): partyIndex = Glo.party.find(target)
		else: partyIndex = Glo.enemyParty.find(target)
		target.stats.emit_signal("died",partyIndex)

func PlayAttackAnimation(attacker,delay:float)->void:
	for r:int in 4:
		await get_tree().create_timer(delay).timeout
		if attacker.flip_h == true: attacker.flip_h = false
		else: attacker.flip_h = true
	await get_tree().create_timer(0.2).timeout

func ShowDamageText(target,dam:int)->void:
	damText.get_child(0).text = str(-1*dam)
	damText.position = target.global_position
	damText.visible = true
	await get_tree().create_timer(0.7).timeout
	damText.visible = false

func TargetSelection_OnSelectionShifted(right:bool)->void:
	var min:int = 0
	var max:int = Glo.enemyParty.size() - 1
	combatActionUI.visible = false
	if right:
		if selectionIndex+1 > max: selectionIndex = min
		else: selectionIndex += 1
	else:
		if selectionIndex-1 < min: selectionIndex = max
		else: selectionIndex -= 1
	selectedTarget.get_child(2).visible = false # Selection Cursor
	selectedTarget = Glo.enemyParty[selectionIndex]
	selectedTarget.get_child(2).visible = true # Selection Cursor
	changeSelectSound.play()

func PerformAction_OnTargetConfirmed()->void:
	playerTurn = false
	var dam:int = randi_range(turnTaker.stats.atk.x,turnTaker.stats.atk.y)
	selectedTarget.get_child(2).visible = false # Selection Cursor
	PlayAttackAnimation(turnTaker,0.15)
	await get_tree().create_timer(0.9).timeout
	selectedTarget.stats.hp -= dam
	confirmSelectSound.play()
	ShowDamageText(selectedTarget,dam)
	if selectedTarget.stats.hp <= 0:
		selectedTarget.stats.emit_signal("died",selectionIndex)
	await get_tree().create_timer(0.6).timeout
	emit_signal("turn_ended")

func DrawCombatants():
	var offset:float = arena.tile_set.tile_size.x

	for r:int in Glo.party.size():
		var sectionSize:float = 17 / Glo.party.size()
		var member = Glo.party[r]
		member.position = Vector2(2 + (r * sectionSize),5) * offset
		member.flip_h = true
		member.scale = Vector2(2,2)

	for r:int in Glo.enemyParty.size():
		var sectionSize:float = 17 / Glo.enemyParty.size()
		var member = Glo.enemyParty[r]
		member.position = Vector2(20 + (r * sectionSize),5) * offset
		member.scale = Vector2(2,2)

func DetermineTurnOrder():
	var everyone:Array = []
	everyone.append_array(Glo.party)
	everyone.append_array(Glo.enemyParty)
	var finalOrder:Array[int] = []
	finalOrder.resize(everyone.size())
	finalOrder.fill(0)
	var turnRolls:Array[int] = []
	for r:int in everyone.size():
		var roll:int = randi_range(0,5) + everyone[r].stats.speed
		turnRolls.append(roll)

	var orderCnt:int = 0
	var highest:int = turnRolls.max()
	for r:int in highest:
		if not turnRolls.has(highest - r): continue
		var ties:Array[int] = []
		for k:int in turnRolls.size():
			if turnRolls[k] == highest - r: ties.append(k)
		while not ties.is_empty():
			orderCnt += 1
			var picked:int = ties.pick_random()
			var remove:int = ties.find(picked)
			finalOrder[picked] = orderCnt
			ties.remove_at(remove)

	#print("Turn Rolls: " + str(turnRolls))
	#print("finalOrder: " + str(finalOrder))
	highestTurn = finalOrder.max()
	for r:int in Glo.party.size():
		Glo.party[r].stats.turn = finalOrder[r]
		#print("Name: "+str(Glo.party[r].stats.name)+"Turn:" + str(Glo.party[r].stats.turn))
	for r:int in Glo.enemyParty.size():
		Glo.enemyParty[r].stats.turn = finalOrder[r + Glo.party.size()]
		#print("Name: "+str(Glo.enemyParty[r].stats.name)+" Turn:"+str(Glo.enemyParty[r].stats.turn))

func HurtEveryone():
	for r:int in Glo.party.size():
		var member = Glo.party[r]
		member.stats.hp -= 1
		if member.stats.hp <= 0:
			member.stats.hp = member.stats.maxHP

	for r:int in Glo.enemyParty.size():
		var member = Glo.enemyParty[r]
		member.stats.hp -= 1
		if member.stats.hp <= 0:
			member.stats.hp = member.stats.maxHP
