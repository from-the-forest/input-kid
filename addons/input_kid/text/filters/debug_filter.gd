## DebugFilter (TextFilter)
##
## Sample InputFilter that prints captured_text and event information to output on 
## the pre_filter_text singal.
## 
## InputFilter Provides a mechanism for filtering and modifying input in text-based controls.
## Attach filter scripts as child nodes to text controls to customize their input behavior.
##
## - Filters operate on individual input events before they are applied to the text control.
## - Each filter can modify, reject, or allow input based on custom logic.
## - Feedback mechanisms (signals or custom actions) can be implemented to provide 
##   UI feedback or perform other actions based on filter results.
##
## See the text_filter.md file for detailed usage instructions and examples.

@icon("text_filter.svg")
class_name DebugFilter
extends TextFilter

signal applied

#region node

func _ready():
	super()
	if not pre_filter_text.is_connected(on_pre_filter_text):
		pre_filter_text.connect(on_pre_filter_text)

func _exit_tree():
	pre_filter_text.disconnect(on_pre_filter_text)

#endregion

#region InputFilter implemented overrides

# Filters the given input value based on the logic in the
# concrete filter implementation.
#
# * return Authority - enum value indicating the outcome of
#                         the filtering process
func _filter() -> Authority:
	return Authority.APPLY
	
#endregion

#region private

# pre_filter_text signal handler
func on_pre_filter_text(from, event):
	_debug_input(from, event as InputEventKey)

# output debug info for the given input event
func _debug_input(type: String, event: InputEventKey) -> void:
	print('\n'.join([
		"\n\n=====================================",
		type.to_upper(),
		"as physical keycode with mods: %s" % event.get_physical_keycode_with_modifiers(),
		"os key mod: %s" % OS.get_keycode_string(event.get_modifiers_mask()),
		"os key: %s" % OS.get_keycode_string(event.physical_keycode),
		"physical keycode: %s" % event.physical_keycode,
		"is cmd or ctrl: %s" % event.is_command_or_control_pressed(),
		"unicode: %s" % event.unicode,
		"is pressed: %s" % event.is_pressed(),
		"is released: %s" % event.is_released(),
		"=====================================\n\n"
	]))

#endregion
