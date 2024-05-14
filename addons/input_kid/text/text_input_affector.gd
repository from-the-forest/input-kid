## TextInputAffector (Affector)
##
## Provides a mechanism for attaching parasitic overrides to text-based controls.
##
## Attach subclasses of InputAffector scripts as child nodes of a text control or 
## manually configure the affects property to select a text control within the scene tree
## to customize the control's behavior without directly extending the Control.

class_name TextInputAffector
extends Affector

enum Affection {
	UNAFFECTED,
	TEXT_AFFECTION,
	EDIT_TEXT_AFFECTION 
}

var control_affection: Affection = Affection.UNAFFECTED

const WARN_AFFECTION_NOT_IMPLEMENTED = "WARN: %s has no implementation for %s."
const WARN_OPERATION_NOT_AVAILABLE = "WARN: %s cannot %s for %s at this time."

#region public

# public: Affection 
# 
# * return Affection - the Affection for the 
#                      affects control
func affection() -> Affection:
	return control_affection

# public: InputAffector's Affection state
#
# * return bool - true if InputAffector has Affection
func has_affection() -> bool:
	return control_affection != Affection.UNAFFECTED

#endregion

#region control interface

func has_carets() -> bool:
	match(control_affection):
		Affection.EDIT_TEXT_AFFECTION:
			if not (control.has_method('get_caret_index_edit_order')):
				return false

		Affection.TEXT_AFFECTION:
			if not (control.has_method('get_caret_column')):
				return false
		
		_:
			print(WARN_AFFECTION_NOT_IMPLEMENTED % [
					'TextInputAffector',
					control_affection
				])
			return false

	return true

# public: When the control is only capable of a 
# single caret, the array contains a single element.
#
# * return PackedInt32Array - array of carets
func carets() -> PackedInt32Array:
	if not has_carets():
		return PackedInt32Array([0])

	match(control_affection):
		Affection.EDIT_TEXT_AFFECTION:
			return control.get_caret_index_edit_order()
		
		Affection.TEXT_AFFECTION:
			return PackedInt32Array([control.get_caret_column()])
		
		_:
			print(WARN_AFFECTION_NOT_IMPLEMENTED % [
					'TextInputAffector',
					control_affection
				])
			return PackedInt32Array([0])


# public: When the control is only capable of a 
# single caret, the array contains a single element.
#
# * return Array - array of caret coordinates
func caret_coords() -> Array:
	if not has_carets():
		return Array([Vector2i.ZERO])

	var array = Array()

	for caret in carets():
		match(control_affection):
			Affection.EDIT_TEXT_AFFECTION:
				array.append(Vector2i(
					control.get_caret_column(caret), 
					control.get_caret_line(caret)))
			
			Affection.TEXT_AFFECTION:
				array.append(Vector2i(control.get_caret_column(), 0))
				
			_: 
				array.append(Vector2i.ZERO)

	return array

func has_selections() -> bool:
	if not control.has_method('has_selection'): return false

	var control_selection = control.has_selection()
	
	if not control_selection: return false
	
	match(control_affection):
		Affection.EDIT_TEXT_AFFECTION:
			if not (control.has_method('get_selection_from_line') and
					control.has_method('get_selection_from_column') and
					control.has_method('get_selection_to_line') and
					control.has_method('get_selection_to_column')):
						return false

		Affection.TEXT_AFFECTION:
			if not (control.has_method('get_selection_from_column')):
				return false

	return control_selection
	
# public: When the control is only capable of a 
# single selection, the array contains a single selection.
#
# * return Array - array of caret coordinates or selections
func selections() -> Array:
	if not has_selections():
		return Array() 
	
	var array = Array()

	for caret in carets():
		var start = Vector2i(0,0)
		var end = Vector2i(0,0)
		
		match(control_affection):
			Affection.EDIT_TEXT_AFFECTION:
				array.append(Array([Vector2i(
					control.get_selection_from_column(caret),
					control.get_selection_from_line(caret)
				), Vector2i(
					control.get_selection_to_column(caret),
					control.get_selection_to_line(caret)
				)]))
			
			Affection.TEXT_AFFECTION:
				array.append(Array([
					Vector2i(control.get_selection_from_column(), 0), 
					Vector2i(control.get_selection_to_column(), 0)
				]))

	return array

func release_input(text) -> void:
	if not has_carets():
		print(WARN_OPERATION_NOT_AVAILABLE % [
			'TextInputAffector',
			'set_text(text)',
			control_affection
		])
		return
		
	if has_selections():
		for caret in carets():
			delete_selection(caret)
		
		if text != "\b":
			for caret in carets():
				insert_text_at_caret(text, caret)
	else:
		for caret in carets():
			if text == "\b":
				backspace(caret)
			else:
				insert_text_at_caret(text, caret)

func backspace(caret) -> void:
	match(control_affection):
		Affection.EDIT_TEXT_AFFECTION:
			control.backspace(caret)

		Affection.TEXT_AFFECTION:
			var col = control.get_caret_column()
			control.delete_text(col - 1, col)

func insert_text_at_caret(text, caret) -> void:
	match(control_affection):
		Affection.EDIT_TEXT_AFFECTION:
			control.insert_text_at_caret(text, caret)

		Affection.TEXT_AFFECTION:
			control.insert_text_at_caret(text)
			
		_:
			print(WARN_OPERATION_NOT_AVAILABLE % [
				'TextInputAffector',
				'insert_text(text, caret) -> void',
				control_affection
			])

func delete_selection(caret) -> void:
	match(control_affection):
		Affection.EDIT_TEXT_AFFECTION:
			control.delete_selection(caret)

		Affection.TEXT_AFFECTION:
			control.delete_text(
				control.get_selection_from_column(), 
				control.get_selection_to_column())
			control.deselect()
			
		_:
			print(WARN_OPERATION_NOT_AVAILABLE % [
				'TextInputAffector',
				'delete_selection(caret) -> void',
				control_affection
			])

#endregion

#region Affector implemented overrides

# protected: Identify the Affection by inspecting the control
# class and then it's properties for bespoke Edit classes
# that do not inheret TextEdit or LineEdit
#
# protected: Can be overridden to implement  
# flags or control specific configurations
#
# * override in subclass
func _evaluate_control() -> void:
	
	if control.is_class('TextEdit'):
		control_affection = Affection.EDIT_TEXT_AFFECTION
		
	elif control.is_class('LineEdit'):
		control_affection = Affection.TEXT_AFFECTION
	
	# handle non TextEdit controls that 
	# provide the TextEdit interface
	elif (control.has_signal('text_changed') and 
		control.has_method('insert_text_at_caret') and 
		control.has_method('get_caret_index_edit_order') and
		control.has_method('get_selection_from_line') and
		control.has_method('get_selection_from_column') and 
		control.has_method('get_selection_to_line') and
		control.has_method('get_selection_to_column') and
		control.has_method('delete_selection')
		):
			control_affection = Affection.EDIT_TEXT_AFFECTION

	# handle non LineEdit controls that 
	# provide the LineEdit interface
	elif (control.has_signal('text_changed') and 
		control.has_method('insert_text_at_caret') and 
		control.has_method('get_selection_from_column') and
		control.has_method('delete_text') and
		control.has_method('get_caret_column') and 
		control.has_method('deselect')):
			control_affection = Affection.TEXT_AFFECTION
			
	else:
		control_affection = Affection.UNAFFECTED

#endregion



