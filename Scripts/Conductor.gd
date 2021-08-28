extends AudioStreamPlayer

var bpm
var measures

# Tracking the beat and song position
var song_position = 0.0
var song_position_in_beats = 0
var sec_per_beat
var last_reported_beat = 0
var beats_before_start = 0
var measure = 1

# Determining how close to the beat an event is
var closest = 0
var time_off_beat = 0.0
var initial_beat

signal beat(position_beats, position_measure)

func initialize(song):
	bpm = song.bpm
	measures = song.measures
	sec_per_beat = 60.0 / bpm
	
	stream = load(song.stream_path)
	
	song_position = 0.0
	song_position_in_beats = 0
	last_reported_beat = 0
	beats_before_start = 0
	measure = 1

	closest = 0
	time_off_beat = 0.0

func _physics_process(_delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
		_report_beat()

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if measure > measures:
			measure = 1
		emit_signal("beat", song_position_in_beats, measure)
		last_reported_beat = song_position_in_beats
		measure += 1

func play_with_beat_offset(num):
	beats_before_start = num
	$StartTimer.wait_time = sec_per_beat
	$StartTimer.start()

func closest_beat(nth):
	closest = int(round((song_position / sec_per_beat) / nth) * nth) 
	time_off_beat = abs(closest * sec_per_beat - song_position)
	return Vector2(closest, time_off_beat)

func play_from_beat(beat, offset):
	var start_timer = $StartTimer
	
	measure = beat % measures	
		
	get_parent().get_node("NoteScroller").set_offset(beat)
	
	if beat > 0:
		initial_beat = beat
		
	beats_before_start = offset
	
	if offset > 0 && beat == 0:
		start_timer.wait_time = sec_per_beat * offset
		start_timer.start()
	else:
		start()

func start():
	play()
	
	if initial_beat:
		seek((initial_beat - beats_before_start) * sec_per_beat)

	_report_beat()

func stop_song():
	stop()

func _on_StartTimer_timeout():
	start()
	
#	song_position_in_beats += 1
#	if song_position_in_beats < beats_before_start - 1:
#		$StartTimer.start()
#	elif song_position_in_beats == beats_before_start - 1:
#		$StartTimer.wait_time = $StartTimer.wait_time - (AudioServer.get_time_to_next_mix() +
#														AudioServer.get_output_latency())
#		$StartTimer.start()
#	else:
#		play()
#		$StartTimer.stop()
#	_report_beat()
