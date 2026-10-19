class_name GameController extends Node

@export var level: Node3D
@export var hud: CanvasLayer
@export var menu: Control

@export var transition_controller: SceneTransitionController

var player_controller: PlayerController

var current_level
var current_hud
var current_menu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	current_menu = $Menu/MainMenu


func change_level_scene(
	new_scene: String,
	delete: bool = true,
	keep_running: bool = false,
	transition: bool = false,
	transition_in: String = "Fade In",
	transition_out: String = "Fade Out",
	seconds: float = 1.0
	) -> void:
	
	if transition:
		transition_controller.transition(transition_out, seconds) # Transition out
		await transition_controller.animation_player.animation_finished
	if current_level != null:
		if delete:
			current_level.queue_free() # Removes node entirely
		elif keep_running:
			current_level.visible = false # Keeps in memory and running
		else:
			level.remove_child(current_menu) # Keeps in memory, does not run
	var new = load(new_scene).instantiate()
	menu.add_child(new)
	current_level = new
	if transition:
		transition_controller.transition(transition_in, seconds) # Transition in


func change_hud_scene(
	new_scene: String,
	delete: bool = true,
	keep_running: bool = false,
	transition: bool = false,
	transition_in: String = "Fade In",
	transition_out: String = "Fade Out",
	seconds: float = 1.0
	) -> void:
	
	if transition:
		transition_controller.transition(transition_out, seconds) # Transition out
		await transition_controller.animation_player.animation_finished
	if current_hud != null:
		if delete:
			current_hud.queue_free() # Removes node entirely
		elif keep_running:
			current_hud.visible = false # Keeps in memory and running
		else:
			hud.remove_child(current_menu) # Keeps in memory, does not run
	var new = load(new_scene).instantiate()
	hud.add_child(new)
	current_hud = new
	if transition:
		transition_controller.transition(transition_in, seconds) # Transition in


func change_menu_scene(
	new_scene: String,
	delete: bool = true,
	keep_running: bool = false,
	transition: bool = false,
	transition_in: String = "Fade In",
	transition_out: String = "Fade Out",
	seconds: float = 1.0
	) -> void:
		
	if transition:
		transition_controller.transition(transition_out, seconds) # Transition out
		await transition_controller.animation_player.animation_finished
	if current_menu != null:
		if delete:
			current_menu.queue_free() # Removes node entirely
		elif keep_running:
			current_menu.visible = false # Keeps in memory and running
		else:
			menu.remove_child(current_menu) # Keeps in memory, does not run
	var new = load(new_scene).instantiate()
	menu.add_child(new)
	current_menu = new
	if transition:
		transition_controller.transition(transition_in, seconds) # Transition in
