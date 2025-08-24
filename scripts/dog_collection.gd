extends Control


func _ready() -> void:
	Globals.connect("next_dog", display_next_dog)
	Globals.connect("prev_dog", display_prev_dog)
	

func display_next_dog():
	var tc := %TabContainer
	tc.current_tab = clamp(tc.current_tab + 1, 0, tc.get_tab_count() - 1)
	#if tc.current_tab == tc.get_tab_count() - 1:
		#Globals.emit_signal("disable_next")
	#else:
		#Globals.emit_signal("enable_next")
		
func display_prev_dog():
	var tc := %TabContainer
	tc.current_tab = clamp(tc.current_tab - 1, 0, tc.get_tab_count() - 1)
	#if tc.current_tab == 0:
		#Globals.emit_signal("disable_prev")
	#else:
		#Globals.emit_signal("enable_prev")
