extends Control


signal item_drop_received
signal item_drag_started


#func get_drag_data(_pos):
#	item_drag_started
	
func signal_drag():
	emit_signal("item_drag_started")
	print("emit_signal 'item_drag_started' ")
	
func can_drop_data(_pos, item):	
	return true



func drop_data(_pos, item):
	emit_signal("item_drop_received", item)
	
	
	
	
	
func old_stuff(item):
	var itemslot_template
	var new_item = itemslot_template.instance()
	new_item.drop_origin = item.drop_origin
	new_item.text = item.text
	new_item.image = item.image
	new_item.amount = item.amount
	new_item.price = item.price
	
	
	var cost_total = 0
	if new_item.drop_origin.name == "Trader_Itemgrid":
		cost_total -= new_item.price
	elif new_item.drop_origin.name == "Player_Itemgrid":
		cost_total += new_item.price
	
	var cost_label
	if cost_total >= 0:
		cost_label.text = "+" + str(cost_total)
	else:
		cost_label.text = str(cost_total)
		
	var item_grid
	item_grid.add_child(new_item)
	item.drop_origin.remove_child(item.item_node)


