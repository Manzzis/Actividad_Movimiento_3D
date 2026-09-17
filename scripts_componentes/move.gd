class_name MoveComponent extends Node

@export var actor: CharacterBody3D
@export var velocidad: float = 8.0
@export var velocidad_rotacion: float = 3.0
@export var fuerza_salto: float = 10.0
@export var max_saltos: int = 2

var saltos_restantes: int = 0
var gravedad: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if not actor and get_parent() is CharacterBody3D:
		actor = get_parent() as CharacterBody3D
	
	saltos_restantes = max_saltos

func _physics_process(delta: float) -> void:
	if not actor:
		return
	
	
	if actor.is_on_floor():
		saltos_restantes = max_saltos
	else:
		actor.velocity.y -= gravedad * delta
	
	if Input.is_action_just_pressed("ui_accept") and saltos_restantes > 0:
		actor.velocity.y = fuerza_salto
		saltos_restantes -= 1

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")


	if input_dir.x != 0:
		actor.rotate_y(-input_dir.x * velocidad_rotacion * delta)

	# MOVIMIENTO ADELANTE / ATRÁS
	# En Godot 3D, el frente local del personaje es -transform.basis.z
	if input_dir.y != 0:
		var direccion_frente := -actor.transform.basis.z
		var movimiento := direccion_frente * (-input_dir.y) * velocidad
		actor.velocity.x = movimiento.x
		actor.velocity.z = movimiento.z
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0, velocidad)
		actor.velocity.z = move_toward(actor.velocity.z, 0, velocidad)

	# 6. Aplicar físicas
	actor.move_and_slide()
