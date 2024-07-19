extends Node

enum TURN {PLAYER, ENEMY}
@export var TURNORDER=TURN.PLAYER
@export var playerpath: NodePath
@onready var player: CharacterBody2D = get_node(playerpath)



# Called when the node enters the scene tree for the first time.
func _ready():
	combat_prepare()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass


func combat_prepare():
	# get entity_data from levels
	# move camera around to point at each sunflower, then back to player
	
	pass

func turn_start_player():
# play player turn cutscene
	pass
	
func turn_start_npc():
# play NPC turn cutscene

	pass
