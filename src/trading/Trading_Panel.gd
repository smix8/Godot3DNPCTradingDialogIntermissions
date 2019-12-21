extends Control

#################################################
### Panel for NPC trading,
###
###

signal trade_window_closed

var itemslot_template = preload("res://gui/trading/Itemslot_Template.tscn")

var player_inventory : Array = []
var exchange_inventory : Array = []
var trader_inventory : Array = []
var player_money_value : int = 150
var trader_money_value : int = 100
export(float) var exchange_rate_buy = 2.0
export(float) var exchange_rate_sell = 0.5

var last_clicked_time : float
var last_clicked_item : Node
var compared_item : Node

export(Color) var default_color
export(Color) var highlight_color
export(Color) var money_plus_color
export(Color) var money_minus_color

onready var inventory_grid_player = $HBoxContainer/Player/VBoxContainer/ScrollContainer/Player_Itemgrid
onready var inventory_panel_player = $HBoxContainer/Player/Panel
onready var dropzone_player = $HBoxContainer/Player/Player_Item_Dropzone

onready var inventory_grid_trader = $HBoxContainer/Trader/VBoxContainer/ScrollContainer/Trader_Itemgrid
onready var inventory_panel_trader = $HBoxContainer/Trader/Panel
onready var dropzone_trader = $HBoxContainer/Trader/Trader_Item_Dropzone

onready var inventory_vbox_exchange_player = $HBoxContainer/Exchange/VBoxContainer/ScrollContainer/HBoxContainer/Exchange_Player_ItemVBox
onready var inventory_vbox_exchange_trader = $HBoxContainer/Exchange/VBoxContainer/ScrollContainer/HBoxContainer/Exchange_Trader_ItemVBox
onready var inventory_panel_exchange = $HBoxContainer/Exchange/Panel
onready var dropzone_exchange = $HBoxContainer/Exchange/Exchange_Dropzone


onready var confirm_button = $HBoxContainer/Exchange/VBoxContainer2/HBoxContainer/Exchange_Confirm
onready var cancel_button = $HBoxContainer/Exchange/VBoxContainer2/HBoxContainer/Exchange_Abort
onready var player_money_label = $HBoxContainer/Player/VBoxContainer/Player_Money_Label
onready var trader_money_label = $HBoxContainer/Trader/VBoxContainer/Trader_Money_Label
onready var cost_label = $HBoxContainer/Exchange/VBoxContainer2/Cost

onready var player_name_label = $HBoxContainer/Player/VBoxContainer/Label
onready var trader_name_label = $HBoxContainer/Trader/VBoxContainer/Label


var cost_total : int = 0
var is_exchanging = false
var compare : bool = false
var trader : Node
var trader_name : String
var hovered_item = null

onready var item_tooltip = $Item_Tooltip

onready var animate = $GUI_Menu_AnimationPlayer



func _ready():
	
	### lock item dragging while rearranging and updating container content
	is_exchanging = true
	
	cancel_button.connect("pressed", self, "_on_cancel_button_pressed")
	confirm_button.connect("pressed", self, "_on_confirm_button_pressed")
	
	dropzone_player.connect( "item_drop_received", self, "_transfer_item_to_grid", ["player"])
	dropzone_trader.connect( "item_drop_received", self, "_transfer_item_to_grid", ["trader"])
	dropzone_exchange.connect( "item_drop_received", self, "_transfer_item_to_grid", ["exchange"])
	dropzone_player.connect( "item_drag_started", self, "_prepare_itemdrop_from", ["player"])
	dropzone_trader.connect( "item_drag_started", self, "_prepare_itemdrop_from", ["trader"])
	dropzone_exchange.connect( "item_drag_started", self, "_prepare_itemdrop_from", ["exchange"])
	
	### make sure the price calculation and display have a reset
	cost_total = 0
	cost_label.text = ""
	
	### give the player side the player name, money and inventory
	player_name_label.text = "Player"
	player_money_value = game.player.get_money()
	player_money_label.text = str(player_money_value)
	player_inventory = game.player.get_inventory()

	### give the trader side the npc actors name, money and inventory
	trader_name_label.text = trader_name
	trader_money_value = trader.get_money()
	trader_money_label.text = str(trader_money_value)
	trader_inventory = trader.get_inventory()
	
	
	for item in player_inventory:
		
		### if the item can not be sold or bought skip it
		if item.get("sellable") == false:
			continue
			
		### create item displays for player inventory
		var new_item = itemslot_template.instance()
		new_item.exchange_panel = self
		new_item.item_owner = "player"
		new_item.item_id = item.item_id
		new_item.display_name = item.display_name
		new_item.description = item.description
		new_item.image = item.image
		new_item.rarity = item.rarity
		new_item.category = item.category
		new_item.slot = item.slot
		new_item.stats = item.stats
		new_item.stack = item.max_stack
		new_item.max_stack = item.max_stack
		new_item.base_price = item.base_price
		
		### calculate how much the item is worth if sold
		new_item.price = int( (item.base_price * exchange_rate_sell) * new_item.stack )
		
		### add the item display to the grid container		
		inventory_grid_player.add_child(new_item)
		
		### connect item display signals for the tooltip display and hightlighting of dropzones
		new_item.connect("dragged", self, "_prepare_itemdrop_from")
		new_item.connect("hovered", self, "_show_tooltip")
		new_item.connect("unhovered", self, "_hide_tooltip")
		new_item.connect("compared", self, "_compare_tooltip")
		new_item.connect("uncompared", self, "_uncompare_tooltip")		
		
	for item in trader_inventory:
		
		### if the item can not be sold or bought skip it
		if item.sellable == false:
			continue
			
		### create item displays for trader inventory
		var new_item = itemslot_template.instance()
		new_item.exchange_panel = self
		new_item.item_owner = "trader"
		new_item.item_id = item.item_id
		new_item.display_name = item.display_name
		new_item.description = item.description
		new_item.image = item.image
		new_item.rarity = item.rarity
		new_item.category = item.category
		new_item.slot = item.slot
		new_item.stats = item.stats
		new_item.stack = item.max_stack
		new_item.max_stack = item.max_stack
		new_item.base_price = item.base_price
		
		### calculate how much the item is worth if bought
		new_item.price = int( (item.base_price * exchange_rate_buy) * new_item.stack )
		
		### add the item display to the grid container
		inventory_grid_trader.add_child(new_item)
		
		### connect item display signals for the tooltip display and hightlighting of dropzones
		new_item.connect("dragged", self, "_prepare_itemdrop_from")
		new_item.connect("hovered", self, "_show_tooltip")
		new_item.connect("unhovered", self, "_hide_tooltip")
		new_item.connect("compared", self, "_compare_tooltip")
		new_item.connect("uncompared", self, "_uncompare_tooltip")
		
	### everything done so allow item dragging again
	is_exchanging = false
	
	animate.play("show")
	
	

func item_doube_clicked(item):
	
	if is_exchanging:
		return
	
	is_exchanging = true
	
	var drop_grid : String
	
	match item.drop_origin.name:
		"Player_Itemgrid":
			drop_grid = "exchange"
		"Trader_Itemgrid":
			drop_grid = "exchange"
		"Exchange_Player_ItemVBox":
			drop_grid = "player"
		"Exchange_Trader_ItemVBox":
			drop_grid = "trader"
			
	is_exchanging = false
	
	hovered_item = null
	_uncompare_tooltip()
	compared_item = null
	
	_transfer_item_to_grid(item, drop_grid)
	
	

func _show_tooltip(tooltip : Dictionary = {}, item_node = null):
	
	item_tooltip.replace_tooltip_display(tooltip, item_node)
	if item_node:
		hovered_item = item_node
		
		
		
func _hide_tooltip(item_node : Node):
	if hovered_item == item_node:
		hovered_item = null
		item_tooltip.replace_tooltip_display()



func _compare_tooltip(tooltip_data : Dictionary, tooltip_node : Node):	
	item_tooltip.replace_compare_tooltip(tooltip_data, tooltip_node)



func _uncompare_tooltip():
	item_tooltip.replace_compare_tooltip({})



func split_stack(item_owner, item_data, diff):
	
	### stack splitting will come with a future update
	pass


func _on_cancel_button_pressed():
	
	### lock item dragging while rearranging and updating container content
	if is_exchanging:
		return
	
	hovered_item = null
	_uncompare_tooltip()
	compared_item = null
		
	if (inventory_vbox_exchange_player.get_child_count() == 0) and (inventory_vbox_exchange_trader.get_child_count() == 0) and (cancel_button.text == "Leave"):
		animate.play("hide")
		yield(animate, "animation_finished")
		emit_signal("trade_window_closed")
		queue_free()
		return
		
	is_exchanging = true
			
	for item in inventory_vbox_exchange_player.get_children():
		if item.item_owner == "trader":
			
			inventory_vbox_exchange_player.remove_child(item)
			inventory_grid_trader.add_child(item)
			
		elif item.item_owner == "player":
			
			inventory_vbox_exchange_player.remove_child(item)
			inventory_grid_player.add_child(item)
			
	for item in inventory_vbox_exchange_trader.get_children():
		if item.item_owner == "trader":
			
			inventory_vbox_exchange_trader.remove_child(item)
			inventory_grid_trader.add_child(item)
			
		elif item.item_owner == "player":
			
			inventory_vbox_exchange_trader.remove_child(item)
			inventory_grid_player.add_child(item)
		
	_reset_cost()
	
	### reset highlight colors on dropzones
	_reset_dropzone_highlights()
	
	cancel_button.text = "Leave"
	
	### everything done so allow item dragging again
	is_exchanging = false
	
		

func _on_confirm_button_pressed():
	
	### do nothing while we are rearranging and updating container content
	if is_exchanging:
		return
		
	hovered_item = null
	
	### if player or trader do not have enough money for the exchange stop it and notify
	if (player_money_value < -cost_total) or (trader_money_value < cost_total):
		
		var notification_text : String
		
		if (player_money_value < -cost_total):
			notification_text = "Not enough money"
		if (trader_money_value < cost_total):
			notification_text = "%s has not enough money" % trader_name
			
		game.notify(notification_text)
		
		return
		
	### lock item dragging while rearranging and updating container content
	is_exchanging = true
		
	var exchange_items = inventory_vbox_exchange_player.get_children()
	exchange_items += inventory_vbox_exchange_trader.get_children()
	for item in exchange_items:
		
		if item.item_owner == "trader":
			
			### adjust player and npc actor money and display money values
			trader_money_value += item.price
			trader.add_money(item.price)
			player_money_value -= item.price
			game.player.sub_money(item.price)
			
			### change ownership and adjust price calculation from new owners exchange rate
			item.item_owner = "player"
			item.price = int( (item.base_price * exchange_rate_sell) * item.stack )
			
			### move item displays between the grids
			inventory_vbox_exchange_trader.remove_child(item)
			inventory_grid_player.add_child(item)
			
			### adjust player and npc actor inventory
			trader.remove_item_id(item.item_id)
			game.player.add_item(game.create_item_from_id(item.item_id))

			
		elif item.item_owner == "player":
			
			### adjust player and npc actor money and display money values
			trader_money_value -= item.price
			trader.sub_money(item.price)
			player_money_value += item.price
			game.player.add_money(item.price)
			
			### change ownership and adjust price calculation from new owners exchange rate
			item.item_owner = "trader"
			item.price = int( (item.base_price * exchange_rate_buy) * item.stack )
			
			### move item displays between the grids
			inventory_vbox_exchange_player.remove_child(item)
			inventory_grid_trader.add_child(item)
			
			### adjust player and npc actor inventory
			game.player.remove_item_id(item.item_id)
			trader.add_item(game.create_item_from_id(item.item_id))

			
		### update the money displays with the new values
		player_money_label.text = str(player_money_value)
		trader_money_label.text = str(trader_money_value)
		

		
	### resets price calculation and updates pricing display
	_reset_cost()
	
	### reset highlight colors on dropzones
	_reset_dropzone_highlights()
	
	### everything done so allow item dragging again with a small delay
	yield(get_tree().create_timer(0.5), "timeout")
	
	is_exchanging = false
	
	animate.play("hide")
	yield(animate, "animation_finished")
	emit_signal("trade_window_closed")
	queue_free()
	


func _reset_cost():
	
	### resets price calculation and updates pricing display
	cost_total = 0
	cost_label.text = ""
	cost_label.modulate = "ffffff"
	
	

func _transfer_item_to_grid(item : Dictionary, drop_grid : String):
	
	### do nothing while we are rearranging and updating container content
	if is_exchanging:
		return
		
	### lock item dragging while rearranging and updating container content
	is_exchanging = true
	
	print ( "_transfer_item_to_grid - grid: %s - item.drop_origin: %s" % [drop_grid, item.drop_origin.name])
		
	match drop_grid:
		
		"player":
			
			if item.drop_origin.name == "Player_Itemgrid":
				
				print("drop on player - drop_origin Player_Itemgrid")
				### reset highlight colors on dropzones
				_reset_dropzone_highlights()
				pass
				
			elif item.drop_origin.name == "Trader_Itemgrid":
				
				print("drop on player - drop_origin Trader_Itemgrid")
				
				item.drop_origin.remove_child(item.item_node)
				inventory_vbox_exchange_trader.add_child(item.item_node)
				cost_total += -item.price
				
			elif item.drop_origin.name == "Exchange_Player_ItemVBox" or item.drop_origin.name == "Exchange_Trader_ItemVBox":
				
				print("drop on player - drop_origin Exchange_Player_ItemVBox / Exchange_Trader_ItemVBox")
				
				item.drop_origin.remove_child(item.item_node)
				if item.item_owner == "player":
					inventory_grid_player.add_child(item.item_node)
					cost_total += -item.price
				elif item.item_owner == "trader":
					inventory_grid_trader.add_child(item.item_node)
					cost_total += item.price

		"trader":
			
			if item.drop_origin.name == "Player_Itemgrid":
				
				print("drop on trader - drop_origin Player_Itemgrid")
				
				item.drop_origin.remove_child(item.item_node)
				inventory_vbox_exchange_player.add_child(item.item_node)
				cost_total += item.price
				
			elif item.drop_origin.name == "Trader_Itemgrid":
				
				print("drop on trader - drop_origin Trader_Itemgrid")
				
				pass
				
			elif item.drop_origin.name == "Exchange_Player_ItemVBox" or item.drop_origin.name == "Exchange_Trader_ItemVBox":
				
				print("drop on trader - drop_origin Exchange_Player_ItemVBox / Exchange_Trader_ItemVBox")
				
				item.drop_origin.remove_child(item.item_node)
				if item.item_owner == "player":
					inventory_grid_player.add_child(item.item_node)
					cost_total += -item.price
				elif item.item_owner == "trader":
					inventory_grid_trader.add_child(item.item_node)
					cost_total += item.price

		"exchange":

			if item.drop_origin.name == "Player_Itemgrid":
				
				print("drop on exchange - drop_origin Player_Itemgrid")
				
				item.drop_origin.remove_child(item.item_node)
				inventory_vbox_exchange_player.add_child(item.item_node)
				cost_total += item.price
				
			elif item.drop_origin.name == "Trader_Itemgrid":
				
				print("drop on exchange - drop_origin Trader_Itemgrid")
				
				item.drop_origin.remove_child(item.item_node)
				inventory_vbox_exchange_trader.add_child(item.item_node)
				cost_total += -item.price
				
			elif item.drop_origin.name == "Exchange_Itemgrid":
				
				print("drop on exchange - drop_origin Exchange_Itemgrid")
				
				pass
			
	if cost_total > 0:
		cost_label.text = "+" + str(cost_total) + " $"
		cost_label.modulate = money_plus_color
	else:
		cost_label.text = str(cost_total) + " $"
		cost_label.modulate = money_minus_color
	
	### reset highlight colors on dropzones
	_reset_dropzone_highlights()
				
	cancel_button.text = "Cancel"
	
	### everything done so allow item dragging again
	is_exchanging = false
	


func _prepare_itemdrop_from(item_drop : Dictionary):
	
	print("_prepare_itemdrop_from: %s" % item_drop.drop_origin.name)
	
	### reset highlight colors on dropzones
	_reset_dropzone_highlights()
	
	### arrange highlight colors and mouse filters
	match item_drop.drop_origin.name:
		
		"Player_Itemgrid":

			dropzone_player.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_player.modulate = default_color
			
			dropzone_trader.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_trader.modulate = highlight_color
			
			dropzone_exchange.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_exchange.modulate = highlight_color
			
		"Trader_Itemgrid":
			
			dropzone_player.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_player.modulate = highlight_color
			
			dropzone_trader.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_trader.modulate = default_color
			
			dropzone_exchange.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_exchange.modulate = highlight_color
			
		"Exchange_Player_ItemVBox":
			
			dropzone_player.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_player.modulate = highlight_color
			
			dropzone_trader.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_trader.modulate = default_color
			
			dropzone_exchange.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_exchange.modulate = default_color
			
		"Exchange_Trader_ItemVBox":
			
			dropzone_player.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_player.modulate = default_color
			
			dropzone_trader.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_trader.modulate = highlight_color
			
			dropzone_exchange.mouse_filter = MOUSE_FILTER_PASS
			inventory_panel_exchange.modulate = default_color
			
			
			
func _reset_dropzone_highlights():
	
	### resets highlight colors on dropzones
	
	dropzone_player.mouse_filter = MOUSE_FILTER_IGNORE
	inventory_panel_player.modulate = default_color
	
	dropzone_trader.mouse_filter = MOUSE_FILTER_IGNORE
	inventory_panel_trader.modulate = default_color
	
	dropzone_exchange.mouse_filter = MOUSE_FILTER_IGNORE
	inventory_panel_exchange.modulate = default_color
