extends TileMap

var grid: AStarGrid2D


func compute_grid():
	for x in grid.region.size.x:
		for y in grid.region.size.y:
			var tile_position = Vector2i(x + grid.region.position.x, y + grid.region.position.y)
			
			var tile_data = get_cell_tile_data(0, tile_position)
			if tile_data == null or not tile_data.get_custom_data("walkable"):
				grid.set_point_solid(tile_position)


# Called when the node enters the scene tree for the first time.
func _ready():
	grid = AStarGrid2D.new()
	grid.region = get_used_rect()
	grid.cell_size = tile_set.tile_size
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	
	compute_grid()
	
func can_move_to():
	pass
	
func get_grid_path(from: Vector2, to: Vector2) -> Array:
	if grid.is_in_boundsv(local_to_map(to)):
		var paths: Array[Vector2i] = grid.get_id_path(local_to_map(from), local_to_map(to))
		paths.pop_front()
		var ret_arr: Array = paths.map(func(x: Vector2i): return map_to_local(x))
		return ret_arr
	else:
		return []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
