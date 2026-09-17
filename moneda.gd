extends Area3D
class_name Moneda3D


@export var valor_puntos : int = 1

func _ready() -> void:
	pass

func _on_body_entered(body: CharacterBody3D) -> void:
	if body is Jugador:
		# Llama a la función sumar_punto en todos los nodos del grupo "UI"
		get_tree().call_group("UI", "sumar_punto", valor_puntos)
		queue_free() # Destruye la moneda al recolectarla
