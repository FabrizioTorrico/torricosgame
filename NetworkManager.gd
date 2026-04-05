# NetworkManager.gd (Autoload)
extends Node

var local_player_id := 1 # 1 para Host, 2 para Client

# Guardamos las decisiones de ESTE turno aquí hasta que ambas lleguen
var p1_locked_action := ""
var p1_locked_dir    := Vector2.ZERO
var p2_locked_action := ""
var p2_locked_dir    := Vector2.ZERO

var p1_is_ready := false
var p2_is_ready := false

signal both_players_locked

# Esta función la llamará tu UI cuando le des a "Ejecutar"
func lock_in_turn(action: String, dir: Vector2):
	if local_player_id == 1:
		# Soy el Host, me lo guardo localmente y le aviso al otro
		_register_p1_turn(action, dir)
		rpc("_register_p1_turn", action, dir)
	else:
		# Soy el Cliente, me lo guardo localmente y le aviso al Host
		_register_p2_turn(action, dir)
		rpc("_register_p2_turn", action, dir)

# --- LAS FUNCIONES RPC (Remote Procedure Call) ---
# La etiqueta @rpc("any_peer", "call_remote", "reliable") significa:
# "Cualquiera puede llamar esto", "Ejecútalo en la OTRA máquina", "Asegúrate de que llegue".

@rpc("any_peer", "call_remote", "reliable")
func _register_p1_turn(action: String, dir: Vector2):
	p1_locked_action = action
	p1_locked_dir = dir
	p1_is_ready = true
	_check_if_ready_to_simulate()

@rpc("any_peer", "call_remote", "reliable")
func _register_p2_turn(action: String, dir: Vector2):
	p2_locked_action = action
	p2_locked_dir = dir
	p2_is_ready = true
	_check_if_ready_to_simulate()

func _check_if_ready_to_simulate():
	if p1_is_ready and p2_is_ready:
		both_players_locked.emit()
		
func reset_turn():
	p1_is_ready = false
	p2_is_ready = false
