extends Control

onready var label: RichTextLabel = $Margin/VBox/TextContainer/RichTextLabel
onready var letterTimer: Timer = $LetterTimer
onready var image: TextureRect = $Margin/VBox/ImageContainer/Image
onready var pageTimer: Timer = $PageTimer

const datas = [
	{"sprite": "res://icon.png", "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque aliquam non eros eu bibendum. Nunc id condimentum nulla. Curabitur eu neque eget elit rutrum tempus."},
	{"sprite": "res://icon2.png", "text": "Aenean non ipsum et justo pulvinar blandit. Fusce aliquet velit ut semper luctus. Etiam libero nibh, consequat a ultrices et, bibendum in tortor."}	
]

var page = 0

func _ready():
	changePage(datas[page])
	pass

func _on_LetterTimer_timeout():
	if label.visible_characters <= len(label.text) - 1:
		label.visible_characters += 1
		if label.text[label.visible_characters - 1] in ".,":
			letterTimer.wait_time = 1
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
		get_tree().change_scene("res://Scenes/Menu.tscn")
	pass

func changePage(data):
	image.texture = load(data.sprite)
	label.visible_characters = 0
	label.text = data.text
	letterTimer.wait_time = 0.07
	letterTimer.start()
	pass
