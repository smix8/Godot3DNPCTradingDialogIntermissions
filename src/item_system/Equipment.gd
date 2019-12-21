extends "res://src/item_system/Item.gd"

class_name Equipment

enum Slot {
	Hands,
	Head,
	Torso,
	Legs,
	Arms,
	Feet,
	Accessory
}

export(Slot) var slot = Slot.Hands

# stat boosts provided when equipped
export(Resource) var stats = null setget ,_get_stats
	
func _get_stats():
	return stats
