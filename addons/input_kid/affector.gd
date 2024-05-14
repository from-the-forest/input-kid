## Affector (Node)
##
## Abstract mechanism for attaching parasitic overrides to Control.
##
## Attach subclasses of Affector scripts as child nodes of a Control or 
## manually configure the affects property to select a Control within the scene tree
## to customize the control's behavior without directly extending the Control.

class_name Affector
extends Node

@export_node_path("Control") var affects: NodePath

var control: Control = null

#region node

# Called when the node enters the scene tree for the first time.
func _ready():
	_acknowledge_affects()

#endregion

#region default implementaton

# protected: Can be overridden to implement  
# flags or control specific configurations
#
# * override in subclass
func _evaluate_control() -> void:
	pass

#endregion

#region private

# private: Attempts to use the Control node provided by the afftects
# property or the parent of affects in undefined
func _acknowledge_affects() -> void:
	control = get_node(affects)
	if control == null:
		control = get_parent()
		affects = control.get_path()
		
	_evaluate_control()

#endregion


