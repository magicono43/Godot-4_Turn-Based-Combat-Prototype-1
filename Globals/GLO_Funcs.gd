extends Node

var rGen = RandomNumberGenerator.new()

@export var branchCycles:int = 0
@export var maxBranches:int = 25
@export var minDis:int = 6
@export var maxDis:int = 13
@export var roomBorders:Array[Vector2i] = []
@export var anchors:Array[Vector2i] = []

@export var dunBranchNum:int = 0

@export var mapTileScale:int = 5 # Walkable tiles per mini-map tile

#region General Helpers
func ClearGlobalVars()->void:
	branchCycles = 0
	roomBorders.clear()
	dunBranchNum = 0
	Glo.dunCenter = Vector2i(0,0)
	Glo.rooms.clear()
	Glo.halls.clear()
	Glo.sections.clear()
	Glo.playerPos = Vector2(0,0)
	Glo.currSectNum = -1
	Glo.currDunSect.clear()

	Glo.party.clear()
	Glo.enemyParty.clear()
	Glo.allyCounter = 0
	Glo.enemyCounter = 0
	Glo.encounters.clear()

func RemoveRepeats(array:Array[Vector2i])->Array[Vector2i]:
	var dups: Array[bool] = []
	dups.resize(array.size())
	dups.fill(false)

	for r:int in array.size():
		if dups[r] == true: continue
		for k:int in array.size():
			if r == k: continue
			if array[r].x == array[k].x and array[r].y == array[k].y:
				dups[k] = true

	var uniques: Array[Vector2i] = []
	for b:int in dups.size():
		if dups[b] == false:
			uniques.append(array[b])
	return uniques

func GetCentroidVector(array:Array[Vector2i])->Vector2i:
	var xTot:int = 0
	var yTot:int = 0
	var points:int = array.size()
	for r:int in points:
		xTot += array[r].x
		yTot += array[r].y
	var xCentroid:int = xTot / points
	var yCentroid:int = yTot / points
	return Vector2i(xCentroid,yCentroid)

func CheckForValidHall(start:Vector2i,dir:int)->bool:
	return Glo.halls.has(start + (Glo.dirs[dir] * 2))

func GetDungeonSection(start:Vector2i)->Array[Vector2i]:
	for r:int in Glo.sections:
		var sect:Array[Vector2i] = Glo.sections.get(r).duplicate()
		var playerTest:Vector2i = start
		var sectTest:Array[Vector2i] = sect
		if sect.has(start):
			if start == Vector2i(Glo.playerPos):
				Glo.currSectNum = r
				Glo.currDunSect = sect
				return sect
			else:
				return sect
	return []
#endregion

#region Layout Random Dungeon
func LayoutRandomDungeon()->void:
	# [north, east, south, west]
	var checkDirs:Array[bool] = [true,true,true,true]
	var pos:Vector2i = Vector2i(0,0)
	Glo.rooms.append(pos)
	anchors.append(pos)
	for r:int in checkDirs.size():
		if randi_range(0,1) == 1: checkDirs[r] = false
	if not checkDirs.has(true):
		checkDirs[randi_range(0,3)] = true
	var loops:int = 0
	while anchors.size() > 0:
		loops += 1
		if loops-1 >= anchors.size(): break
		MakeMoreRooms(checkDirs,anchors[loops-1])
	anchors.clear()
	RemoveRepeats(Glo.rooms)
	RemoveRepeats(Glo.halls)

func MakeMoreRooms(dirs:Array[bool],start:Vector2i)->void:
	branchCycles += 1
	if branchCycles > maxBranches: return
	var checkDirs:Array[bool] = [true,true,true,true]
	if branchCycles == 1: checkDirs = dirs.duplicate()
	else:
		if dirs[0]: checkDirs[2] = false
		if dirs[1]: checkDirs[3] = false
		if dirs[2]: checkDirs[0] = false
		if dirs[3]: checkDirs[1] = false
		for r:int in checkDirs.size():
			if randi_range(0,1) == 1: checkDirs[r] = false
		if not checkDirs.has(true): return
	for r:int in checkDirs.size():
		if not checkDirs[r]: continue
		var parentBorders:Array[Vector2i] = GetParentBorder(start)
		var direct:Vector2i
		match(r):
			0: direct = Vector2i(0,-1)
			1: direct = Vector2i(1,0)
			2: direct = Vector2i(0,1)
			_: direct = Vector2i(-1,0)
		var currP:Vector2i = Vector2i(start.x,start.y)
		var path:Array[Vector2i] = []
		var kill:bool = false
		var length:int = randi_range(minDis,maxDis)
		for k:int in length:
			currP.x += direct.x; currP.y += direct.y
			if Glo.halls.has(currP): kill = true; break
			if roomBorders.has(currP) and not parentBorders.has(currP): kill = true; break
			path.append(Vector2i(currP.x,currP.y))
		var newRoomBorder:Array[Vector2i] = GetParentBorder(path.back())
		for k:int in newRoomBorder.size():
			if Glo.halls.has(newRoomBorder[k]): kill = true; break
			if roomBorders.has(newRoomBorder[k]) and not newRoomBorder.has(newRoomBorder[k]):
				kill = true; break
		if kill: continue
		Glo.rooms.append(path.back())
		anchors.append(path.back())
		UpdateRoomBorders()
		path.pop_back()
		path.pop_back()
		path.pop_front()
		Glo.halls.append_array(path)
		var sect:Array[Vector2i] = []
		sect.append(start)
		sect.append_array(path)
		sect.append(Glo.rooms.back())
		Glo.sections[dunBranchNum] = sect
		dunBranchNum += 1

func GetParentBorder(pos:Vector2i)->Array[Vector2i]:
	var border:Array[Vector2i] = []
	var squareSize:int = 7
	var halfSize:int = squareSize/2

	for r:int in range(-halfSize, halfSize+1):
		for k:int in range(-halfSize, halfSize+1):
			var x:int = pos.x + r
			var y:int = pos.y + k
			var vec:Vector2i = Vector2i(x,y)
			border.append(vec)
	return border

func UpdateRoomBorders()->void:
	var borders:Array[Vector2i] = []
	var squareSize:int = 7
	var halfSize:int = squareSize/2

	for r:int in Glo.rooms.size():
		var border:Array[Vector2i] = []
		for k:int in range(-halfSize, halfSize+1):
			for w:int in range(-halfSize, halfSize+1):
				var x:int = Glo.rooms[r].x + k
				var y:int = Glo.rooms[r].y + w
				var vec:Vector2i = Vector2i(x,y)
				border.append(vec)
		borders.append_array(border)
	roomBorders = borders.duplicate()
#endregion

