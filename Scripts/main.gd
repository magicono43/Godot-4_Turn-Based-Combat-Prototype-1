extends Node2D

@export var dunMinimap:Control
@export var combat:Control

func StartCombat_OnEnemyEncounter():
	dunMinimap.set_process_input(false)
	dunMinimap.set_process(false)
	dunMinimap.set_physics_process(false)
	combat.set_process_input(true)
	combat.set_process(true)
	combat.set_physics_process(true)
	combat.visible = true
	dunMinimap.CreateEnemyParty()
	combat.SetupCombat()

func ExitCombat_OnCombatEnd():
	combat.set_process_input(false)
	combat.set_process(false)
	combat.set_physics_process(false)
	dunMinimap.RemoveDefeatedEncounter()
	dunMinimap.set_process_input(true)
	dunMinimap.set_process(true)
	dunMinimap.set_physics_process(true)
	combat.hide()

func _ready()->void:
	dunMinimap.encountered_enemy.connect(StartCombat_OnEnemyEncounter)
	combat.combat_ended.connect(ExitCombat_OnCombatEnd)
