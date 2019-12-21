extends "res://src/item_system/Item.gd"

class_name ConsumableItem

# action to execute when used in combat
export(Resource) var action = null setget ,_get_action
	
func _get_action():
	return action 
