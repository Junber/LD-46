extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_label(label):
	$Label.bbcode_text = "[center]" + label + "[/center]"


func _on_Label_meta_hover_started(meta):
	pass # Replace with function body.
