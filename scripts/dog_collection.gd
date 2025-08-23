extends Control


func _ready() -> void:
	Globals.connect("next_dog", display_next_dog)
	Globals.connect("prev_dog", display_prev_dog)
	

func display_next_dog():
	var tc := %TabContainer
	tc.current_tab = clamp(tc.current_tab + 1, 0, tc.get_tab_count() - 1)

func display_prev_dog():
	var tc := %TabContainer
	tc.current_tab = clamp(tc.current_tab - 1, 0, tc.get_tab_count() - 1)
