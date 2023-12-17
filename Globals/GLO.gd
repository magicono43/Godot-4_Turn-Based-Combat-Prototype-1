extends Node # Script holds most, if not all global variables for this project

# North, East, South, West
var dirs:Array[Vector2i] = [Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0)]

var dunCenter:Vector2i = Vector2i(0,0)
var rooms:Array[Vector2i] = []
var halls:Array[Vector2i] = []

var sections:Dictionary = {}

var playerPos:Vector2 = Vector2(0,0)
var currSectNum:int = -1
var currDunSect:Array[Vector2i] = []

var party:Array = []
var enemyParty:Array = []
var allyCounter:int = 0
var enemyCounter:int = 0
var encounters:Array[Vector2i] = []

# Maybe tomorrow I can start working on a completely different system than the
# dungeon generation and movement related stuff. That thing possibly being
# the very basics of a combat system maybe? Like completely just data driven
# turn based combat sort of thing just to get a basic framework to build
# upon started? Don't know, will see what I feel like doing I guess tomorrow.
