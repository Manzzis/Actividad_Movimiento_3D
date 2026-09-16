extends Node
class_name MoveComponent

@export var actor: CharacterBody3D

@export_category("Fuerza del Salto")
@export var hop_up := 6.0
@export var hop_forward := 8.0
@export var rotation_speed := 4.0
@export var max_charge := 1.0
@export var gravity_strength := 18.0
@export var ground_check_distance := 0.2

var velocity := Vector3.ZERO
var charge_time := 0.0
var charging := false
var jumped := false

func _ready() -> void:
	if not actor and get_parent() is CharacterBody3D:
		actor = get_parent() as CharacterBody3D
	# Si preferís que el actor procese su propia física, comentá la siguiente línea.
	# actor.set_physics_process(false)

func _physics_process(delta: float) -> void:
	if not actor:
		return

	# ROTACIÓN (solo cuando estamos "grounded")
	if _is_grounded():
		var rot_dir := Input.get_axis("ui_right", "ui_left")
		if rot_dir != 0:
			actor.rotate_y(rot_dir * rotation_speed * delta)
		actor.velocity.x = 0
		actor.velocity.z = 0

	# CARGA: solo se puede iniciar si estamos en suelo y no hemos saltado
	if _is_grounded() and not jumped:
		if Input.is_action_pressed("ui_accept"):
			if not charging:
				charging = true
				charge_time = 0.0
			charge_time = min(charge_time + delta, max_charge)
		if Input.is_action_just_released("ui_accept") and charging:
			_perform_jump()
	else:
		# Si estamos en el aire y se intentó cargar, cancelamos la carga
		if charging:
			charging = false
	

	# INTEGRACIÓN MANUAL DE GRAVEDAD (si no estamos en suelo)
	if not _is_grounded():
		velocity.y -= gravity_strength * delta

	# MOVIMIENTO MANUAL con detección de colisión
	var motion := velocity * delta
	var collision = actor.move_and_collide(motion)
	if collision:
		var n := collision.get_normal()
		if n.dot(Vector3.UP) > 0.7:
			# Colisionamos con suelo: congelamos velocidad y marcamos aterrizaje
			velocity = Vector3.ZERO
			charging = false
			charge_time = 0.0
			jumped = false
		else:
			# Colisión lateral/techo: anulamos componente en la normal
			velocity = velocity.slide(n)

func _perform_jump() -> void:
	var forward_dir = -actor.transform.basis.z.normalized()
	var multiplier = 1.0 + charge_time
	velocity.y = hop_up * multiplier
	velocity.x = forward_dir.x * hop_forward * multiplier
	velocity.z = forward_dir.z * hop_forward * multiplier
	charging = false
	charge_time = 0.0
	jumped = true

func _is_grounded() -> bool:
	if not actor or not is_inside_tree():
		return false
		
	var space_state = actor.get_world_3d().direct_space_state
	var from = actor.global_transform.origin
	var to = from + Vector3.DOWN * (ground_check_distance + 0.01)
	
	# Creamos la consulta de raycast propia de Godot 4
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [actor.get_rid()] # Excluimos el RID de la rana para que no se choque a sí misma
	
	var result = space_state.intersect_ray(query)
	return not result.is_empty()
