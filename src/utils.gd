extends Node
class_name Utils

static func remove_all_children(node : Node):
	for i in node.get_child_count():
		node.get_child(i).queue_free()
		
static func get_children_recursive(parent: Node) -> Array[Node]:
	var result: Array[Node] = []
	var stack: Array[Node] = [parent]

	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			result.append(child)
			stack.append(child)
	
	return result

static func get_first_of_type(type : Script):
	for child in get_children_recursive(Engine.get_main_loop().root):
		if is_instance_of(child, type):
			return child

static func wait(time : float):
	await Engine.get_main_loop().root.get_tree().create_timer(time).timeout
	
static func get_all_of_type(type : Script):
	var children = []
	for child in get_children_recursive(Engine.get_main_loop().root):
		if is_instance_of(child, type):
			children.append(child)
	return children
			
static func get_component_by_type(node : Node, type : Script):
	for child in get_children_recursive(node):
		if is_instance_of(child, type):
			return child
			
static func get_parent_by_type(node : Node, type : Script):
	var parent = node.get_parent()
	if !parent:
		return null
		
	if is_instance_of(parent, type):
		return parent
	return get_parent_by_type(parent, type)

static func get_player() -> Player:
	return get_first_of_type(Player)
	
static func get_camera() -> PlayerCamera:
	return get_first_of_type(PlayerCamera)
