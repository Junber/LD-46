extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	set("theme_override_colors/default_color",Color(0.78,0.78,0.78))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_mouse_entered():
	set("theme_override_colors/default_color",Color(1,1,1))


func _on_Button_mouse_exited():
	set("theme_override_colors/default_color",Color(0.78,0.78,0.78))
