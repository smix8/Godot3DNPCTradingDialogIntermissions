
# Godot 3D Drag&Drop NPC Trading with Interactions and Dialog
Example project made with Godot 3.2 beta4

No longer developed and therefor archived.

![trading_demo](https://user-images.githubusercontent.com/52464204/71304376-030e7f80-23c6-11ea-9f3d-e2355f64a188.gif)

## Features | Examples:

- Prepared template resources for `new items` and `item slots` 
- Example for creating new items with `rarity levels` from a base item with visual item rarity border and background coloring
- Example for `mouse drag & drop` with different `dropzones` and `returns on reset` depending on `item ownership`
- Example for `price calculation` depending on `exchange rates` between the parties
- Example for `item tooltip on mouse hover` that scales and always `stays inside the viewport` size
- Example for `doubleclick items` and added `item comparison` to the tooltip with a keymodifier
- Example for stacking `notification messages` that autohide after a few seconds
- Scripts for `utility` that `scans for images and items` in defined folders at startup and create a dictionary for convenient access by filename.
This way you can always reorganize your image / item folder structure without breaking a million filepaths on projects that grow large
- Ruby colors!

## NOT included:
- Yasmin my trader girl from the demo is not included, bring your own 3d character actors.
- Layout is not intended for anything below full hd resolution ( well ... who wants to suffer a mouse controlled desktop game below this anyway )


## Setup | Usage

### Step 1 - Add Item Images
The example project comes with a premade trading scene that autostarts and various helper scripts to get you started but first we need some item images.

Place all your images in the `assets/images/` folder or below in as many subfolders as you need for your project and `use unique filenames` for them.
The image script scans for `.webp, .png.` and `.jpg` file endings.


![image_folder](https://user-images.githubusercontent.com/52464204/71303410-8c1eba00-23b8-11ea-9bf5-8de41650980e.JPG)

All found images are added as `key:value` pair to a dictionary with the imagename as key and the loadpath as value. From now on you can access the loadpath of images by typing `game.image_data.get("unique_image_name")` from everywhere in your game without caring for the excact path as long as you keep your imagenames unique e.g. with a prefix. If you need other formats edit the `scan_dir_for_images()` function in the `data` script.

### Step 2 - Add Item Resources
Place all your item resources in the `data/items/` folder or below in any subfolder. The scripts scans for all `.tres` resource files so don't mix them with anything else in the items subfolders. Same as with images, all items are added to a dictionary and you access them with `game.item_data.get("unique_item_name")`.

![resource_folder](https://user-images.githubusercontent.com/52464204/71303411-93de5e80-23b8-11ea-846c-e9a610a681db.JPG)

### Step 3 - Add Item Stats
Edit your item resources one by one. Give them a unique `item_id` , a `display_name`, a `desription` and your image. Some stats are already for the next expensions and have no effect rightnow apart from visuals like `max_stack` and `unique`. `sellable` prevents the items from showing up in trade, the `base_price` is the cost and sell value of the item before exchange modifiers are applied. `category`, `rarity` and `slot` are self-explanatory and pick from the pulldown menu what you see fit..

![item_stats](https://user-images.githubusercontent.com/52464204/71303426-d43ddc80-23b8-11ea-80e3-fd02b0f9b8cf.JPG)

### Step 4 - Add Trader NPC
You can add as many new trader npcs as you want with their own inventories.
The current setup is, that you add them as a child node to the `characters` node, name them how you want and attach the `NPC.gd` Script to the node.

![add_npcs](https://user-images.githubusercontent.com/52464204/71303880-02beb600-23bf-11ea-8481-7c10d27aa889.JPG)

### Step 5 - Add Items and Money to Inventory
At the moment there is a project cheat that adds all created items to both player and npc trader at the game start.
You find this block in the `game` script in the `_ready()` function. There you can see a script example how to create and add items as well as money to the inventories of both player and npc.

![add_items](https://user-images.githubusercontent.com/52464204/71303512-27fcf580-23ba-11ea-9c07-96614a64ba93.JPG)

### Step 6 - Start Trading
You can control the trade window manually by calling `game.start_trading( "the_trader_name" )` function from everywhere with the traders name as a text `string`.

![start_trade](https://user-images.githubusercontent.com/52464204/71303914-7bbe0d80-23bf-11ea-9d1c-061601ca6385.JPG)

There are two optional parameters as well. `inventory_id` replaces the npcs real inventory temporarily. This is usefull for quests or other special events where you want to hide the real inventory of the npc for this interaction. Selling and buying is still possible and sold player items are added to the real inventory to not get lost. The `dialog_id` at the moment serves no purpose but will be important when the dialog addon is added.



## License
MIT.
