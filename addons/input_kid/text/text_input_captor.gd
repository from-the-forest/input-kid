## TextInputCaptor (TextInputAffector)
##
## Provides a consistent pattern for parasitically capturing control input text and 
## then releasing it to be consumed by the control.
##
## Attach subclasses of TextInputCaptor scripts as child nodes of a text control or 
## manually configure the affects property to select a text control within the scene tree
## to customize the control's behavior without directly extending the Control.

class_name TextInputCaptor
extends TextInputAffector

signal captured_text_changed(text: String)
signal unreleased_captive_input(value: Variant)
signal released_captive_input(value: Variant)

@export var enabled: bool = true
@export var supress_captor_warnings: bool = false

var input_text: String = ""
var captured_text: String = ""
var is_input_captured: bool = false

const NEW_LINE = '\n'
const WARN_METHOD_NOT_IMPLEMENTED = "WARN: %s can be declared by inhereted subclass of %s."

#region Node

# Called when the node receives input. Input is passed up the tree
# to the scene root or until a node handles it using 'set_input_as_handled'.
func _input(event):
	if (not _has_focus(event is InputEventKey and event.is_pressed()) or 
		event.is_queued_for_deletion()): return
	
	if not _can_evaluate_input_event(event): return
	
	# the ascii representation of the keypress 
	# e.g. Shift+2 whould cause event_text to be '@' 
	var event_text = char(event.unicode)

	if (affection() == Affection.TEXT_AFFECTION and 
		_handled_key(KEY_TAB, "\t", event)):
			pass
		
	elif (
		_handled_key(KEY_BACKSPACE, "\b", event) or
		_handled_key(KEY_ENTER, "\n", event) or 
		_handled_key(KEY_SPACE, " ", event) or 
		_handled_key(KEY_TAB, "\t", event) or 
		_handled_paste(event_text, event) or
		_handled_input(event_text, event)
		): get_viewport().set_input_as_handled()
	
	
	if is_input_captured and _should_release_captured_input():
		_release_captured_input()
	else:
		unreleased_captive_input.emit(input_text)
	
	_captured_input_resolved()
		
#endregion

#region default implementation

# protected: Can be overridden to decide if the node should process
# input without requiring the InputCaptor to be enabled/disabled 
# allows subclasses to make the decision 
#
# * override in subclass
# * return bool - true if input should be evaluated 
#               - false if input should pass through 
func _can_evaluate_input_event(event: InputEvent) -> bool:
	if not supress_captor_warnings:
		print(WARN_METHOD_NOT_IMPLEMENTED % [
			'_can_evaluate_input_event(event: InputEvent) -> bool', 
			'InputCaptor'])
		
	return true


# protected: Should be overridden in subclasses to fulfill the 
# purpose of needing to capture input. InputAuthority is such a
# subclass that offers an API for accepting or rejecting input
# and handling the corresponding states.
#
# * override in subclass
func _evaluate_captured_text() -> void:
	if not supress_captor_warnings:
		print(WARN_METHOD_NOT_IMPLEMENTED % [
			'_evaluate_captured_text() -> void', 
			'InputCaptor'])


# protected: Can be overridden in subclasses to determine
# if the affected control is still going to receive the  
# input after the capture resolution.
#
# * override in subclass
func _should_release_captured_input() -> bool:
	if not supress_captor_warnings:
		print(WARN_METHOD_NOT_IMPLEMENTED % [
			'_should_release_captured_input() -> bool', 
			'InputCaptor',
			])
			
	return true


# protected: Can be overridden in subclasses to execute any
# logic that would be required to finalise the resolution of 
# the input capture.
#
# * override in subclass
func _captured_input_resolved() -> void:
	if not supress_captor_warnings:
		print(WARN_METHOD_NOT_IMPLEMENTED % [
			'_captured_input_resolved() -> void', 
			'InputCaptor',
			])

#endregion

#region public

func is_enabled() -> bool:
	return enabled == true
	
func set_captured_text(text: String) -> void:
	captured_text = text
	captured_text_changed.emit(text)
	
func set_input_captured(value: bool) -> void:
	is_input_captured = value

#endregion

#region private

# private: determine if the control is focussed and 
# whether the filter should process an incoming 
# input event.
#
# * return bool - true if input fitering should 
#                 be attempted.
func _has_focus(is_valid_event_type) -> bool:
	return (
		is_valid_event_type and
		has_affection() and 
		is_enabled() and 
		control.has_focus() 
	)
	

# private: input handler 
# * return bool - true if input was captured by this handler
func _handled_key(key_code: int, set_input_text: String, event: InputEvent) -> bool:
	if event.pressed and event.keycode == key_code:
		_capture_input(set_input_text)
		return true

	return false

# private: input handler 
# * return bool - true if input was captured by this handler
func _handled_paste(event_text, event) -> bool:
	if event.as_text().length() == 1:
		if (event.is_action("ui_paste") or (
			event.is_command_or_control_pressed() and 
			event.physical_keycode == KEY_V)):
				_capture_input(DisplayServer.clipboard_get())
				return true

	return false
	
# private: input handler 
# * return bool - true if input was captured by this handler
func _handled_input(event_text, event) -> bool:
	if event_text.length() == 1:
		_capture_input(event_text)
		return true
		
	return false

# private: release captured input back to it's intended control
func _release_captured_input():
	release_input(input_text)
	set_captured_text(control.text)
	released_captive_input.emit(input_text)
	input_text = ""
	set_input_captured(false)


# private: capture captured_text 
func _capture_input(text: String) -> void:
	input_text = text
	if (control_affection == Affection.TEXT_AFFECTION or 
		control_affection == Affection.EDIT_TEXT_AFFECTION):
			_compose_captured_text()
			set_input_captured(true)
			_evaluate_captured_text()


# private: 
func _compose_captured_text() -> void:
	var lines: PackedStringArray = (control.text as String).split(NEW_LINE)
	
	if has_selections():
		for selection in selections():
			if selection[0].y != selection[1].y:
				var delete_lines = selection[1].y - selection[0].y
				# delete first segment
				lines[selection[0].y] = lines[selection[0].y].erase(
					selection[0].x, lines[selection[0].y].length() - selection[0].x)
				
				# delete middle segments
				# 
					
				# delete last segment
				lines[selection[1].y] = lines[selection[1].y].erase(0, selection[1].x)
				pass
			else:
				lines[selection[0].y] = lines[selection[0].y].erase(
					selection[0].x, selection[1].x - selection[0].x + 1)
					
		for caret in caret_coords():
			lines[caret.y] = lines[caret.y].insert(caret.x, input_text)
	
	else:
		for caret in caret_coords():
			if input_text == "\b":
				lines[caret.y] = lines[caret.y].erase(caret.x, 1)
			else:
				lines[caret.y] = lines[caret.y].insert(caret.x, input_text)
	
	set_captured_text(NEW_LINE.join(lines))

#endregion
