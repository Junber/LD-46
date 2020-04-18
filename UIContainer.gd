extends MarginContainer

func _ready():
	$SickHappinessUI.visible = false
	$PetHappinessUI.visible = true

func _on_Tamagotchi_switch_to_pet():
	$SickHappinessUI.visible = false
	$PetHappinessUI.visible = true

func _on_Tamagotchi_switch_to_sick():
	$SickHappinessUI.visible = true
	$PetHappinessUI.visible = false
