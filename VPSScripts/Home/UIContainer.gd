extends MarginContainer

func _ready():
	$SickHappinessUI.visible = false
	$PetHappinessUI.visible = true
	$AwakenessUI/TextureProgressBar.step = 100.0 / 6.0

func _on_HomeScreen_switch_to_pet():
	$SickHappinessUI.visible = false
	$PetHappinessUI.visible = true

func _on_HomeScreen_switch_to_sick():
	$SickHappinessUI.visible = true
	$PetHappinessUI.visible = false
