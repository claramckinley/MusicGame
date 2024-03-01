extends Node2D

var score = 0
var combo = 0

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

var bpm = 115

var song_position = 0.0
var song_position_in_beats = 0
var last_spawned_beat = 0
var sec_per_beat = 60.0 / bpm

var spawn_1_beat = 0
var spawn_2_beat = 0
var spawn_3_beat = 1
var spawn_4_beat = 0

var lane = 0
var rand = 0
var note = load("res://Scenes/Note.tscn")
var instance
var http_req


func _ready():
	randomize()
	$Conductor.play_with_beat_offset(8)


func _input(event):
	if event.is_action("escape"):
		if get_tree().change_scene("res://Scenes/Menu.tscn") != OK:
			print ("Error changing scene to Menu")


func _on_Conductor_measure(position):
	if position == 1:
		_spawn_notes(spawn_1_beat)
	elif position == 2:
		_spawn_notes(spawn_2_beat)
	elif position == 3:
		_spawn_notes(spawn_3_beat)
	elif position == 4:
		_spawn_notes(spawn_4_beat)

func _on_Conductor_beat(position):
	song_position_in_beats = position
	if song_position_in_beats > 36:
		spawn_1_beat = 1
		spawn_2_beat = 1
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 98:
		spawn_1_beat = 2
		spawn_2_beat = 0
		spawn_3_beat = 1
		spawn_4_beat = 0
	if song_position_in_beats > 132:
		spawn_1_beat = 0
		spawn_2_beat = 2
		spawn_3_beat = 0
		spawn_4_beat = 2
	if song_position_in_beats > 162:
		spawn_1_beat = 2
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 194:
		spawn_1_beat = 2
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 228:
		spawn_1_beat = 0
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 258:
		spawn_1_beat = 1
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 288:
		spawn_1_beat = 0
		spawn_2_beat = 2
		spawn_3_beat = 0
		spawn_4_beat = 2
	if song_position_in_beats > 322:
		spawn_1_beat = 3
		spawn_2_beat = 2
		spawn_3_beat = 2
		spawn_4_beat = 1
	if song_position_in_beats > 388:
		spawn_1_beat = 1
		spawn_2_beat = 0
		spawn_3_beat = 0
		spawn_4_beat = 0
	if song_position_in_beats > 396:
		spawn_1_beat = 0
		spawn_2_beat = 0
		spawn_3_beat = 0
		spawn_4_beat = 0
	if song_position_in_beats > 404:
		Global.set_score(score)
		Global.combo = max_combo
		Global.great = great
		Global.good = good
		Global.okay = okay
		Global.missed = missed
		if get_tree().change_scene("res://Scenes/End.tscn") != OK:
			print ("Error changing scene to End")



func _spawn_notes(to_spawn):
	if to_spawn > 0:
		lane = randi() % 3
		instance = note.instance()
		instance.initialize(lane)
		add_child(instance)
	if to_spawn > 1:
		while rand == lane:
			rand = randi() % 3
		lane = rand
		instance = note.instance()
		instance.initialize(lane)
		add_child(instance)
		


func increment_score(by):
	if by > 0:
		combo += 1
	else:
		combo = 0
	
	if by == 3:
		great += 1
	elif by == 2:
		good += 1
	elif by == 1:
		okay += 1
	else:
		missed += 1
	
	
	score += by * combo
	$Label.text = str(score)
	if combo > 0:
		$Combo.text = str(combo) + " combo!"
		if combo > max_combo:
			max_combo = combo
	else:
		$Combo.text = ""


func reset_combo():
	combo = 0
	$Combo.text = ""


var clientId = "35eb3120ba3841ddbc1b3cab8c573f80"
var clientSecret = "8288717bc1004029b002cfe9bef7a50c"
var code = null

func _on_Button_pressed():
	if code == null:
		http_req = HTTPRequest.new()
		add_child(http_req)
		http_req.connect("request_completed", self, "_http_request_completed")
#		get_auth()
		get_access_to_account()
	else:
#		search_spotify($TextEdit.text)
		play_spotify($TextEdit.text)
			
func get_auth():
	var Client = HTTPClient.new()
	var url = "https://accounts.spotify.com/api/token"
	var auth = Marshalls.utf8_to_base64(clientId + ":" + clientSecret)
	var headers = [
		"Authorization: Basic " + auth,
		"Content-Type: application/x-www-form-urlencoded"]
	var body = {"grant_type":"client_credentials"}
	http_req.request(url, headers, true, HTTPClient.METHOD_POST, Client.query_string_from_dict(body))
	
func get_access_to_account():
	var Client = HTTPClient.new()
	var url = "https://accounts.spotify.com/authorize?"
	var auth = Marshalls.utf8_to_base64(clientId + ":" + clientSecret)
	var headers = [
		"Authorization: Basic " + auth,
		"Content-Type: application/x-www-form-urlencoded"]
	var body = {
		"client_id":clientId,
		"response_type":"code",
		"redirect_uri":"http://localhost:8060/callback",
		"scope":"user-read-private user-read-email"
	}
	http_req.request(url, headers, true, HTTPClient.METHOD_POST, Client.query_string_from_dict(body))
	
func search_spotify(search_query):
	var Client = HTTPClient.new()
	var url = "https://api.spotify.com/v1/search?" + "q=" + search_query + "&type=track&limit=10"
	var headers = ["Authorization: Bearer " + code]
	print(url)
	http_req.request(url, headers, true, HTTPClient.METHOD_GET)
	
func play_spotify(search_query):
	var Client = HTTPClient.new()
	var url = "https://api.spotify.com/v1/me/player/play"
	var headers = ["Authorization: Bearer " + code]
	print(url)
	var body = {"scope":"user-modify-playback-state user-read-playback-state"}
	http_req.request(url, headers, true, HTTPClient.METHOD_PUT, Client.query_string_from_dict(body))


func _http_request_completed(result, response_code, headers, body):
	print("completed " + str(response_code))
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 200:
			var json_string = body.get_string_from_utf8()
			print(json_string)
			$Label.text = json_string
			var json_result = JSON.parse(json_string)
			var variant = json_result.get_result()
			code = variant.get("access_token")
		else: 
			print("http Error")
#			print(headers)
			print(body.get_string_from_utf8())
			$Label.text = body.get_string_from_utf8()
