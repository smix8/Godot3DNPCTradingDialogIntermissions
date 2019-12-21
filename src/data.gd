extends Node


const IMAGES_SOURCE_DIRECTORY = "res://assets/images"
const IMAGES_REFERENCES_SOURCE = "res://data/images/image_data.json" 
const ITEMS_SOURCE_DIRECTORY = "res://data/items"
const ITEM_REFERENCES_SOURCE ="res://data/items/items_data.json"


var image_data : Dictionary = {}
var item_data : Dictionary = {}



func _ready():
	pass



func scan_assets():
	var file = File.new()
	var all_images_dict : Dictionary = scan_dir_for_images(IMAGES_SOURCE_DIRECTORY)
	if file.open(IMAGES_REFERENCES_SOURCE, File.WRITE) != 0:
		print("Error opening json image file")
		return
	file.store_line(to_json(all_images_dict))
	file.close()
	
	var all_items_dict : Dictionary = scan_dir_for_items(ITEMS_SOURCE_DIRECTORY)
	if file.open(ITEM_REFERENCES_SOURCE, File.WRITE) != 0:
		print("Error opening json item file")
		return
	file.store_line(to_json(all_items_dict))
	file.close()
	
	
	
func init_asset_refs():
	var file = File.new()
	
	assert(file.file_exists(IMAGES_REFERENCES_SOURCE))
	file.open(IMAGES_REFERENCES_SOURCE, file.READ)
	var images_refs = parse_json(file.get_as_text())
	assert(images_refs.size() > 0)
	#print(images_refs)
	for key in images_refs:
		image_data[key] = images_refs[key]
	print("loaded image refs")
	
	assert(file.file_exists(ITEM_REFERENCES_SOURCE))
	file.open(ITEM_REFERENCES_SOURCE, file.READ)
	var item_refs = parse_json(file.get_as_text())
	assert(item_refs.size() > 0)
	#print(audio_refs)
	for key in item_refs:
		item_data[key] = item_refs[key]
	print("loaded item refs")
	
	
	
func scan_dir_for_items(path):
	var file_name
	var files = {}
	var dir = Directory.new()
	var error = dir.open(path)
	if error!=OK:
		print("Can't open "+path+"!")
		return
	dir.list_dir_begin(true)
	file_name = dir.get_next()
	while file_name!="":
		if dir.current_is_dir():
			var new_path = path+"/"+file_name
			var new_dict_files = scan_dir_for_items(new_path)
			merge_dir(files,new_dict_files)
		else:
			if file_name.ends_with(".tres"):
				var file_path = path.plus_file(file_name)
				files[file_name.get_basename()] = file_path
		file_name = dir.get_next()
	dir.list_dir_end()
	return files
	
	
	
func scan_dir_for_images(path):
	var file_name
	var files = {}
	var dir = Directory.new()
	var error = dir.open(path)
	if error!=OK:
		print("Can't open "+path+"!")
		return
	dir.list_dir_begin(true)
	file_name = dir.get_next()
	while file_name!="":
		if dir.current_is_dir():
			var new_path = path+"/"+file_name
			var new_dict_files = scan_dir_for_images(new_path)
			merge_dir(files,new_dict_files)
		else:
			if file_name.ends_with(".webp") or file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				var file_path = path.plus_file(file_name)
				files[file_name.get_basename()] = file_path
		file_name = dir.get_next()
	dir.list_dir_end()
	return files
	
	
	
static func merge_dir(target, patch):
	### helper function two merge two Dictionary
	for key in patch:
		if target.has(key):
			### if a key already exists we need a warning to manual check what we overwrite
			print("double key: " + key)
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				### if our key is just another dictionary we merge the content
				merge_dir(tv, patch[key])
			else:
				### if we have identical keys the value of the patch always wins
				target[key] = patch[key]
		else:
			target[key] = patch[key]
