@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("DebugFilter", "Node", preload("res://addons/input_kid/text/filters/debug_filter.gd"), preload("res://addons/input_kid/text/filters/text_filter.svg"))
	add_custom_type("HardCharacterLimitFilter", "Node", preload("res://addons/input_kid/text/filters/hard_character_limit_filter.gd"), preload("res://addons/input_kid/text/filters/text_filter.svg"))
	add_custom_type("MaxLineLimitFilter", "Node", preload("res://addons/input_kid/text/filters/max_line_limit_filter.gd"), preload("res://addons/input_kid/text/filters/text_filter.svg"))
	add_custom_type("SoftCharacterLimitFilter", "Node", preload("res://addons/input_kid/text/filters/soft_character_limit_filter.gd"), preload("res://addons/input_kid/text/filters/text_filter.svg"))

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("DebugFilter")
	remove_custom_type("HardCharacterLimitFilter")
	remove_custom_type("MaxLineLimitFilter")
	remove_custom_type("SoftCharacterLimitFilter")
	
