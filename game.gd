extends CanvasLayer

@export var dogs : Array[DogResource] = []
var temp 

enum GameState {TITLE, DOGS, MENU, MAP}

var state := GameState.MENU

func _ready() -> void:
	Globals.connect("change_state", change_state)

func _process(delta: float) -> void:
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

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func change_state(new_state):
	print("new state: " + str(new_state))
	state = new_state

func _on_menu_button_pressed() -> void:
	print("changing State to Menu")
	change_state(GameState.MENU)

func _on_collection_button_pressed() -> void:
	change_state(GameState.DOGS)
	
func _on_map_button_pressed() -> void:
	change_state(GameState.MAP)
