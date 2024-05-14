# TextFilter

TextFilter is an add-on for Godot Engine that provides input filtering capabilities for various UI text controls. It allows you to create custom filters to validate, modify, or reject user input before it's applied to the control's text property.

Attach a text filter script (such as the ones provided in [res://addons/**add-on**/filters/...](filters/hard_character_limit_filter.gd), or your own TextFilter inherited scripts) to a child of the UI text Control node you want to filter.

## TextFilter Class

###### [res://addons/input_kid/text/filters/text_filter.gd](text_filter.gd)

This is the base class for implementing text filters. To create your own filter, extend this class and implement the `_filter` method.

You can find sample implementations in the `/text/filters/` directory of this add-on.

## Nodes Suitable for Attaching Child TextFilters

TextFilter works with `TextEdit` and `LineEdit` Control nodes and their derivatives. It can also be used with custom Control nodes that comply with Godot's standard text editing API.

## Using existing TextFilters

1. **Locate Existing Filters:** The `/text/filters/` directory contains a selection of TextFilter extensions you are welcome to use them in your Godot projects if they meet your needs. 
2. **Attach as Child:** Attach the script to a Node that is a **direct child** of the Control node you want to filter for automatic affection for the control otherwise manually set the `affects` property from editor or script.

## Overview - Creating New TextFilters

1. **Create a New Script:** Extend the `TextFilter` class.
2. **Implement `_filter`:** This function should analyze the input and return an `Authority` (see [TextInputAuthority](../text_input_authority.gd) class for details) value indicating how the input should be handled.
3. **Attach as Child:** Attach the script to a Node that is a **direct child** of the Control node you want to filter for automatic affection for the control otherwise manually set the `affects` property from editor or script.

## Extending TextFilter Class

1. Extend `TextFilter`

```GDScript2
class_name HardCharacterLimitFilter
extends TextFilter
```

2. Customize functionality

```GDScript2
@export var character_limit: int = 128
```

3. Declare required signals

```GDScript2
signal applied
signal rejected(character_limit)
```

4. Override `_filter()`

```GDScript2
func _filter() -> Authority:
    # captured_text is an inherited property of input_captor
    if captured_text.length() > character_limit:
            return Authority.REJECT
    
    return Authority.APPLY
```

5. Override `_emit_` methods for custom signals

```GDScript2
## emit rejected signal with character_limit parameter
func _emit_rejected():
	rejected.emit(character_limit)
```

## TextInputAuthority Authority enum

| Value          | Description                                                                  |
|----------------|------------------------------------------------------------------------------|
| APPLY          | Input is to be applied to the text control.                                  |
| APPLY_INVALID  | Input should affect the text control _as-is_ <br> while considered invalid.  |
| APPLY_MODIFIED | Input has been modified by the `_filter`.                                    |
| REJECT         | Block input from reaching UI text Control.                                   |  

## Implement Signals

You must declare any signals required by your subclass. **TextFilter** does not declare signals by default, but it will notice and call the following signals if they are defined on your subclass, and you have not overridden the default behaviour of `_captured_input_resolved()`

| Signal   | Authority       | Emitted by (Default) |
|----------|-----------------|----------------------|
| invalid  | APPLY_INVALID   | `_emit_invalid()`    |
| modified | APPLY_MODIFIED  | `_emit_modified()`   |
| rejected | REJECT          | `_emit_rejected()`   |  
| applied  | APPLY           | `_emit_applied()`    |

## Implement `_filter`

The following examples should demonstrate the basics of defining a text filter's logic.

Returning **APPLY** from a `_filter()` will accept all input provided by the user.

```GDScript2
func _filter() -> Authority:	
	return Authority.APPLY
```

Returning **REJECT** from a `_filter()` will block all input and the affected UI text Control will never receive the `captured_text`. In this way filters can be designed to disallow certain types of input.

```GDScript2
func _filter() -> Authority:	
	if captured_text.length() > 10
		return Authority.REJECT

	return Authority.APPLY
```

If the intention is to modify the users input before it reaches the UI text Control this can also be done within the `_filter()` method while also returning **APPLY_MODIFIED**

```GDScript2
@export var repeat_times: int = 3
func _filter() -> Authority:	
	captured_text = captured_text.repeat(repeat_times)
	return Authority.APPLY_MODIFIED
```

## Customizing Behaviour

After `_filter()` has executed and returned an **Authority**, `_captured_input_resolved()` uses the **Authority** generated by `_filter()`'s execution to determine which, if any, related actions should occur.

If `_captured_input_resolved()` is overridden in a subclass derivative, it is the developer's responsibility to define any signals or further logic required by their implementation. `_captured_input_resolved()`'s default implementation makes a subsequent method call for each of the **Authority** options. These methods are named `_emit_{signal_name}()` and will attempt to trigger a similarly named signal if it has been declared on the extended TextFilter. It is up to the developer to declare which signals their implementation requires which also allows for flexibility in declaring signals with parameters which wouldn't be possible if the signals were declared in the base class.

If the resulting Authority is **REJECT**, the associated input will be automatically blocked from reaching the text Control. The `_captured_input_resolved()` will call `_emit_rejected()` to emit the default rejected signal, if it has been declared, and you may want to trigger a UI state or display a message in response by binding to the `rejected` signal from the scene.

This flow through `_captured_input_resolved()` is identical for each of the ALLOW_INPUT... variants, in turn making a call to `_emit_applied()`, `_emit_modified()` or `_emit_invalid()`. In cases where the `_filter()` result is an **ALLOW_*** variant the input text is not blocked and the text Control's text value will be modified triggering its text_changed event internally.

Individual `_emit_{signal_name}()` methods can be overridden in extended implementations allowing for custom behaviour or custom signals to be called for that Authority while still taking advantage of the default behaviour for other Authority's.

## Working with Custom Nodes

TextFilter expects the following properties and signals to be present on the target text Control node:

| Declare   | Description                                |
| --------- | ------------------------------------------ |
| @property | `text: String`                             |
| @signal   | `text_changed`                             |

TextFilter also expects one of these sets of methods to be available on the target text Control node:

| Declare   | Description                                                    |
| --------- | -------------------------------------------------------------- |
| @method   | `insert_text_at_caret(text: String) -> void`                    |
|           | -or-                                                           |
| @method   | `insert_text_at_caret(text: String, caret_index: int = -1) -> void` |
| @method   | `get_caret_index_edit_order() -> PackedInt32Array`               |

## Using Custom Signals

TextFilter does not provide signals by default so that extended implementations have the opportunity to declare their own with parameters. In cases where the developer has specified a non-default signature for the signal, the `_emit_...` function should also be overridden

```GDScript2
## Example rejected signal with character_limit

signal rejected(character_limit)
@export var charcter_limit: int = 10

func _feedback_rejected():
	rejected.emit(character_limit)
```

TextFilter implementations can declare signals using the default names providing the `_captured_input_resolved()` method's behaviour is not modified in an override. If you choose to override `_captured_input_resolved()` you can use `input_classified_as:Authority` to perform any actions or emit custom signals.

```GDScript2
signal custom_signal(text, classifier)

func _captured_input_resolved() -> void:
	match input_classified_as:
		Authority.APPLY_INPUT:
			_emit_applied()
		_:
			custom_signal.emit(input_text, input_classified_as)
```

## Error Handling

If you encounter unexpected behavior, double-check the following:

*  Ensure your filter script is attached as a direct child of the text Control node.
*  Verify that your custom Control node implements the required properties and methods.
*  If using custom signals, confirm that their names and signatures match your `_emit_...()` method implementations.
