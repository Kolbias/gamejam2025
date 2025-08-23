extends Control

var temp 

@export var dog_display_scene : PackedScene

enum GameState {TITLE, DOGS, MENU, MAP}

var state := GameState.TITLE
var mouse_on_map := false

func _ready() -> void:
	Globals.connect("change_state", change_state)

func _process(delta: float) -> void:
	%WaterBar.value = Globals.water
	match state:
		GameState.TITLE:
			%Title.show()
		GameState.DOGS:
			%Menu.hide()
			%Map.hide()
			%DogCollection.show()

				
		GameState.MAP:
			%Menu.hide()
			%DogCollection.hide()
			%Map.show()
		GameState.MENU:
			%Title.hide()
			%DogCollection.hide()
			%Map.hide()
			%Menu.show()
	if mouse_on_map:
		var mouse_pos = get_global_mouse_position()
		#var tween = get_tree().create_tween()
		if Input.is_action_just_pressed("left_click"):
			print("mouse pos on click: " + str(mouse_pos))
			var dir = (get_viewport().get_mouse_position() - get_viewport_rect().size / 2).normalized()
			var speed = 15.0
			var target = %MapBackground.position - dir * speed
			print(target)
			print("map pos" + str(%MapBackground.position))
			var tween = get_tree().create_tween()
			tween.tween_property(%MapBackground, "position", target, 0.5)
			
			
func collect_new_dog(dog: DogResource):
	Globals.dogs.append(dog)

	var instance = dog_display_scene.instantiate()
	dog.setup_frames()
	%TabContainer.add_child(instance)
	instance.set_display(dog)
		
func _on_player_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("dog"):
		collect_new_dog(area.get_dog_from_map())
		print("New dog collected!")
		print("dogs: " + str(Globals.dogs))
		area.queue_free()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func change_state(new_state):
	print("new state: " + str(new_state))
	state = new_state

func _on_play_button_pressed() -> void:
	change_state(GameState.MENU)

func _on_menu_button_pressed() -> void:
	print("changing State to Menu")
	change_state(GameState.MENU)

func _on_collection_button_pressed() -> void:
	change_state(GameState.DOGS)
	
func _on_map_button_pressed() -> void:
	change_state(GameState.MAP)

func _on_control_mouse_entered() -> void:
	print("mouse on map")
	mouse_on_map = true

func _on_control_mouse_exited() -> void:
	print("mouse left map")
	mouse_on_map = false

func _on_forward_button_pressed() -> void:
	if GameState.DOGS:
		Globals.emit_signal("next_dog")

func _on_back_button_pressed() -> void:
	if GameState.DOGS:
		Globals.emit_signal("prev_dog")
		
func _on_water_timer_timeout() -> void:
	Globals.water += 1
