extends CanvasLayer


var player_controller: PlayerController

@onready var menu: Control = %Menu
@onready var button_leave: Button = %ButtonLeave
@onready var label_session: Label = %LabelSession
@onready var button_copy_session: Button = %ButtonCopySession


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	if not is_multiplayer_authority():
		return # Original tutorial hid menu node here and canvas layer above for some reason

	label_session.text = Network.tube_client.session_id
	button_leave.pressed.connect(func(): Network.leave_server())
	button_copy_session.pressed.connect(func(): DisplayServer.clipboard_set(Network.tube_client.session_id))
