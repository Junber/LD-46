extends Container

signal game_over(score)

const enemyScenes = [
	preload("res://VPSScenes/Minigame/EnemyFan.tscn"),
	preload("res://VPSScenes/Minigame/EnemyTargeted.tscn"),
	preload("res://VPSScenes/Minigame/EnemySine.tscn"),
	preload("res://VPSScenes/Minigame/EnemySpawning.tscn")
]

const bulletScene = preload("res://VPSScenes/Minigame/Bullet.tscn")

onready var scoreLabel = $ScoreLabel
onready var heartContainer = $HeartContainer
onready var player = $Player 

onready var spawnTimer = $EnemySpawnTimer
onready var difficultyTimer = $DifficultyIncreaseTimer
onready var shootTimer = $PlayerShootTimer

onready var spawnPositionLeft = $EnemySpawnPosition1
onready var spawnPositionRight = $EnemySpawnPosition2

export (int) var minX = 5
export (int) var maxX = 64

var enemySpeed = 2.0
var enemyBulletSpeed = 15.0
var enemyBulletTime = 3.0
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnTimer.set_paused(true)
	difficultyTimer.set_paused(true)


func spawn_enemy():
	var enemy = enemyScenes[randi() % enemyScenes.size()].instance()
	enemy.position = spawnPositionLeft.position.linear_interpolate(spawnPositionRight.position, randf())
	enemy.position.x -= fmod(enemy.position.x, 5.0)
	enemy.position.x = round(enemy.position.x)
	enemy.connect("death", self, "_on_Enemy_death")
	add_child(enemy)
	enemy.set_speed(enemySpeed)
	enemy.set_bullet_time(enemyBulletTime)
	enemy.set_bullet_speed(enemyBulletSpeed)

func increase_score():
	score += 1
	scoreLabel.set_text(String(score))

func move_left():
	player.position.x -= 5
	if player.position.x < minX:
		player.position.x += 5

func move_right():
	player.position.x += 5
	if player.position.x > maxX:
		player.position.x -= 5
	

func shoot():
	if shootTimer.is_stopped():
		shootTimer.start()
		var bullet = bulletScene.instance()
		bullet.position = player.position - Vector2(2, 0)
		add_child(bullet)

func pause():
	spawnTimer.set_paused(true)
	difficultyTimer.set_paused(true)

func unpause():
	spawnTimer.set_paused(false)
	difficultyTimer.set_paused(false)

	
func increase_difficulty():
	difficultyTimer.set_wait_time(difficultyTimer.get_wait_time() + 0.3)
	difficultyTimer.start()
	
	var thingToIncrease = randi() % 4
	if thingToIncrease == 0:
		spawnTimer.stop()
		spawn_enemy()
		spawnTimer.set_wait_time(spawnTimer.get_wait_time() / 1.1)
		spawnTimer.start()
	elif thingToIncrease == 1:
		enemySpeed += 0.5
	elif thingToIncrease == 2:
		enemyBulletSpeed += 2.0
	elif thingToIncrease == 3:
		enemyBulletTime /= 1.5


# warning-ignore:unused_argument
func _on_Player_area_entered(area):
	for heart in heartContainer.get_children():
		if heart.visible:
			heart.visible = false
			break
	
	for heart in heartContainer.get_children():
		if heart.visible:
			return
			
	emit_signal("game_over", score)


func _on_EnemySpawnTimer_timeout():
	spawn_enemy()


func _on_DifficultyIncreaseTimer_timeout():
	increase_difficulty()


func _on_Enemy_death():
	increase_score()
