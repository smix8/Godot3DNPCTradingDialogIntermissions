extends Control


var old_item_id : String = ""
onready var character_names = game.characters.names
onready var animate : AnimationPlayer = $AnimationPlayer
onready var tooltip_container = $MarginContainer/HBoxContainer/Itemtooltip_PanelContainer/MarginContainer/Itemtooltip_VBoxContainer
onready var compare_container = $MarginContainer/HBoxContainer/Compare_PanelContainer/MarginContainer/Compare_VBoxContainer
onready var compare_panel_container = $MarginContainer/HBoxContainer/Compare_PanelContainer
onready var margin = $MarginContainer
onready var panel = $Panel

export(Color) var default_color = "ffffff"
export(Color) var compare_better_color = "00ff28"
export(Color) var compare_worse_color = "ff0101"

var tooltip_item : Node
var compared_item : Node
var compare_base_price : int
var compare_trade_price : int
export(Vector2) var mouse_offset = Vector2(20,20)



func _ready():
	visible = false
	compare_panel_container.visible = false
	rect_size = Vector2.ZERO
	tooltip_container.get_node("Description").self_modulate = "9d9d9d"
	compare_container.get_node("Description").self_modulate = "9d9d9d"
	

func replace_tooltip_display(new_tooltip : Dictionary = {}, node = null) -> void:
		
	if ( not tooltip_item == node ) and ( node != null ):
		tooltip_item = node
		rect_size = Vector2.ZERO
		
		tooltip_container.get_node("Title").text = new_tooltip.get("display_name").format(character_names)
		tooltip_container.get_node("Title").self_modulate = new_tooltip.get("item_color")
		tooltip_container.get_node("Category").text = game.category_name.get(new_tooltip.get("category"), "")
		tooltip_container.get_node("Slot").text = "%s" % game.itemslot_name.get(new_tooltip.get("slot"), "")
		tooltip_container.get_node("Description").set_text("\"%s\"" % new_tooltip.get("description").format(character_names))
		if new_tooltip.get("stack") > 1:
			tooltip_container.get_node("Stacksize").text = "%s / %s" % [new_tooltip.get("stack"), new_tooltip.get("max_stack")]
		else:
			tooltip_container.get_node("Stacksize").text = ""
		tooltip_container.get_node("Price").text = "Baseprice $ %s" % new_tooltip.get("base_price")
		
		if new_tooltip.get("item_owner") == "player":
			tooltip_container.get_node("TradePrice").text = "Sells $ %s" % new_tooltip.get("price")
		elif new_tooltip.get("item_owner") == "trader":
			tooltip_container.get_node("TradePrice").text = "Costs $ %s" % new_tooltip.get("price")
		
		if compared_item:
			if new_tooltip.get("base_price") >= compare_base_price:
				compare_container.get_node("Price").modulate = compare_better_color
			else:
				compare_container.get_node("Price").modulate = compare_worse_color
			if new_tooltip.get("price") >= compare_trade_price:
				compare_container.get_node("TradePrice").modulate = compare_better_color
			else:
				compare_container.get_node("TradePrice").modulate = compare_worse_color
		
		### controls have the habit of not updating expand size in time, adjust them twice so the background scales correct
		adjust_size()
		adjust_size()
		visible = true
		set_process(true)
		
		if old_item_id != new_tooltip.get("item_id"):
			animate.play("tooltip")
			old_item_id = new_tooltip.get("item_id")
			
	elif tooltip_item == node:
		visible = true
		
	else:
		visible = false



func replace_compare_tooltip(new_compare, node = null):
	
	if ( not compared_item == node ) and ( node != null ):
		
		compared_item = node
		
		compare_container.rect_size = Vector2.ZERO
		
		compare_container.get_node("Title").text = new_compare.get("display_name").format(character_names)
		compare_container.get_node("Title").self_modulate = new_compare.get("item_color")
		compare_container.get_node("Category").text = game.category_name.get(new_compare.get("category"), "")
		compare_container.get_node("Slot").text = "%s" % game.itemslot_name.get(new_compare.get("slot"), "")
		compare_container.get_node("Description").set_text("\"%s\"" % new_compare.get("description").format(character_names))
		if new_compare.get("stack") > 1:
			compare_container.get_node("Stacksize").text = "%s / %s" % [new_compare.get("stack"), new_compare.get("max_stack")]
		else:
			compare_container.get_node("Stacksize").text = ""
		compare_container.get_node("Price").text = "Baseprice $ %s" % new_compare.get("base_price")
		
		if new_compare.get("item_owner") == "player":
			compare_container.get_node("TradePrice").text = "Sells $ %s" % new_compare.get("price")
		elif new_compare.get("item_owner") == "trader":
			compare_container.get_node("TradePrice").text = "Costs $ %s" % new_compare.get("price")
			
		compare_base_price = new_compare.get("base_price")
		compare_trade_price = new_compare.get("price")
		compare_panel_container.visible = true		
		
	else:
		compare_panel_container.visible = false
		if compared_item:
			compared_item.get_node("Compare").visible = false
		compared_item = null
		compare_panel_container.rect_size = Vector2.ZERO
		
		

func adjust_size():
	
	### containers take some time to properly update so we wait two idleframes for them
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	var max_child_size : Vector2 = Vector2.ZERO
	
	for child in tooltip_container.get_children():
				
		if child.rect_size.x > max_child_size.x:
			max_child_size.x = child.rect_size.x
		max_child_size.y += child.rect_size.y	

	var margin_padding : Vector2 = Vector2.ZERO
	margin_padding.x = margin.get("custom_constants/margin_left")
	margin_padding.x += margin.get("custom_constants/margin_right")
	margin_padding.y = margin.get("custom_constants/margin_top")
	margin_padding.y += margin.get("custom_constants/margin_bottom")
		
	var new_size = Vector2(
		( max_child_size.x + margin_padding.x ),
		( max_child_size.y + margin_padding.y )# * tooltip_container.get_child_count()
	)
	
	rect_size = new_size




func _process(delta):
		
	if visible:
		var windowsize = get_viewport_rect().size
		var mousepos = get_viewport().get_mouse_position()
		
		### if the container is to large and goes beyond our viewport push it back inside
		if mousepos.x + mouse_offset.x + rect_size.x + compare_panel_container.rect_size.x + margin.get("custom_constants/margin_right") >= windowsize.x:
			mousepos.x = windowsize.x -mouse_offset.x - rect_size.x -compare_panel_container.rect_size.x - margin.get("custom_constants/margin_left") - margin.get("custom_constants/margin_right")
		if mousepos.y + mouse_offset.y + rect_size.y + margin.get("custom_constants/margin_bottom") >= windowsize.y:
			mousepos.y = windowsize.y -mouse_offset.y - rect_size.y - margin.get("custom_constants/margin_bottom")
		
		rect_position = Vector2(mousepos.x + mouse_offset.x, mousepos.y + mouse_offset.y)

	else:
		set_process(false)
		
	
