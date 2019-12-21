 extends Control

var text : String
onready var label = $MarginContainer/Label
onready var animate = $GUI_Menu_AnimationPlayer

func _ready():
	label.text = text
	animate.play("show")


func _on_Timer_timeout():
	animate.play("hide")
	yield(animate, "animation_finished")
	queue_free()
