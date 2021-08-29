extends Control

var musicBus: int = AudioServer.get_bus_index("Music")
var SFXBus: int = AudioServer.get_bus_index("SFX")
onready var musicSlider: HSlider = $Margin/VBox/Sliders/MusicContainer/MusicSlider
onready var musicButton: TextureButton = $Margin/VBox/Sliders/MusicContainer/MusicButton
onready var SFXSlider: HSlider = $Margin/VBox/Sliders/SFXContainer/SFXSlider
onready var SFXButton: TextureButton = $Margin/VBox/Sliders/SFXContainer/SFXButton

onready var SFXPlayer: AudioStreamPlayer = $SFXPlayer

onready var backButton: Button = $Margin/VBox/Center/HBox/BackButton
onready var backMenuButton: Button = $Margin/VBox/Center/HBox/BackMenuButton
onready var retryButton: Button = $Margin/VBox/Center/HBox/RetryButton
onready var changeControlsButton: Button = $Margin/VBox/HBox/ChangeControlsButton

func _ready():
	setVisible(false)
	$"/root/MusicPlayer".change_music("res://Sounds/Menu.ogg", -1)
	var isMusicMuted: bool = AudioServer.is_bus_mute(musicBus)
	var isSFXMuted: bool = AudioServer.is_bus_mute(SFXBus)	
	musicSlider.value = AudioServer.get_bus_volume_db(musicBus)
	SFXSlider.value = AudioServer.get_bus_volume_db(SFXBus)
	setMute(isMusicMuted, "Music")
	setMute(isSFXMuted, "SFX")
	
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		setVisible(!visible)
		pass

func _on_Slider_value_changed(value: float, busName: String):
	setVolume(value, busName)
	if value <= -30:
		setMute(true, busName)
	else:
		setMute(false, busName)

func setVolume(value: float, busName: String):
	var busIndex = AudioServer.get_bus_index(busName)
	AudioServer.set_bus_volume_db(busIndex, value)

func setMute(value: bool, busName: String):
	var busIndex = AudioServer.get_bus_index(busName)
	AudioServer.set_bus_mute(busIndex, value)
	var isMuted = AudioServer.is_bus_mute(AudioServer.get_bus_index(busName))
	if busName == "Music":
		if isMuted:
			musicButton.texture_normal = load("res://Sprites/Menu/OptionsMenu/MusicOff.png")
		else:
			musicButton.texture_normal = load("res://Sprites/Menu/OptionsMenu/MusicOn.png")
	elif busName == "SFX":
		if isMuted:
			SFXButton.texture_normal = load("res://Sprites/Menu/OptionsMenu/SfxOff.png")
		else:
			SFXButton.texture_normal = load("res://Sprites/Menu/OptionsMenu/SfxOn.png")

func _on_OptionsButton_pressed(busName: String):
	setMute(!AudioServer.is_bus_mute(AudioServer.get_bus_index(busName)), busName)	
	
func _on_Button_pressed(button: String):
	playSFX("selected")
	OS.delay_msec(175)
	if button == "Back":
		get_tree().change_scene("res://Scenes/Menu.tscn")
	elif button == "ChangeControls":
		$"/root/MenuController".backTo = "Pause"
		get_tree().change_scene("res://Scenes/ModalChangeControls.tscn")
	elif button == "Quit":
		get_tree().change_scene("res://Scenes/Menu.tscn")
	elif button == "Retry":
		get_tree().reload_current_scene()

func _on_Button_mouse_entered(button):
	playSFX("entered")
	if button == "Back":
		backButton.get_font("font").size = 80
	elif button == "ChangeControls":
		changeControlsButton.get_font("font").size = 56
	elif button == "Quit":
		backMenuButton.get_font("font").size = 80
	elif button == "Retry":
		retryButton.get_font("font").size = 80
	
func _on_Button_mouse_exited():
		backButton.get_font("font").size = 64
		backMenuButton.get_font("font").size = 64		
		changeControlsButton.get_font("font").size = 48
		retryButton.get_font("font").size = 64
	
func playSFX(stream: String):
	SFXPlayer.stop()
	if stream == "selected":
		SFXPlayer.set_stream(load("res://Sounds/selected.ogg"))
	elif stream == "entered":
		SFXPlayer.set_stream(load("res://Sounds/mouseEntered.ogg"))
	SFXPlayer.play(0)

func setVisible(state):
	visible = state
	get_tree().paused = state
	
