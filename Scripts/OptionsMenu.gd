extends Control

var musicBus: int = AudioServer.get_bus_index("Music")
var SFXBus: int = AudioServer.get_bus_index("SFX")
onready var musicSlider: HSlider = $Margin/VBox/Sliders/MusicContainer/MusicSlider
onready var musicButton: TextureButton = $Margin/VBox/Sliders/MusicContainer/MusicButton
onready var SFXSlider: HSlider = $Margin/VBox/Sliders/SFXContainer/SFXSlider
onready var SFXButton: TextureButton = $Margin/VBox/Sliders/SFXContainer/SFXButton


func _ready():
	var isMusicMuted: bool = AudioServer.is_bus_mute(musicBus)
	var isSFXMuted: bool = AudioServer.is_bus_mute(SFXBus)	
	musicSlider.value = AudioServer.get_bus_volume_db(musicBus)
	SFXSlider.value = AudioServer.get_bus_volume_db(SFXBus)
	setMute(isMusicMuted, "Music")
	setMute(isSFXMuted, "SFX")
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

func _on_Button_pressed(busName: String):
	setMute(!AudioServer.is_bus_mute(AudioServer.get_bus_index(busName)), busName)	
	pass
	

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")
	pass
