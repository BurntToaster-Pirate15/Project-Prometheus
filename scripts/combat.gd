extends Node2D

var in_combat: bool = false

var grid: TileMap

var current_turn: CharacterBody2D
var combatants: Array[CharacterBody2D]


@onready var player: CharacterBody2D = $"../Player" 

func _ready():
	player = $"../Player"
	grid = $"../TileMap"
	
	for child in get_children():
		child.connect("body_entered", _on_combat_area_entered.bind(child))



func _on_combat_area_entered(body: Node2D, area: Area2D):
	body.switch_to_grid()
	var children := area.find_child("EnemyManager").get_children()
	
	combatants.append(player)
	children.map(func(child): if child is CharacterBody2D: combatants.append(child))
	player.position.x += 32
	in_combat = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_combat and len(combatants) > 1:
		for combatant in combatants:
			combatant.start_turn(grid, combatants)
			await combatant.turn_finished
