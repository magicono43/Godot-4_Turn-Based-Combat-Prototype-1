extends Control

signal encountered_enemy

var speed:float = 0.25
var moveR:bool = false
var moveL:bool = false
var isPlayerInRoom:bool = true
var moveDir:bool = true # true = left and right, false = up and down
var lWall:int = 0
var rWall:int = 0
var dotStart:Vector2i = Vector2i(0,0)

var processCounter:int = 0

@export var mapTiles:TileMap
@export var sectNumTiles:TileMap
@export var playerDot:AnimatedSprite2D
@export var panel:Panel
@export var debugtext1:Label

@export var arena:TileMap

func _ready() -> void:
	MakeDungeon()

func _physics_process(delta: float)->void:
	processCounter += 1
	if processCounter % 5 == 0:
		processCounter = 0
		if isPlayerInRoom: pass
		else:
			if moveR and moveL: pass
			elif moveR:
				if moveDir:
					Glo.playerPos.x = clampf(Glo.playerPos.x + speed,lWall,rWall)
				else:
					Glo.playerPos.y = clampf(Glo.playerPos.y - speed,rWall,lWall)
			elif moveL:
				if moveDir:
					Glo.playerPos.x = clampf(Glo.playerPos.x - speed,lWall,rWall)
				else:
					Glo.playerPos.y = clampf(Glo.playerPos.y + speed,rWall,lWall)

func _process(delta: float)->void:
	if dotStart != Vector2i(Glo.playerPos):
		playerDot.position = Vector2i(Glo.playerPos) * (mapTiles.tile_set.tile_size.x)
		dotStart = Vector2i(Glo.playerPos)
		CenterMapCameraOnPlayer()
		if Glo.encounters.has(Vector2i(Glo.playerPos)): encountered_enemy.emit()
	debugtext1.text = str(round(Glo.playerPos * 100) / 100)

func _input(event:InputEvent)->void:
	if event.is_action_pressed("ui_accept"):
		GloFuncs.ClearGlobalVars()
		get_tree().reload_current_scene()

	if isPlayerInRoom:
		if event.is_action_released("ui_up"):
			if GloFuncs.CheckForValidHall(Vector2i(Glo.playerPos),0):
				Glo.playerPos = Vector2i(Glo.playerPos) + (Glo.dirs[0] * 2)
				GloFuncs.GetDungeonSection(Vector2i(Glo.playerPos))
				moveDir = false
				isPlayerInRoom = false
				DefineHallBorders()
		elif event.is_action_released("ui_right"):
			if GloFuncs.CheckForValidHall(Vector2i(Glo.playerPos),1):
				Glo.playerPos = Vector2i(Glo.playerPos) + (Glo.dirs[1] * 2)
				GloFuncs.GetDungeonSection(Vector2i(Glo.playerPos))
				moveDir = true
				isPlayerInRoom = false
				DefineHallBorders()
		elif event.is_action_released("ui_down"):
			if GloFuncs.CheckForValidHall(Vector2i(Glo.playerPos),2):
				Glo.playerPos = Vector2i(Glo.playerPos) + (Glo.dirs[2] * 2)
				GloFuncs.GetDungeonSection(Vector2i(Glo.playerPos))
				moveDir = false
				isPlayerInRoom = false
				DefineHallBorders()
		elif event.is_action_released("ui_left"):
			if GloFuncs.CheckForValidHall(Vector2i(Glo.playerPos),3):
				Glo.playerPos = Vector2i(Glo.playerPos) + (Glo.dirs[3] * 2)
				GloFuncs.GetDungeonSection(Vector2i(Glo.playerPos))
				moveDir = true
				isPlayerInRoom = false
				DefineHallBorders()
	else:
		if event.is_action_pressed("ui_right"):
			moveR = true
		if event.is_action_released("ui_right"):
			moveR = false
		if event.is_action_pressed("ui_left"):
			moveL = true
		if event.is_action_released("ui_left"):
			moveL = false

		if event.is_action_released("ui_up"):
			if not moveR and not moveL:
				if Vector2i(Glo.playerPos) == Glo.currDunSect[1]:
					Glo.playerPos = Glo.currDunSect.front()
					Glo.currSectNum = -1
					Glo.currDunSect.clear()
					isPlayerInRoom = true
					lWall = 0; rWall = 0
				elif Vector2i(Glo.playerPos) == Glo.currDunSect[Glo.currDunSect.size() - 2]:
					Glo.playerPos = Glo.currDunSect.back()
					Glo.currSectNum = -1
					Glo.currDunSect.clear()
					isPlayerInRoom = true
					lWall = 0; rWall = 0

func DefineHallBorders()->void:
	var secF:Vector2i = Glo.currDunSect[1]
	var secE:Vector2i = Glo.currDunSect[Glo.currDunSect.size() - 2]
	if moveDir:
		if secF.x >= secE.x: lWall = secE.x; rWall = secF.x
		else: lWall = secF.x; rWall = secE.x
	else:
		if secF.y >= secE.y: lWall = secF.y; rWall = secE.y
		else: lWall = secE.y; rWall = secF.y

func MakeDungeon()->void:
	GloFuncs.LayoutRandomDungeon()
	MapDungeonTiles()
	#GenerateWalkableTiles()
	#CenterCameraOnDungeonLayout()
	Glo.playerPos = Glo.rooms.front() # Place playerPos in "home room"
	CenterMapCameraOnPlayer()
	#NumberDungeonSections()

	CreatePlayerParty()
	PlaceEnemyEncounters()
	#for r:int in Glo.sections.size():
		#print(Glo.sections.get(r))

func MapDungeonTiles()->void:
	var squareSize: int = 3
	var halfSize: int = squareSize/2

	for r:int in Glo.rooms.size():
		var pos:Vector2i = Glo.rooms[r]
		for k:int in range(-halfSize, halfSize+1):
			for w:int in range(-halfSize, halfSize+1):
				var place:Vector2i = Vector2i(pos.x + k, pos.y + w)
				if r == 0: # Home Room Tile
					mapTiles.set_cell(0, place, 0, Vector2i(6,63))
				else: # Any other room tiles
					mapTiles.set_cell(0, place, 0, Vector2i(6,65))
	for r:int in Glo.halls.size():
		var pos:Vector2i = Glo.halls[r]
		mapTiles.set_cell(0, pos, 0, Vector2i(6,59))

func CenterMapCameraOnPlayer()->void:
	var offset:float = mapTiles.tile_set.tile_size.x * mapTiles.scale.x
	var panCenter:Vector2i = Vector2i(panel.size.x/2,panel.size.y/2)
	var playerCenter:Vector2i = Glo.playerPos * offset
	mapTiles.position = panCenter - playerCenter

func CenterCameraOnDungeonLayout()->void:
	Glo.dunCenter = GloFuncs.GetCentroidVector(Glo.rooms)
	var offset:float = mapTiles.tile_set.tile_size.x * mapTiles.scale.x
	var panCenter:Vector2i = Vector2i(panel.size.x/2,panel.size.y/2)
	var mapCenter: Vector2i = Glo.dunCenter * offset
	mapTiles.position = panCenter - mapCenter

func NumberDungeonSections()->void:
	for num:int in Glo.sections.keys():
		var tile:Vector2i = Vector2i(0,0)
		match num:
			0: tile = Vector2i(0,0)
			1: tile = Vector2i(1,0)
			2: tile = Vector2i(2,0)
			3: tile = Vector2i(3,0)
			4: tile = Vector2i(4,0)
			5: tile = Vector2i(0,1)
			6: tile = Vector2i(1,1)
			7: tile = Vector2i(2,1)
			8: tile = Vector2i(3,1)
			9: tile = Vector2i(4,1)
			_: tile = Vector2i(4,1)
		var sect:Array[Vector2i] = Glo.sections.get(num)
		var mid:Vector2i = sect[sect.size()/2]
		sectNumTiles.set_cell(0,mid,0,tile)

var pPath = load("res://Scenes/player.tscn")
var aPath = load("res://Scenes/ally.tscn")
var ePath = load("res://Scenes/enemy.tscn")

func CreateEnemyParty():
	var partyNode:Node2D = Node2D.new()
	partyNode.name = "EnemyParty"
	arena.add_child(partyNode)
	var enemyNum:int = randi_range(1,5)
	for r:int in enemyNum:
		var member = ePath.instantiate()
		member.name = member.stats.name
		Glo.enemyParty.append(member)
		partyNode.add_child(member)

	Glo.enemyParty.shuffle()
	for r:int in Glo.enemyParty.size():
		print(PartyMemberInfo(Glo.enemyParty[r].stats))
		print("####################################")

func CreatePlayerParty()->void:
	var partyNode:Node2D = Node2D.new()
	partyNode.name = "PlayerParty"
	arena.add_child(partyNode)
	var member = pPath.instantiate()
	member.name = member.stats.name
	Glo.party.append(member)
	partyNode.add_child(member)
	var allyNum:int = randi_range(2,4)
	for r:int in allyNum:
		member = aPath.instantiate()
		member.name = member.stats.name
		Glo.party.append(member)
		partyNode.add_child(member)

	Glo.party.shuffle()
	for r:int in Glo.party.size():
		print(PartyMemberInfo(Glo.party[r].stats))
		print("-------------------------------------")

func PartyMemberInfo(member:EntityStats)->String:
	var strg:String = ""
	if member is PlayerStats or member is AllyStats or member is EnemyStats:
		strg = "Name: " + str(member.name) + ", "
		strg = strg + "Max-HP: " + str(member.maxHP) + ", "
		strg = strg + "Dam-Range: " + str(member.atk) + ", "
		strg = strg + "Speed: " + str(member.speed)
	else: return "Invalid Member"
	return strg

func PlaceEnemyEncounters()->void:
	var dunSize:int = Glo.rooms.size() + Glo.halls.size()
	var amount:int = randi_range(1,dunSize/10)
	var allRooms:Array[Vector2i] = Glo.rooms.duplicate(); allRooms.append_array(Glo.halls)
	for r:int in amount:
		var spot:Vector2i = allRooms.pick_random()
		if spot == Vector2i(0,0): spot = allRooms.pick_random()
		if spot == Vector2i(0,0): continue
		Glo.encounters.append(spot)
	GloFuncs.RemoveRepeats(Glo.encounters)

	for r:int in Glo.encounters.size():
		var tile:Vector2i = Vector2i(6,131)
		var pos:Vector2i = Glo.encounters[r]
		sectNumTiles.set_cell(0,pos,1,tile)

func RemoveDefeatedEncounter()->void:
	moveR = false
	moveL = false
	var index:int = Glo.encounters.find(Vector2i(Glo.playerPos))
	var pos:Vector2i = Glo.encounters[index]
	sectNumTiles.erase_cell(0,pos)
	Glo.encounters.remove_at(index)
