extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_label(label):
	$Label.bbcode_enabled = true
	$Label.bbcode_text = "[center]" + label + "[/center]"