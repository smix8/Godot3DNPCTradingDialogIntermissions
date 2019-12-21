extends Node


var money : int = 0
var inventory : Array = []



func add_money( amount : int = 0 ):
	money += amount

func sub_money( amount : int = 0 ):
	money -= amount
	
func add_item( item : Dictionary, amount : int = 1 ):
		
	inventory.append(item)
	
	var notification_text = "Added %sx %s" % [item.get("amount", amount), item.get("display_name")]
	
	game.notify(notification_text)
	
	
func remove_item_id(item_id : String):
	var inx = 0
	for item in inventory:
		if item.item_id == item_id:
			inventory.remove(inx)
			break
		inx += 1
	print("couldn't remove item_id '%s' from inventory" % item_id)


func get_money():
	return money
	
func get_inventory():
	return inventory
