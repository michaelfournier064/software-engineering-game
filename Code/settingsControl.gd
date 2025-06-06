# File: res://Code/settingsControl.gd
extends Control

@onready var returnMainMenu : Button            = $backGroundImage/ReturnSaveVBoxContainer/ReturnMainMenuButton
@onready var returnToGame   : Button            = $backGroundImage/ReturnSaveVBoxContainer/ReturnToGameButton
@onready var saveChanges    : Button            = $backGroundImage/ReturnSaveVBoxContainer/SaveChangesButton
@onready var click_sound    : AudioStreamPlayer = $backGroundImage/clickSound
@onready var master_slider  : HSlider           = $backGroundImage/MainVBox/AudioVBox/MasterVolumeContainer/MasterVolumeSlider

signal settings_closed

func _ready() -> void:
	# load and apply saved settings
	SettingsLoaderSingleton.load_settings()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# configure volume slider
	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	master_slider.step      = 0.01
	_sync_gui_to_current_settings()
	
	# connect signals
	master_slider.value_changed.connect(Callable(self, "_on_master_slider_value_changed"))
	returnMainMenu.pressed.connect(Callable(self, "_on_return_main_menu_button_pressed"))
	returnToGame.pressed.connect(Callable(self, "_on_return_to_game_button_pressed"))
	saveChanges.pressed.connect(Callable(self, "_on_save_changes_pressed"))
	
	returnToGame.visible = get_tree().paused

func _sync_gui_to_current_settings() -> void:
	# initialize slider from master bus
	var db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	master_slider.value = db_to_linear(db)

func _on_master_slider_value_changed(value: float) -> void:
	# update master volume immediately
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(value)
	)

func _on_return_main_menu_button_pressed() -> void:
	click_sound.play()
	SettingsLoaderSingleton.save_settings()
	get_tree().paused = false
	emit_signal("settings_closed")
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_return_to_game_button_pressed() -> void:
	click_sound.play()
	SettingsLoaderSingleton.save_settings()
	get_tree().paused = false
	emit_signal("settings_closed")
	# parent frees this node, so no queue_free() here

func _on_save_changes_pressed() -> void:
	click_sound.play()
	SettingsLoaderSingleton.save_settings()
