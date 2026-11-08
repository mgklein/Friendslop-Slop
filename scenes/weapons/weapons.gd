class_name Weapons extends Resource

@export var name: StringName
@export_category("Weapon Orientation")
@export var position: Vector3
@export var rotation: Vector3
@export_category("Visual Settings")
@export var mesh: PackedScene
@export_category("Shootable Settings")
@export var shootable: bool
@export var max_ammo: int
@export var is_hitscan: bool
@export var range: float
@export_category("Projectile Settings")
@export var projectile_speed: int
@export var projectile_scene: PackedScene
