extends Node2D

var audio_stream_players = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func mute_ambience():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), -70)
	
func unmute_ambience():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), 0)
	
func clear():
	for audio_stream_player in get_children():
		var seq := TweenSequence.new(get_tree())
		seq.append(audio_stream_player, "volume_db", -40, 2).from_current()
		yield(seq, "finished")
		audio_stream_player.stop()
		
func play(name, volume_db = 0, pitch_scale = 1, fade_in_time = 0):
	var audio_stream_player
	if len(audio_stream_players) == 0:
		audio_stream_player = AudioStreamPlayer.new()
		audio_stream_player.bus = "SFX"
		add_child(audio_stream_player)
	else:
		audio_stream_player = audio_stream_players.pop_front()
	 
	audio_stream_player.volume_db = volume_db if fade_in_time == 0 else -40
	var stream = load("res://sfx/"+name+".wav")
	audio_stream_player.stream = stream
	audio_stream_player.pitch_scale = pitch_scale
	audio_stream_player.play()
	if fade_in_time > 0:
		var seq := TweenSequence.new(get_tree())
		seq.append(audio_stream_player, "volume_db", volume_db, fade_in_time).set_trans(2).set_ease(Tween.EASE_OUT).from_current()
		yield(seq, "finished")
		
	#if stream.loop_mode == AudioStream.LOOP_DISABLED:
	yield(audio_stream_player, "finished")
	audio_stream_players.append(audio_stream_player)
