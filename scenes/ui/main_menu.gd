extends CanvasLayer

@onready var button_join: Button = %ButtonJoin
@onready var button_quit: Button = %ButtonQuit
@onready var line_edit_session: LineEdit = %LineEditSession
@onready var line_edit_username: LineEdit = %LineEditUsername
@onready var button_join_tube: Button = %ButtonJoinTube
@onready var button_join_tube_2: Button = %ButtonJoinTube2
@onready var button_quit_tube: Button = %ButtonQuitTube
@onready var button_create_tube: Button = %ButtonCreateTube
@onready var button_create_tube_2: Button = %ButtonCreateTube2
@onready var enet_menu: VBoxContainer = %EnetMenu
@onready var tube_menu: VBoxContainer = %TubeMenu

const WORLD_FOREST = "uid://tb21kw5g8pwt"
#const PLAYER = preload("uid://d1w5ccem33kle")
const WORLD_TRACK = "uid://17nxn1glan6p"
const WORLD_PROCEDURAL = "uid://ppc40eff8d81"
const WORLD_LOW_POLY = "uid://dp5xr5kwe7oqq"
const WORLD_LOW_POLY_GUNNAR = "uid://bt4yddrj6enen"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Network.tube_enabled:
		enet_menu.hide()
	else:
		tube_menu.hide()
	
	button_join.pressed.connect(on_join)
	button_quit.pressed.connect(func(): get_tree().quit())
	
	line_edit_session.text_changed.connect(update_session)
	line_edit_username.text_changed.connect(update_username)
	button_join_tube.disabled = true
	button_join_tube.pressed.connect(on_join_tube)
	button_join_tube_2.disabled = true
	button_join_tube_2.pressed.connect(on_join_tube_2)
	button_quit_tube.pressed.connect(func(): get_tree().quit())
	button_create_tube.pressed.connect(on_create_tube)
	button_create_tube_2.pressed.connect(on_create_tube_2)
	
	Network.tube_client.error_raised.connect(on_error_raised)
	
	if OS.has_feature("server"):
		Network.start_server()
		await get_tree().create_timer(0.1).timeout
		add_world()
		hide()

func on_join():
	Network.join_server()
	add_world()


func add_world():
	Global.game_controller.change_level_scene(WORLD_LOW_POLY)
	hide()


func add_world_2():
	Global.game_controller.change_level_scene(WORLD_LOW_POLY_GUNNAR)
	hide()


func on_join_tube():
	Network.tube_join(line_edit_session.text)
	multiplayer.connected_to_server.connect(add_world)


func on_join_tube_2():
	Network.tube_join(line_edit_session.text)
	multiplayer.connected_to_server.connect(add_world_2)


func on_create_tube():
	Network.tube_create()
	add_world()


func on_create_tube_2():
	Network.tube_create()
	add_world_2()

func update_session(new_text: String):
	if new_text != "":
		button_join_tube.disabled = false
		button_join_tube_2.disabled = false


func update_username(new_text: String):
	Global.username = new_text


func on_error_raised(_code, _message):
	line_edit_session.text = ""
	button_join_tube.add_theme_color_override("font_disabled_color", Color.DARK_RED)
	button_join_tube.disabled = true
	Network.clean_up_signals()
