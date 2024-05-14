## MaxLineLimitFilter (TextFilter)
##
## Provides a maximum line limit on input received by affected UI text control.
## Attach filter script as child node of a text control.
##
## See the text_filter.md file for detailed usage instructions and examples.

@icon("text_filter.svg")
class_name MaxLineLimitFilter
extends TextFilter

signal applied
signal rejected(line_limit)

@export var line_limit: int = 10

#region InputFilter implemented overrides

## Filters the given input value based on the logic in the
## concrete filter implementation.
##
## * return Authority - enum value indicating the outcome of
##                         the filtering process
func _filter() -> Authority:
	if _total_line_count() > line_limit:
		return Authority.REJECT
	
	return Authority.APPLY

#endregion

#region InputAuthority implemented overrides

# emit rejected with the configured line limit
#
# protected: Can be overridden to emit alternative signals or
# logic when the input is considered rejected.
#
# * emit rejected signal - if declared in a subclass.
func _emit_rejected():
	rejected.emit(line_limit)

#endregion

#region private

## get the control's line count plus any new lines that will be
## appended to the control text if the input text is received
##
## * return bool - the line count after input
func _total_line_count() -> int:
	# count the new lines from the captured input
	var new_line_count = input_text.split("\n", true).size() - 1
	
	return control.get_line_count() + new_line_count

#endregion