extends Control

signal dragged
signal hovered
signal unhovered
signal compared
signal uncompare

var exchange_panel
var item_id : String
var display_name : String
var item_color : String
var description : String
var image : Texture
var price : int = 2
var stack : int = 1
var max_stack : int
var item_type : String
var can_sell = true
enum Category { TRASH, CONSUMABLE, MATERIAL, KEY, EQUIPMENT }
var category = Category.TRASH
enum Slot {Hands,Head,Torso,Legs,Arms,Feet,Accessory}
var slot = Slot.Hands
var stats : Resource = null
var base_price = 0
var item_owner
var origin
var is_compared : bool = false

enum Rarity { TRASH, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY , ARTIFACT}
var rarity = Rarity.TRASH

export(Color) var compare_border_highlight = "cc0066"
export(Color) var compare_border_default = "cccccc"

### background colors of item display rect
var rarity_colors = {
	0 : "9d9d9d",
	1 : "ffffff",
	2 : "1eff00",
	3 : "0070dd",
	4 : "a335ee",
	5 : "ff8000",
	6 : "e6cc80"
}



func _ready():
	$TextureRect.texture = image
	$Backdrop.modulate = rarity_colors[rarity]
	item_color = rarity_colors[rarity]
	if stack > 1:
		$MarginContainer/Stack_Size.text = str(stack)
	else:
		$MarginContainer/Stack_Size.text = ""
	$MarginContainer/Item_Name.text = display_name
	$MarginContainer/Item_Slot.text = "%s" % game.itemslot_name.get(slot)
	$MarginContainer/Item_Price.text = str(price)
	
	
func _input(event):
	
	if event is InputEventMouseButton:
		
		if ( exchange_panel.hovered_item == self ) and ( event.button_index == BUTTON_LEFT ) and event.pressed:
			
			if Input.is_action_pressed("compare"):
				_compare_item(true)
				
			if Input.is_action_pressed("split_stack") and max_stack > 1:
				
				var stack_split = load("res://gui/game_menu/trading/Split_Stack.tscn").instance()
				stack_split.stack_node = self
				exchange_panel.add_child(stack_split)
				
				
			elif ( not exchange_panel.is_exchanging ) and ( event.doubleclick ):
				_compare_item(false)
				exchange_panel.item_doube_clicked(get_item_data())
			
func _on_stack_changed(new_stack_size):
	var diff = stack - new_stack_size
	stack = new_stack_size
	exchange_panel.split_stack(item_owner, get_item_data(), diff)
	
	
	
	
func get_item_data() -> Dictionary:
	var data : Dictionary = {
		"drop_origin" : get_parent(),
		"item_node" : self,
		"item_owner" : item_owner,
		"item_id" : item_id, 
		"display_name" : display_name,
		"item_color" : item_color,
		"rarity" : rarity,
		"description" : description,
		"image" : image,
		"category" : category,
		"slot" : slot,
		"stats" : stats,
		"stack" : stack,
		"max_stack" : max_stack,
		"base_price" : base_price,
		"price" : price
		}
	return data

func get_drag_data(_pos):
	
	### if we can't sell the item don't allow a drag
	if can_sell == false:
		return
	
	### prevent new item drag while exchange panel is rearranging the old one
	if exchange_panel.is_exchanging:
		return

	### create a mousedrag display to stick with the mousepointer
	var preview = TextureRect.new()
	preview.expand = true
	preview.texture = image
	preview.rect_min_size = rect_min_size
	preview.rect_size = rect_size
	set_drag_preview(preview)

	### create and signal a Dictionary with all item and origin informations for dragdata
	emit_signal("dragged", get_item_data())
	return get_item_data()



func _compare_item(value : bool = true):
	if exchange_panel.compared_item:
		exchange_panel.compared_item.get_node("Compare").visible = false
	exchange_panel.compared_item = self
	get_node("Compare").visible = value
	if value:
		emit_signal("compared", get_item_data(), self)
	else:
		get_node("Compare").visible = false
		emit_signal("uncompare")
		
		
		
func can_drop_data(_pos, data):
	### don't allow drops on itemslots in trading
	return 


func drop_data(_pos, drop_item_id):
	item_id = drop_item_id

	
func _on_Itemslot_mouse_entered():
	
	### create and signal a Dictionary with all item informations for the mousehover tooltip

		
	emit_signal("hovered", get_item_data(), self)
	


func _on_Itemslot_mouse_exited():
	emit_signal("unhovered", self)
