extends CanvasLayer

@export var dogs : Array[DogResource] = []
var temp 

func _ready() -> void:
	if !dogs:
		%Dog.hide()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
