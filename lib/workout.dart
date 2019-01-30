library workout;

import 'dart:async';

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
  final int sets;

  /// Reps in a set
  final int reps;

  /// Time to work for in a rep
  final Duration workTime;

  /// Rest time between reps
  final Duration restTime;

  /// Break time between sets
  final Duration breakTime;

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
      // TODO play countdown pips on 3... 2... 1...
    }

    _totalTime += new Duration(seconds: 1);

    _callback(this);
  }

  nextStep() {
    if (_step == WorkoutState.working) {
      if (rep == _config.reps) {
        if (set == _config.sets) {
          stop();
          _step = WorkoutState.finished;
          _timeLeft = new Duration(seconds: 0);
          // TODO play finished sound
          return;
        } else {
          _step = WorkoutState.breaking;
          _timeLeft = _config.breakTime;
          // TODO play break time sound
        }
      } else {
        _step = WorkoutState.resting;
        _timeLeft = _config.restTime;
        // TODO play rest time sound
      }
    } else if (_step == WorkoutState.resting) {
      _rep++;
      _step = WorkoutState.working;
      _timeLeft = _config.workTime;
      // TODO play start working sound
    } else if (_step == WorkoutState.breaking) {
      _set++;
      _rep = 1;
      _step = WorkoutState.working;
      _timeLeft = _config.workTime;
      // TODO play start working sound
    }
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
