extends Control

onready var label: RichTextLabel = $Margin/VBox/TextContainer/RichTextLabel
onready var letterTimer: Timer = $LetterTimer
onready var image: TextureRect = $Margin/VBox/ImageContainer/Image
onready var pageTimer: Timer = $PageTimer

onready var datas: Array

var page: int = 0
var sceneOnFinish: String = ""

func _ready():
	pass
	
func start(pg):
	changePage(datas[pg])

func _on_LetterTimer_timeout():
	label.visible_characters += 1
	if label.visible_characters <= len(label.text) - 1:
		if label.text[label.visible_characters] == " ":
			letterTimer.wait_time = 0.3
		else:
			letterTimer.wait_time = 0.07
		$KeyboardSound.play(0)
	else:
		letterTimer.stop()
		pageTimer.wait_time = 2
		pageTimer.start()
	pass
	
func _on_PageTimer_timeout():
	page += 1
	if page <= len(datas) - 1:
		changePage(datas[page])
	else:
		if sceneOnFinish != "":
			get_tree().change_scene(sceneOnFinish)
	pass

func changePage(data):
	image.texture = load(data.sprite)
	label.visible_characters = 0
	label.text = data.text
	letterTimer.wait_time = 0.07
	letterTimer.start()
	pass
