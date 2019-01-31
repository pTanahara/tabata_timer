import 'dart:async';

import 'package:audioplayers/audio_cache.dart';

var player = new AudioCache();

var defaultTabata = new Tabata(
    sets: 5,
    reps: 5,
    workTime: new Duration(seconds: 20),
    restTime: new Duration(seconds: 10),
    breakTime: new Duration(seconds: 60));

var quickTabata = new Tabata(
    sets: 2,
    reps: 2,
    workTime: new Duration(seconds: 2),
    restTime: new Duration(seconds: 2),
    breakTime: new Duration(seconds: 2));

void main() {
  var workout = new Workout(quickTabata, (Workout workout) {
    print(
        "Round ${workout.set} / Rep ${workout.rep} / ${workout.timeLeft} / ${workout.step}");
  });

  workout.start();
}

class Tabata {
  /// Sets in a workout
  int sets;

  /// Reps in a set
  int reps;

  /// Time to work for in a rep
  Duration workTime;

  /// Rest time between reps
  Duration restTime;

  /// Break time between sets
  Duration breakTime;

  Tabata({this.sets, this.reps, this.workTime, this.restTime, this.breakTime});

  Duration getTotalTime() {
    return (workTime * sets * reps) +
        (restTime * sets * (reps - 1)) +
        (breakTime * (sets - 1));
  }
}

enum WorkoutState { initial, working, resting, breaking, finished }

class Workout {
  Tabata _config;

  Function _callback;

  WorkoutState _step = WorkoutState.initial;

  Timer _timer;

  /// Time left in the current step
  Duration _timeLeft;

  Duration _totalTime = new Duration(seconds: 0);

  /// Current set
  int _set = 1;

  /// Current rep
  int _rep = 1;

  Workout(this._config, this._callback);

  start() {
    _step = WorkoutState.working;
    _timeLeft = _config.workTime;
    _timer = new Timer.periodic(new Duration(seconds: 1), this.tick);
  }

  tick(Timer timer) {
    if (_timeLeft == new Duration(seconds: 1)) {
      nextStep();
    } else {
      _timeLeft -= new Duration(seconds: 1);
      if (_timeLeft.inSeconds <= 3 && _timeLeft.inSeconds >= 1) {
        player.play('pip.mp3');
      }
    }

    _totalTime += new Duration(seconds: 1);

    _callback(this);
  }

  nextStep() {
    var sound = 'boop.mp3';

    if (_step == WorkoutState.working) {
      if (rep == _config.reps) {
        if (set == _config.sets) {
          stop();
          _step = WorkoutState.finished;
          _timeLeft = new Duration(seconds: 0);
          return;
        } else {
          _step = WorkoutState.breaking;
          _timeLeft = _config.breakTime;
          sound = 'dingdingding.mp3';
        }
      } else {
        _step = WorkoutState.resting;
        _timeLeft = _config.restTime;
      }
    } else if (_step == WorkoutState.resting) {
      _rep++;
      _step = WorkoutState.working;
      _timeLeft = _config.workTime;
    } else if (_step == WorkoutState.breaking) {
      _set++;
      _rep = 1;
      _step = WorkoutState.working;
      _timeLeft = _config.workTime;
    }

    player.play(sound);
  }

  stop() {
    _timer.cancel();
  }

  get set => _set;

  get rep => _rep;

  get step => _step;

  get timeLeft => _timeLeft;

  get totalTime => _totalTime;
}
