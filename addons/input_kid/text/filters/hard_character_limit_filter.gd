## HardCharacterLimitFilter (TextFilter)
##
## Provides a hard character limit on input received by affected UI text control.
## Attach filter script as child node of a text control.
##
## See the text_filter.md file for detailed usage instructions and examples.

@icon("text_filter.svg")
class_name HardCharacterLimitFilter
extends TextFilter

signal applied
signal rejected(character_limit)

@export var character_limit: int = 10

#region InputFilter implemented overrides

# Filters the given input value based on the logic in the
# concrete filter implementation.
#
# * return Authority - enum value indicating the outcome of
#                         the filtering process
func _filter() -> Authority:
	if captured_text.length() > character_limit:
		return Authority.REJECT
	
	return Authority.APPLY

#endregion

#region InputAuthority implemented overrides

# emit rejected with the configured character limit
#
# protected: Can be overridden to emit alternative signals or
# logic when the input is considered rejected.
#
# * emit rejected signal - if declared in a subclass.
func _emit_rejected():
	rejected.emit(character_limit)

#endregion
