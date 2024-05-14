## TextFilter (TextInputAuthority)
##
## Provides a mechanism for filtering and modifying input in text-based controls.
## Attach filter scripts as child nodes to text controls to customize their input behavior.
##
## - Filters operate on individual input events before they are applied to the text control.
## - Each filter can modify, reject, or allow input based on custom logic.
## - Feedback mechanisms (signals or custom actions) can be implemented to provide UI feedback or perform other
##   actions based on filter results.
##
## See the text_filter.md file for detailed usage instructions and examples.

class_name TextFilter
extends TextInputAuthority

signal pre_filter_text(from: String, event: InputEvent)

@export var supress_filter_warnings: bool = false

#region default implementation

# Filters the given input value based on the logic in the 
# concrete filter implementation.
#
# * return Authority - enum value indicating the outcome of 
#                         the filtering process
func _filter() -> Authority:
	if not supress_filter_warnings:
		!(WARN_METHOD_NOT_IMPLEMENTED % [
			' _filter() -> Authority', 
			'InputFilter'])

	return Authority.UNAPPLIED

#endregion

#region InputAuthority implemented overrides

# applies _filter to the InputAuthority's _evaluate_authority
#
# protected: Should be overridden in subclasses to resolve 
# an Authority based on the given input_text or captured_text
#
# * return Authority - enum value indicating the verdict of 
#                         the authority evaluation
func _evaluate_authority() -> Authority:
	return _filter()

#endregion

#region InputCaptor implemented overrides

# override _can_evaluate_input_event to emit the pre_filter_text signal
# 
# protected: Can be overridden to decide if the node should process
# input without requiring the InputCaptor to be enabled/disabled 
# allows subclasses to make the decision 
#
# * override in subclass
# * return bool - true if input should be evaluated 
#               - false if input should pass through 
func _can_evaluate_input_event(event: InputEvent) -> bool:
	pre_filter_text.emit(captured_text, event)
		
	return true

#endregion
