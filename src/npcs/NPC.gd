extends Node


##########################################
### Helper node that holds all data and functions for one npc character
### e.g. stats, inventory, ...
###

var id = ""
var inventory : Array
var money : int

func _ready():
	pass
	
func get_money():
	return money
	
func get_inventory():
	return inventory
	
func add_money( amount : int = 0 ):
	money += amount
	
func sub_money( amount : int = 0 ):
	money -= amount
	
func add_item( item : Dictionary, amount : int = 1 ):
	inventory.append(item)
	
func remove_item_id(item_id : String):
	var inx = 0
	for item in inventory:
		if item.item_id == item_id:
			inventory.remove(inx)
			break
		inx += 1
	print("couldn't remove item_id '%s' from inventory" % item_id)
