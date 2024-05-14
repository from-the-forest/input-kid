## InputAuthority (InputCaptor)
##
## Provides a consistent pattern for parasitically accepting or rejecting 
## control input text and then issuing relevant singals or override logic.
##
## Attach subclasses of InputAuthority scripts as child nodes of a text control or 
## manually configure the affects property to select a text control within the scene tree
## to customize the control's behavior without directly extending the Control.

class_name TextInputAuthority
extends TextInputCaptor

enum Authority {
	UNAPPLIED,
	APPLY, 
	APPLY_INVALID,
	APPLY_MODIFIED, 
	REJECT, 
}

@export var supress_authority_warnings: bool = false

var input_classified_as: Authority = Authority.UNAPPLIED

const INFO_DEFAULT_IMPLEMENTATION_CALLED = "INFO: default implementation of '_emit_%s() -> void' called by %s without declaring the %s signal."

#region default implementation

# protected: Should be overridden in subclasses to resolve 
# an Authority based on the given input_text or captured_text
#
# * return Authority - enum value indicating the verdict of 
#                         the authority evaluation
func _evaluate_authority() -> Authority:
	if not supress_authority_warnings:
		print(WARN_METHOD_NOT_IMPLEMENTED % [
			'_evaluate_authority() -> Authority', 
			'InputAuthority',
			])
		
	return Authority.APPLY


# protected: Can be overridden to emit alternative signals or 
# logic when the input is accepted and applied as-is.
#
# * emit applied signal - if declared in a subclass.
func _emit_applied() -> void: _emit_signal('applied')


# protected: Can be overridden to emit alternative signals or 
# logic when the input is considered invalid.
#
# * emit invalid signal - if declared in a subclass.
func _emit_invalid() -> void: _emit_signal('invalid')


# protected: Can be overridden to emit alternative signals or 
# logic when the input is considered modified.
#
# * emit modified signal - if declared in a subclass.
func _emit_modified() -> void: _emit_signal('modified')


# protected: Can be overridden to emit alternative signals or 
# logic when the input is considered rejected.
#
# * emit rejected signal - if declared in a subclass.
func _emit_rejected() -> void: _emit_signal('rejected')

#endregion

#region InputCaptor implemented overrides

# applies _evaluate_authority to the InputCaptors _evaluate_captured_text
# 
# protected: Should be overridden in subclasses to fulfill the 
# purpose of needing to capture input. InputAuthority is such a
# subclass that offers an API for accepting or rejecting input
# and handling the corresponding states.
#
# * override in subclass
func _evaluate_captured_text() -> void:
	input_classified_as = _evaluate_authority()


# checks input_classified_as to resolve the 
# InputCaptors _should_release_captured_input
# 
# protected: Can be overridden in subclasses to determine
# if the affected control is still going to receive the  
# input after the capture resolution.
#
# * override in subclass
func _should_release_captured_input() -> bool:
	return input_classified_as != Authority.REJECT


# handle the final resolution of authority to apply input to 
# affected control text

# protected: Can be overridden in subclasses to execute any
# logic that would be required to finalise the resolution of 
# the input capture.
#
# * override in subclass
func _captured_input_resolved() -> void:
	match input_classified_as:
		
		Authority.APPLY:
			# default FilterIntent.APPLY_INPUT can be 
			# used to clear feedback notifications in UI
			_emit_applied()
			
		Authority.APPLY_INVALID:
			_emit_invalid()
		
		Authority.APPLY_MODIFIED:
			_emit_modified()
			
		Authority.REJECT:
			_emit_rejected()

#endregion

#region private

# private: Default handler for the various _emit_ methods 
# responsible for emitting a subclass declared signal
func _emit_signal(signal_name: String) -> void:
	if has_signal(signal_name):
		Signal(self, signal_name).emit()
		return
		
	if not supress_authority_warnings:
		print(INFO_DEFAULT_IMPLEMENTATION_CALLED % [signal_name, self.get_name(), signal_name])

#endregion
