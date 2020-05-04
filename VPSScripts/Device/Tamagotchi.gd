extends Node2D

signal switch_to_sick
signal switch_to_pet
signal tamagotchi_died

signal eat
signal start_sleeping
signal end_sleeping
signal happy
signal refuse
signal sad
signal not_sad
signal start_talking
signal end_talking
signal hatch

signal button_pressed

enum STAGE{
	egg,
	baby,
	adult,
	old}

enum STATE{
	off,
	home,
	minigame,
	gameOver}

onready var stageSpriteMap = {
	STAGE.egg: $Screen/HomeScreen/NormalSprites/EggSprite,
	STAGE.baby: $Screen/HomeScreen/NormalSprites/BabySprite,
	STAGE.adult: $Screen/HomeScreen/NormalSprites/AdultSprite,
	STAGE.old: $Screen/HomeScreen/NormalSprites/OldSprite}

onready var stageNameMap = {
	"egg" : STAGE.egg,
	"young" : STAGE.baby,
	"adult" : STAGE.adult,
	"old" : STAGE.old}

var stage: int = STAGE.egg setget change_stage_to_without_animation
var state: int = STATE.home setget change_state_to
var sleeping: bool = false setget set_sleeping

var fullness: float = 100 setget set_fullness
var awakeness: float = 100 setget set_awakeness
var fun: float = 100 setget set_fun
var happiness: float = 100 setget set_happiness

var needDecay: float = 0

var highScore: int = 0 setget update_high_score

export(float) var needDecayPerSecond: float = 1
export(float) var needGain = 10
export(int) var minimumNeedAfterDialog: int = 15

const minigameScreenScene = preload("res://VPSScenes/Minigame/TamagotchiMinigameScreen.tscn")
onready var minigameScreen = $Screen/MinigameScreen
onready var homeScreen = $Screen/HomeScreen
onready var gameOverScreen = $Screen/GameOverScreen

onready var fullProgressBar = $Screen/HomeScreen/UIContainer/FullnessUI/TextureProgress
onready var awakeProgressBar = $Screen/HomeScreen/UIContainer/AwakenessUI/TextureProgress
onready var funProgressBar = $Screen/HomeScreen/UIContainer/FunUI/TextureProgress
onready var petHappyProgressBar = $Screen/HomeScreen/UIContainer/PetHappinessUI/TextureProgress
onready var sickHappyProgressBar = $Screen/HomeScreen/UIContainer/SickHappinessUI/TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("switch_to_pet")
	switch_to_home()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stage != STAGE.egg and state != STATE.off:
		needDecay += delta * needDecayPerSecond
		if needDecay > 1:
			needDecay -= 1
			if state == STATE.minigame:
				change_fun(10)
			elif not sleeping:
				change_all_needs(-1)
			else:
				change_fullness(-0.5)
				change_fun(-0.5)
				change_happiness(-0.5)
				change_awakeness(10)

func _input(event):
	if event.is_action_pressed("food"):
		press_food_button()
	elif event.is_action_pressed("sleep"):
		press_sleep_button()
	elif event.is_action_pressed("play"):
		press_play_button()
	elif event.is_action_pressed("extra"):
		press_extra_button()

func savedProperties():
	return ["stage",
		"highScore",
		"state",
		"fullness",
		"awakeness",
		"fun",
		"happiness"]

func is_animating() -> bool:
	return homeScreen.is_animating()
	
func set_sleeping(newState):
	sleeping = newState
	if sleeping:
		emit_signal("start_sleeping")
	else:
		emit_signal("end_sleeping")

func toggle_sleep():
	if is_satisfied(awakeness) and not sleeping:
		emit_signal("refuse")
	else:
		set_sleeping(not sleeping)

func set_fullness(newFullness):
	fullness = newFullness
	fullProgressBar.value = fullness
	react_to_low_needs()

func set_awakeness(newAwakeness):
	awakeness = newAwakeness
	awakeProgressBar.value = awakeness
	react_to_low_needs()

func set_fun(newFun):
	fun = newFun
	funProgressBar.value = fun
	react_to_low_needs()

func set_happiness(newHappiness):
	happiness = newHappiness
	petHappyProgressBar.value = happiness
	sickHappyProgressBar.value = happiness
	react_to_low_needs()

func change_fullness(amount, minValue = 0):
	if amount > 0 and is_satisfied(fullness):
		emit_signal("refuse")
	else:
		if amount > 0:
			emit_signal("eat")
		set_fullness(clamp(fullness + amount, min(minValue, fullness), 100))

func change_awakeness(amount, minValue = 0):
	if amount > 0 and is_satisfied(awakeness):
		toggle_sleep()
	else:
		set_awakeness(clamp(awakeness + amount, min(minValue, awakeness), 100))

func change_fun(amount, minValue = 0):
	if amount > 0 and is_satisfied(fun):
		emit_signal("refuse")
	else:
		set_fun(clamp(fun + amount, min(minValue, fun), 100))

func change_happiness(amount, minValue = 0):
	if amount > 0 and is_satisfied(happiness):
		emit_signal("refuse")
	else:
		if amount > 0:
			emit_signal("happy")
		set_happiness(clamp(happiness + amount, min(minValue, happiness), 100))

func change_all_needs(amount, minValue = 0):
	change_fullness(amount, minValue)
	change_awakeness(amount, minValue)
	change_fun(amount, minValue)
	change_happiness(amount, minValue)

func die_if_dead():
	if fullness <= 0 or awakeness <= 0 or fun <= 0 or happiness <= 0:
		die()

func be_sad_if_not_cared_for():
	if fullness <= 25 or awakeness <= 25 or fun <= 25 or happiness <= 25:
		if not is_animating() and not sleeping:
			emit_signal("sad")
	else:
		emit_signal("not_sad")

func react_to_low_needs():
	die_if_dead()
	be_sad_if_not_cared_for()

func die():
	emit_signal("tamagotchi_died")

func change_stage_to_without_animation(newStage):
	if newStage == STAGE.egg:
		if state == STATE.minigame:
			restart_minigame()
		if state != STATE.home:
			switch_to_home()
		
	hide_sprite(stage)
	stage = newStage
	show_sprite(stage)
	if stage == STAGE.old:
		emit_signal("switch_to_sick")

func change_stage_to(newStage):
	if stage == STAGE.egg:
		emit_signal("hatch")
	change_stage_to_without_animation(newStage)
	
func is_satisfied(need) -> bool:
	if need >= 100:
		return true
	return false

func hide_sprite(oldStage):
	stageSpriteMap[oldStage].visible = false
	stageSpriteMap[oldStage].playing = false

func show_sprite(newStage):
	stageSpriteMap[newStage].playing = true
	stageSpriteMap[newStage].visible = true
	

func switch_to_minigame():
	homeScreen.visible = false
	minigameScreen.visible = true
	gameOverScreen.visible = false
	get_tree().call_group("minigame_objects", "unpause")
	state = STATE.minigame

func switch_to_game_over(score = 0):
	homeScreen.visible = false
	minigameScreen.visible = false
	gameOverScreen.visible = true
	gameOverScreen.set_score(score)
	get_tree().call_group("minigame_objects", "pause")
	state = STATE.gameOver

func switch_to_off():
	homeScreen.visible = false
	minigameScreen.visible = false
	gameOverScreen.visible = false
	get_tree().call_group("minigame_objects", "pause")
	state = STATE.off

func switch_to_home():
	homeScreen.visible = true
	minigameScreen.visible = false
	gameOverScreen.visible = false
	get_tree().call_group("minigame_objects", "pause")
	state = STATE.home

func change_state_to(newState):
	if newState == STATE.off:
		switch_to_off()
	elif newState == STATE.gameOver:
		switch_to_game_over()
	elif newState == STATE.home:
		switch_to_home()
	elif newState == STATE.minigame:
		switch_to_minigame()


func restart_minigame():
	minigameScreen.queue_free()
	minigameScreen = minigameScreenScene.instance()
	$Screen.call_deferred("add_child", minigameScreen)
	minigameScreen.connect("game_over", $Screen, "_on_MinigameScreen_game_over")
	get_tree().call_deferred("call_group", "minigame_objects", "pause")

func update_high_score(score):
	if score > highScore:
		highScore = score
		gameOverScreen.set_high_score(highScore)


func press_food_button():
	emit_signal("button_pressed")
	if state == STATE.gameOver:
		switch_to_home()
	elif state == STATE.minigame:
		minigameScreen.move_left()
	elif not is_animating() and state != STATE.off and stage != STAGE.egg:
		if sleeping:
			toggle_sleep()
		change_fullness(needGain)


func press_sleep_button():
	emit_signal("button_pressed")
	if state == STATE.gameOver:
		switch_to_home()
	elif state == STATE.minigame:
		minigameScreen.shoot()
	elif not is_animating() and state != STATE.off and stage != STAGE.egg:
		toggle_sleep()


func press_play_button():
	emit_signal("button_pressed")
	if state == STATE.gameOver:
		switch_to_home()
	elif state == STATE.minigame:
		minigameScreen.move_right()
	elif not is_animating() and state != STATE.off and stage != STAGE.egg:
		if sleeping:
			toggle_sleep()
		switch_to_minigame()


func press_extra_button():
	emit_signal("button_pressed")
	if state == STATE.gameOver:
		switch_to_home()
	elif state == STATE.minigame:
		restart_minigame()
		switch_to_home()
	elif not is_animating() and state != STATE.off and stage != STAGE.egg:
		if sleeping:
			toggle_sleep()
		change_happiness(needGain)


func _on_FoodButton_pressed():
	press_food_button()

func _on_SleepButton_pressed():
	press_sleep_button()

func _on_PlayButton_pressed():
	press_play_button()

func _on_ExtraButton_pressed():
	press_extra_button()

func _on_DialogManager_reduce_awakeness(amount):
	change_awakeness(-amount, minimumNeedAfterDialog)

func _on_DialogManager_reduce_fullness(amount):
	change_fullness(-amount, minimumNeedAfterDialog)

func _on_DialogManager_reduce_fun(amount):
	change_fun(-amount, minimumNeedAfterDialog)

func _on_DialogManager_reduce_happiness(amount):
	change_happiness(-amount, minimumNeedAfterDialog)

func _on_DialogManager_reduce_everything(amount):
	change_all_needs(-amount, minimumNeedAfterDialog)

func _on_TamagotchiTextBox_start_talking():
	emit_signal("start_talking")

func _on_TamagotchiTextBox_end_talking():
	emit_signal("end_talking")

func _on_DialogManager_turn_tamagotchi_off():
	switch_to_off()

func _on_DialogManager_turn_tamagotchi_on():
	switch_to_home()

func _on_Screen_game_over(score):
	restart_minigame()
	update_high_score(score)
	switch_to_game_over(score)

func _on_DialogManager_change_squid_stage(newStageName):
	change_stage_to(stageNameMap[newStageName])
