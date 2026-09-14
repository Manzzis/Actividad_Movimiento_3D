extends Node
class_name MoveComponent

@export var actor: CharacterBody3D

@export_category("Fuerzas Mínimas (Toque rápido)")
@export var min_hop_up := 6.0
@export var min_hop_forward := 8.0

@export_category("Fuerzas Máximas (Carga 100%)")
@export var max_hop_up := 15.0
@export var max_hop_forward := 25.0

@export_category("Ajustes de Carga y Giro")
@export var max_charge_time := 1.2
@export var rotation_speed := 3.0

var gravity: float = 8.0

var current_charge := 0.0
var is_charging := false
var jump_cooldown := 0.0 # Temporizador de bloqueo entre saltos

func _ready() -> void:
	if not actor and get_parent() is CharacterBody3D:
		actor = get_parent() as CharacterBody3D

func _physics_process(delta: float) -> void:
	if not actor:
		return

	# Reducir el tiempo de enfriamiento si está activo
	if jump_cooldown > 0.0:
		jump_cooldown -= delta

	# 1. Gravedad y limpieza en el aire
	if not actor.is_on_floor():
		actor.velocity.y -= gravity * delta
		is_charging = false
		current_charge = 0.0
	else:
		# Frenar deslizamiento horizontal en piso
		actor.velocity.x = move_toward(actor.velocity.x, 0.0, 15.0 * delta)
		actor.velocity.z = move_toward(actor.velocity.z, 0.0, 15.0 * delta)

		# 2. Rotación en tierra
		var rot_dir := 0.0
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			rot_dir += 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			rot_dir -= 1.0

		actor.rotate_y(rot_dir * rotation_speed * delta)

		# 3. Lógica de Carga y Salto (solo si finalizó el cooldown)
		if jump_cooldown <= 0.0:
			if Input.is_key_pressed(KEY_SPACE):
				is_charging = true
				current_charge += delta / max_charge_time
				current_charge = clamp(current_charge, 0.0, 1.0)
			elif is_charging:
				_execute_charged_hop()

	actor.move_and_slide()

func _execute_charged_hop() -> void:
	var forward_dir = -actor.transform.basis.z.normalized()
	
	var actual_up = lerp(min_hop_up, max_hop_up, current_charge)
	var actual_forward = lerp(min_hop_forward, max_hop_forward, current_charge)
	
	actor.velocity.y = actual_up
	actor.velocity.x = forward_dir.x * actual_forward
	actor.velocity.z = forward_dir.z * actual_forward
	
	# Reiniciar carga y activar cooldown para bloquear saltos fantasma
	is_charging = false
	current_charge = 0.0
	jump_cooldown = 0.25
