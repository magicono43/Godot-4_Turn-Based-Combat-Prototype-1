extends VBoxContainer

@export var attackButton:Button
@export var magicButton:Button
@export var passButton:Button

func _ready() -> void:
	visibility_changed.connect(GrabFocus_OnChangedVisibility)

func GrabFocus_OnChangedVisibility()->void:
	attackButton.grab_focus()
