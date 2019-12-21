extends Resource

class_name Item


export var item_id : String = ""
export var display_name : String = ""
export var description : String = ""
export(Texture) var image

var stack : int = 1
export(int) var max_stack = 1
export var unique : bool = false
export var sellable : bool = true
export(int) var base_price = 0
enum Category { TRASH, CONSUMABLE, MATERIAL, KEY, EQUIPMENT }
export(Category) var category = Category.TRASH
enum Rarity { TRASH, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY , ARTIFACT}
export(Rarity) var rarity = Rarity.TRASH
