extends Node

signal trade_finished_reset_camera

onready var data = $data as Node
onready var player = $player as Node
onready var characters = $characters as Node
onready var menu_window = $Menu_CanvasLayer
onready var notification_box = $Notifications_Layer/Notifications


onready var item_data = data.item_data
onready var image_data = data.image_data

var is_trading : bool = false
var in_dialog : bool = false

const itemslot_name = {
	0 : "Hands",
	1 : "Head",
	2 : "Torso",
	3 : "Legs",
	4 : "Arms",
	5 : "Feet",
	6 : "Accessory"
}
const category_name = {
	0 : "Trash",
	1 : "Consumable",
	2 : "Material",
	3 : "Key",
	4 : "Equipable"
}

func _ready():
	
	data.scan_assets()
	data.init_asset_refs()

	
	### DEVELOPMENT CHEATS	
	
	### cheat for testing items and trading
	if OS.is_debug_build():
		for item in game.item_data:
			var new_item = game.create_item_from_id(item)			
			game.player.add_item(game.create_item_from_id(item))
		game.player.add_money(500)		

		for item in game.item_data:
			var new_item = game.create_item_from_id(item)
			characters.get_node("NPC").add_item(game.create_item_from_id(item))
		for item in game.item_data:
			var new_item = game.create_item_from_id(item)
			characters.get_node("NPC").add_item(game.create_item_from_id(item))
		for item in game.item_data:
			var new_item = game.create_item_from_id(item)
			characters.get_node("NPC").add_item(game.create_item_from_id(item))
		characters.get_node("NPC").add_money(100)
		
	start_trading("NPC")


func start_trading(npc_id : String = "", inventory_id = null, dialog_id = null) -> void:
	
	var trading_scene = load("res://gui/trading/Trading_Panel.tscn").instance()
	
	assert(characters.has_node(npc_id))
	
	trading_scene.trader_name = characters.get_node(npc_id).name
	trading_scene.trader = characters.get_node(npc_id)
	
	### only used to overwrite a traders inventory temporarily e.g. for a quest or special event
	if inventory_id:
		trading_scene.trader_inventory = []
	
	menu_window.add_child(trading_scene)
	is_trading = true
	trading_scene.connect("trade_window_closed", self, "_on_trade_finished", [dialog_id])
	

	
func _on_trade_finished(dialog_id):
	
	print("trade_finished: dialog_id: %s" % dialog_id)

	if dialog_id:
		load_dialog(dialog_id)

	is_trading = false
	


func create_item_from_id(item_id : String, rarity : String = ""):
	
	### creates a new item Dictionary from a template resource
	
	var item_resource_template = load(data.item_data[item_id])
	
	var new_item : Dictionary = {
		"item_id" : item_resource_template.item_id,
		"display_name" : item_resource_template.display_name,
		"description" : item_resource_template.description,
		"rarity" : item_resource_template.rarity,
		"image" : item_resource_template.image,
		"stack" : item_resource_template.stack,
		"max_stack" : item_resource_template.max_stack,
		"unique" : item_resource_template.unique,
		"sellable" : item_resource_template.sellable,
		"base_price" : item_resource_template.base_price,
		"category" : item_resource_template.category,
		"slot" : item_resource_template.get("slot"),
		"stats" : item_resource_template.get("stats"),
		"action" : item_resource_template.get("action")
	}
	
	if rarity:
		new_item["rarity"] = rarity
		
	return new_item
	
	

func load_dialog(dialog_id):	
	
	### function for starting dialogs, use your own dialog system code here
	### iwanttostartmyowndialog( dialog_id )
	return
	

	### adds new notifications from items to the screen that autohide after a few seconds
func notify(notification_text : String):
	var notification = load("res://gui/trading/Notification.tscn").instance()
	notification.text = notification_text
	notification_box.add_child(notification)
	
	
func dialog_exit() -> void:
	emit_signal("dialog_ended")
	in_dialog = false
	
func dialog_enter() -> void:
	emit_signal("dialog_started")
	in_dialog = true
