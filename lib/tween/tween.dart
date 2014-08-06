part of Phaser;

class Linears {
  tween.TweenEquation get None => tween.Linear.INOUT;
}

class Quads {
  tween.TweenEquation get In => tween.Quad.IN;

  tween.TweenEquation get InOut => tween.Quad.INOUT;

  tween.TweenEquation get Out => tween.Quad.OUT;
}

class Cubics {
  tween.TweenEquation get In => tween.Quad.IN;

  tween.TweenEquation get InOut => tween.Quad.INOUT;

  tween.TweenEquation get Out => tween.Quad.OUT;
}

class Quarts {
  tween.TweenEquation get In => tween.Quart.IN;

  tween.TweenEquation get InOut => tween.Quart.INOUT;

  tween.TweenEquation get Out => tween.Quart.OUT;
}

class Circs {
  tween.TweenEquation get In => tween.Circ.IN;

  tween.TweenEquation get InOut => tween.Circ.INOUT;

  tween.TweenEquation get Out => tween.Circ.OUT;
}

class Sines {
  tween.TweenEquation get In => tween.Sine.IN;

  tween.TweenEquation get InOut => tween.Sine.INOUT;

  tween.TweenEquation get Out => tween.Sine.OUT;
}

class Expos {
  tween.TweenEquation get In => tween.Expo.IN;

  tween.TweenEquation get InOut => tween.Expo.INOUT;

  tween.TweenEquation get Out => tween.Expo.OUT;
}

class Backs {
  tween.TweenEquation get In => tween.Back.IN;

  tween.TweenEquation get InOut => tween.Back.INOUT;

  tween.TweenEquation get Out => tween.Back.OUT;
}

class Bounces {
  tween.TweenEquation get In => tween.Bounce.IN;

  tween.TweenEquation get InOut => tween.Bounce.INOUT;

  tween.TweenEquation get Out => tween.Bounce.OUT;
}

class Elastics {
  tween.TweenEquation get In => tween.Elastic.IN;

  tween.TweenEquation get InOut => tween.Elastic.INOUT;

  tween.TweenEquation get Out => tween.Elastic.OUT;
}

class Quints {
  tween.TweenEquation get In => tween.Quint.IN;

  tween.TweenEquation get InOut => tween.Quint.INOUT;

  tween.TweenEquation get Out => tween.Quint.OUT;
}



class Easing {
  static final Linears Linear = new Linears();
  static final Quads Quadratic = new Quads();
  static final Cubics Cubic = new Cubics();
  static final Quarts Quartic = new Quarts();
  static final Circs Circ = new Circs();
  static final Quints Quintic = new Quints();
  static final Sines Sinusoidal = new Sines();
  static final Expos Exponential = new Expos();
  static final Backs Back = new Backs();
  static final Bounces Bounce = new Bounces();
  static final Elastics Elastic = new Elastics();
}

//class TweenEvents{
//  static const int BEGIN = 0x01;
//  static const int START = 0x02;
//  static const int END = 0x04;
//  static const int COMPLETE = 0x08;
//  static const int BACK_BEGIN = 0x10;
//  static const int BACK_START = 0x20;
//  static const int BACK_END = 0x40;
//  static const int BACK_COMPLETE = 0x80;
//  static const int ANY_FORWARD = 0x0F;
//  static const int ANY_BACKWARD = 0xF0;
//  static const int ANY = 0xFF;
//}

class Tween {
  static const int INFINITY = tween.Tween.INFINITY;

  static const int BEGIN = 0x01;
  static const int START = 0x02;
  static const int END = 0x04;
  static const int COMPLETE = 0x08;
  static const int BACK_BEGIN = 0x10;
  static const int BACK_START = 0x20;
  static const int BACK_END = 0x40;
  static const int BACK_COMPLETE = 0x80;
  static const int ANY_FORWARD = 0x0F;
  static const int ANY_BACKWARD = 0xF0;
  static const int ANY = 0xFF;

//  Map<String, int> _StoN = {
//    'x': 0,
//    'y':
//    'v': 0,
//  };

  final Game _game;
  final dynamic _gameObject;

  tween.TweenManager _tweenManager;
  tween.Timeline _timeline;
  double _startTime = 0.0;
  double get startTime => _startTime;

  Map<String, num> _initVal;
  //List<num> _vals = new List<num>(1);

  Tween(this._game, this._gameObject) {
    this._tweenManager = _game.tweens;
    this._timeline = tween.Timeline.createSequence();
  }

  Tween to(Map<String, num> properties, [num duration = 1000, tween.TweenEquation ease = null, bool autoStart = false, num delay = 0, int repeat = 0, bool yoyo = false]) {
    _initVal = getCurrentState(properties.keys);
    return _setTween(properties, tween.Tween.to, duration, ease, autoStart, delay, repeat, yoyo);
  }

  Tween from(Map<String, num> properties, [num duration = 1000, tween.TweenEquation ease = null, bool autoStart = false, num delay = 0, int repeat = 0, bool yoyo = false]) {
    _initVal = properties;
    return _setTween(properties, tween.Tween.from, duration, ease, autoStart, delay, repeat, yoyo);
  }

  Map<String, num> getCurrentState(Iterable<String> props) {
    Map<String, num> result = new Map<String, num>();
    for (var key in props) {
      //this._gameObject.getTweenableValues(key, _vals);
      result[key] = tween.Tween.getRegisteredAccessor().getValue(this._gameObject,key);
    }
    return result;
  }

//  Tween set(Map<int, num> properties, [num duration=1000, tween.TweenEquation ease=null, bool autoStart=false, double delay=0.0, int repeat=0, bool yoyo=false]) {
//    return _setTween(properties, tween.Tween.set, duration, ease, autoStart, delay, repeat, yoyo);
//  }



  Tween _setTween(Map<String, num> properties, Function operation, [num duration = 1000, tween.TweenEquation ease = null, bool autoStart = false, num delay = 0.0, int repeat = 0, bool yoyo = false]) {
    tween.Timeline tweens = tween.Timeline.createParallel();

    for (String prop in properties.keys) {
      tween.Tween t = operation(_gameObject, prop, duration * 0.001);
      if (ease != null) {
        t.easing = ease;
      }

      t.targetValue = properties[prop];

      tweens.push(t);
    }
    tweens.delay = delay * 0.001;

    if (repeat != Tween.INFINITY) {
      if (yoyo == true) {
        tweens.repeatYoyo(repeat, 0);
      } else {
        tweens.repeat(repeat, 0);
      }
    }

    if (autoStart == true) {
      tweens.start(this._tweenManager);
    }

    _timeline.push(tweens);

    if (repeat == Tween.INFINITY) {
      if (yoyo == true) {
        _timeline.repeatYoyo(repeat, 0);
      } else {
        _timeline.repeat(repeat, 0);
      }
    }


    return this;
  }

  Tween setCallback(tween.CallbackHandler func, [int event]) {
    this._timeline.setCallback(new tween.TweenCallback()..onEvent = func);
    if (event != null) {
      this._timeline.setCallbackTriggers(event);
    }
    return this;
  }

  Tween setCallbackEvent(int event) {
    this._timeline.setCallbackTriggers(event);
    return this;
  }

  Tween delay(num amount) {
    this._timeline.pushPause(amount * 0.001);
    return this;
  }

  Tween pause() {
    this._timeline.pause();
    return this;
  }

  Tween resume() {
    this._timeline.resume();
    return this;
  }

  Tween reset() {
    this._timeline.reset();
    return this;
  }

  Tween repeat([int count = 1, num delayBetweenLoop = 0]) {
    if (_yoyo == false) {
      _timeline.repeat(count, delayBetweenLoop * 0.001);
    } else {
      _timeline.repeatYoyo(count, delayBetweenLoop * 0.001);
    }
    return this;
  }

  Tween yoyo([bool yoyo = true]) {
    _yoyo = yoyo;
    return this;
  }

  Tween start() {
    _timeline.start(this._tweenManager);
    _startTime = this._game.time.now;

    return this;
  }

  Tween loop([num delayBetweenLoop = 0, bool yoyo]) {
    if (yoyo != null) {
      this._yoyo = yoyo;
    }
    return this.repeat(Tween.INFINITY, delayBetweenLoop);
  }



  List<Map<String, num>> generateData([int frameRate = 60, List<Map<String, num>> data]) {
    double rate = frameRate * 0.001;

    if (this._game == null || this._gameObject == null) {
      return null;
    }

    if (data == null) {
      data = new List<Map<String, num>>();
    }
    this._timeline.start();
    //this._timeline.fullDuration

    while (!this._timeline.isFinished) {
      data.add(getCurrentState(_initVal.keys));
      this._timeline.update(rate);
    }
    data.add(getCurrentState(_initVal.keys));
    return data;
    //this._timeline.getChildren()[0].

    //this._startTime = 0.0;

//    for (String property in this._valuesEnd.keys) {
//      // Check if an Array was provided as property value
//      if (this._valuesEnd[property] is List) {
//        if (this._valuesEnd[property].length == 0) {
//          continue;
//        }
//
//        // create a local copy of the Array with the start value at the front
//        [this._object[property]].addAll(this._valuesEnd[property]);
//      }
//
//      this._valuesStart[property] = this._object[property];
//
//      if (this._valuesStart[property] is! List) {
//        this._valuesStart[property] *= 1.0;
//        // Ensures we're using numbers, not strings
//      }
//
//      this._valuesStartRepeat[property] = this._valuesStart[property];
//    }
//
//    //  Simulate the tween. We will run for frameRate * (this._duration / 1000) (ms)
//    var time = 0;
//    var total = Math.floor(frameRate * (this._timeline.duration / 1000));
//    var tick = this._timeline.duration / total;
//
//    List output = [];
//
//    while (total-- >= 0) {
//      String property;
//
//      double elapsed = (time - this._startTime) / this._duration;
//      elapsed = elapsed > 1 ? 1 : elapsed;
//
//      var value = this._timeline.isReverse(step)//._easingFunction(elapsed);
//      var blob = {};
//
//      for (property in this._valuesEnd) {
//        var start = this._valuesStart[property];
//        var end = this._valuesEnd[property];
//
//        if (end is List) {
//          blob[property] = this._interpolationFunction(end, value);
//        } else {
//          // Parses relative end values with start as base (e.g.: +10, -3)
//          if (end is String) {
//            end = start + double.parse(end);
//          }
//
//          // protect against non numeric properties.
//          if (end is num) {
//            blob[property] = start + (end - start) * value;
//          }
//        }
//      }
//
//      output.add(blob);
//
//      time += tick;
//    }
//
//    if (this._yoyo) {
////      List reversed = output.reversed;
////      reversed.reverse();
//      output.addAll(output.reversed);
//    }
//
//    if (data != null) {
//      data.addAll(output);
//
//      return data;
//    } else {
//      return output;
//    }

  }



  bool _yoyo = false;

  bool get isYoyo => _yoyo;

  bool get isPaused => this._timeline.isPaused;

  bool get isFinished => this._timeline.isFinished;

  bool get isInitialized => this._timeline.isInitialized;

  bool get isKilled => this._timeline.isKilled;

  bool get isStarted => this._timeline.isStarted;


}

//
//typedef double EasingFunction(double k);
//
//class PhaserTween {
//  final dynamic _object;
//  final Game game;
//  TweenManager _manager;
//
//  /**
//   * @property {object} _valuesStart - Private value object.
//   * @private
//   */
//  Map _valuesStart = {
//  };
//
//  /**
//   * @property {object} _valuesEnd - Private value object.
//   * @private
//   */
//  Map _valuesEnd = {
//  };
//
//  /**
//   * @property {object} _valuesStartRepeat - Private value object.
//   * @private
//   */
//  Map _valuesStartRepeat = {
//  };
//
//  /**
//   * @property {number} _duration - Private duration counter.
//   * @private
//   * @default
//   */
//  int _duration = 1000;
//
//  /**
//   * @property {number} _repeat - Private repeat counter.
//   * @private
//   * @default
//   */
//  int _repeat = 0;
//
//  /**
//   * @property {boolean} _yoyo - Private yoyo flag.
//   * @private
//   * @default
//   */
//  bool _yoyo = false;
//
//  /**
//   * @property {boolean} _reversed - Private reversed flag.
//   * @private
//   * @default
//   */
//  bool _reversed = false;
//
//  /**
//   * @property {number} _delayTime - Private delay counter.
//   * @private
//   * @default
//   */
//  double _delayTime = 0.0;
//
//  /**
//   * @property {number} _startTime - Private start time counter.
//   * @private
//   * @default null
//   */
//  double _startTime = null;
//
//  /**
//   * @property {function} _easingFunction - The easing function used for the tween.
//   * @private
//   */
//  EasingFunction _easingFunction = Easing.Linear.None;
//
//  /**
//   * @property {function} _interpolationFunction - The interpolation function used for the tween.
//   * @private
//   */
//  Function _interpolationFunction = Math.linearInterpolation;
//
//  /**
//   * @property {array} _chainedTweens - A private array of chained tweens.
//   * @private
//   */
//  List<Tween> _chainedTweens = [];
//
//  /**
//   * @property {boolean} _onStartCallbackFired - Private flag.
//   * @private
//   * @default
//   */
//  bool _onStartCallbackFired = false;
//
//  /**
//   * @property {function} _onUpdateCallback - An onUpdate callback.
//   * @private
//   * @default null
//   */
//  Function _onUpdateCallback = null;
//
//  /**
//   * @property {object} _onUpdateCallbackContext - The context in which to call the onUpdate callback.
//   * @private
//   * @default null
//   */
//  var _onUpdateCallbackContext = null;
//
//  /**
//   * @property {boolean} _paused - Is this Tween paused or not?
//   * @private
//   * @default
//   */
//  bool _paused = false;
//
//  /**
//   * @property {number} _pausedTime - Private pause timer.
//   * @private
//   * @default
//   */
//  double _pausedTime = 0.0;
//
//  /**
//   * @property {boolean} _codePaused - Was the Tween paused by code or by Game focus loss?
//   * @private
//   */
//  bool _codePaused = false;
//
//  /**
//   * @property {boolean} pendingDelete - If this tween is ready to be deleted by the TweenManager.
//   * @default
//   */
//  bool pendingDelete = false;
//
//  // Set all starting values present on the target object - why? this will copy loads of properties we don't need - commenting out for now
//  // for (var field in object)
//  // {
//  //     this._valuesStart[field] = parseFloat(object[field], 10);
//  // }
//
//  /**
//   * @property {Phaser.Signal} onStart - The onStart event is fired when the Tween begins.
//   */
//  Signal onStart = new Signal();
//
//  /**
//   * @property {Phaser.Signal} onLoop - The onLoop event is fired if the Tween loops.
//   */
//  Signal onLoop = new Signal();
//
//  /**
//   * @property {Phaser.Signal} onComplete - The onComplete event is fired when the Tween completes. Does not fire if the Tween is set to loop.
//   */
//  Signal onComplete = new Signal();
//
//  /**
//   * @property {boolean} isRunning - If the tween is running this is set to true, otherwise false. Tweens that are in a delayed state, waiting to start, are considered as being running.
//   * @default
//   */
//  bool isRunning = false;
//
//  Tween _parent = null;
//
//  Tween _lastChild;
//
//  Tween(this._object, this.game, [this._manager]) {
//
//  }
//
//  Tween to(Map properties, [int duration=1000, EasingFunction ease=null, bool autoStart=false, double delay=0.0, int repeat=0, bool yoyo=false]) {
//    if (yoyo && repeat == 0) {
//      repeat = 1;
//    }
//
//    Tween self;
//
//    if (this._parent != null) {
//      self = this._manager.create(this._object);
//      this._lastChild.chain(self);
//      this._lastChild = self;
//    }
//    else {
//      self = this;
//      this._parent = this;
//      this._lastChild = this;
//    }
//
//    self._repeat = repeat;
//    self._duration = duration;
//    self._valuesEnd = properties;
//
//    if (ease != null) {
//      self._easingFunction = ease;
//    }
//
//    if (delay > 0) {
//      self._delayTime = delay;
//    }
//
//    self._yoyo = yoyo;
//
//    if (autoStart) {
//      return this.start();
//    }
//    else {
//      return this;
//    }
//
//  }
//
//
//  /**
//   * Sets this tween to be a `from` tween on the properties given. A `from` tween starts at the given value and tweens to the current values.
//   * For example a Sprite with an `x` coordinate of 100 could be tweened from `x: 200` by giving a properties object of `{ x: 200 }`.
//   *
//   * @method Phaser.Tween#from
//   * @param {object} properties - Properties you want to tween from.
//   * @param {number} [duration=1000] - Duration of this tween in ms.
//   * @param {function} [ease=null] - Easing function. If not set it will default to Phaser.Easing.Linear.None.
//   * @param {boolean} [autoStart=false] - Whether this tween will start automatically or not.
//   * @param {number} [delay=0] - Delay before this tween will start, defaults to 0 (no delay). Value given is in ms.
//   * @param {number} [repeat=0] - Should the tween automatically restart once complete? If you want it to run forever set as Number.MAX_VALUE. This ignores any chained tweens.
//   * @param {boolean} [yoyo=false] - A tween that yoyos will reverse itself and play backwards automatically. A yoyo'd tween doesn't fire the Tween.onComplete event, so listen for Tween.onLoop instead.
//   * @return {Phaser.Tween} This Tween object.
//   */
//
//  Tween from(Map properties, [int duration=1000, EasingFunction ease=null, bool autoStart=false, double delay=0.0, int repeat=0, bool yoyo=false]) {
//    Map _cache = {
//    };
//
//    for (String prop in properties.keys) {
//      _cache[prop] = this._object[prop];
//      this._object[prop] = properties[prop];
//    }
//
//    return this.to(_cache, duration, ease, autoStart, delay, repeat, yoyo);
//
//  }
//
//
//  /**
//   * Starts the tween running. Can also be called by the autoStart parameter of Tween.to.
//   *
//   * @method Phaser.Tween#start
//   * @return {Phaser.Tween} Itself.
//   */
//
//  start() {
//
//    if (this.game == null || this._object == null) {
//      return null;
//    }
//
//    this._manager.add(this);
//
//    this.isRunning = true;
//
//    this._onStartCallbackFired = false;
//
//    this._startTime = this.game.time.now + this._delayTime;
//
//    for (var property in this._valuesEnd) {
//      // check if an Array was provided as property value
//      if (this._valuesEnd[property] is List) {
//        if (this._valuesEnd[property].length == 0) {
//          continue;
//        }
//
//        // create a local copy of the Array with the start value at the front
//        [this._object[property]].addAll(this._valuesEnd[property]);
//      }
//
//      this._valuesStart[property] = this._object[property];
//
//      if (this._valuesStart[property] is! List) {
//        this._valuesStart[property] *= 1.0;
//        // Ensures we're using numbers, not strings
//      }
//
//      this._valuesStartRepeat[property] = this._valuesStart[property];
//
//    }
//
//    return this;
//
//  }
//
//
//  /**
//   * This will generate an array populated with the tweened object values from start to end.
//   * It works by running the tween simulation at the given frame rate based on the values set-up in Tween.to and similar functions.
//   * It ignores delay and repeat counts and any chained tweens. Just one play through of tween data is returned, including yoyo if set.
//   *
//   * @method Phaser.Tween#generateData
//   * @param {number} [frameRate=60] - The speed in frames per second that the data should be generated at. The higher the value, the larger the array it creates.
//   * @param {array} [data] - If given the generated data will be appended to this array, otherwise a new array will be returned.
//   * @return {array} An array of tweened values.
//   */
//
//  List generateData([int frameRate =60, List data]) {
//
//    if (this.game == null || this._object == null) {
//      return null;
//    }
//
//    this._startTime = 0.0;
//
//    for (String property in this._valuesEnd.keys) {
//      // Check if an Array was provided as property value
//      if (this._valuesEnd[property] is List) {
//        if (this._valuesEnd[property].length == 0) {
//          continue;
//        }
//
//        // create a local copy of the Array with the start value at the front
//        [this._object[property]].addAll(this._valuesEnd[property]);
//      }
//
//      this._valuesStart[property] = this._object[property];
//
//      if (this._valuesStart[property] is! List) {
//        this._valuesStart[property] *= 1.0;
//        // Ensures we're using numbers, not strings
//      }
//
//      this._valuesStartRepeat[property] = this._valuesStart[property];
//    }
//
//    //  Simulate the tween. We will run for frameRate * (this._duration / 1000) (ms)
//    var time = 0;
//    var total = Math.floor(frameRate * (this._duration / 1000));
//    var tick = this._duration / total;
//
//    List output = [];
//
//    while (total-- >= 0) {
//      String property;
//
//      double elapsed = (time - this._startTime) / this._duration;
//      elapsed = elapsed > 1 ? 1 : elapsed;
//
//      var value = this._easingFunction(elapsed);
//      var blob = {
//      };
//
//      for (property in this._valuesEnd) {
//        var start = this._valuesStart[property];
//        var end = this._valuesEnd[property];
//
//        if (end is List) {
//          blob[property] = this._interpolationFunction(end, value);
//        }
//        else {
//          // Parses relative end values with start as base (e.g.: +10, -3)
//          if (end is String) {
//            end = start + double.parse(end);
//          }
//
//          // protect against non numeric properties.
//          if (end is num) {
//            blob[property] = start + ( end - start ) * value;
//          }
//        }
//      }
//
//      output.add(blob);
//
//      time += tick;
//    }
//
//    if (this._yoyo) {
////      List reversed = output.reversed;
////      reversed.reverse();
//      output.addAll(output.reversed);
//    }
//
//    if (data != null) {
//      data.addAll(output);
//
//      return data;
//    }
//    else {
//      return output;
//    }
//
//  }
//
//  /**
//   * Stops the tween if running and removes it from the TweenManager. If there are any onComplete callbacks or events they are not dispatched.
//   *
//   * @method Phaser.Tween#stop
//   * @return {Phaser.Tween} Itself.
//   */
//
//  stop() {
//
//    this.isRunning = false;
//
//    this._onUpdateCallback = null;
//
//    this._manager.remove(this);
//
//    return this;
//
//  }
//
//  /**
//   * Sets a delay time before this tween will start.
//   *
//   * @method Phaser.Tween#delay
//   * @param {number} amount - The amount of the delay in ms.
//   * @return {Phaser.Tween} Itself.
//   */
//
//  delay(amount) {
//
//    this._delayTime = amount;
//    return this;
//
//  }
//
//  /**
//   * Sets the number of times this tween will repeat.
//   *
//   * @method Phaser.Tween#repeat
//   * @param {number} times - How many times to repeat.
//   * @return {Phaser.Tween} Itself.
//   */
//
//  repeat(times) {
//
//    this._repeat = times;
//
//    return this;
//
//  }
//
//  /**
//   * A tween that has yoyo set to true will run through from start to finish, then reverse from finish to start.
//   * Used in combination with repeat you can create endless loops.
//   *
//   * @method Phaser.Tween#yoyo
//   * @param {boolean} yoyo - Set to true to yoyo this tween.
//   * @return {Phaser.Tween} Itself.
//   */
//
//  yoyo(yoyo) {
//
//    this._yoyo = yoyo;
//
//    if (yoyo && this._repeat == 0) {
//      this._repeat = 1;
//    }
//
//    return this;
//
//  }
//
//  /**
//   * Set easing function this tween will use, i.e. Phaser.Easing.Linear.None.
//   *
//   * @method Phaser.Tween#easing
//   * @param {function} easing - The easing function this tween will use, i.e. Phaser.Easing.Linear.None.
//   * @return {Phaser.Tween} Itself.
//   */
//
//  easing(easing) {
//
//    this._easingFunction = easing;
//    return this;
//
//  }
//
//  /**
//   * Set interpolation function the tween will use, by default it uses Phaser.Math.linearInterpolation.
//   * Also available: Phaser.Math.bezierInterpolation and Phaser.Math.catmullRomInterpolation.
//   *
//   * @method Phaser.Tween#interpolation
//   * @param {function} interpolation - The interpolation function to use (Phaser.Math.linearInterpolation by default)
//   * @return {Phaser.Tween} Itself.
//   */
//
//  interpolation(interpolation) {
//
//    this._interpolationFunction = interpolation;
//    return this;
//
//  }
//
//  /**
//   * You can chain tweens together by passing a reference to the chain function. This enables one tween to call another on completion.
//   * You can pass as many tweens as you like to this function, they will each be chained in sequence.
//   *
//   * @method Phaser.Tween#chain
//   * @return {Phaser.Tween} Itself.
//   */
//
//  Tween chainTweens(List<Tween> tweens) {
//    this._chainedTweens = tweens;
//    return this;
//  }
//
//  Tween chain(Tween tween) {
//    this._chainedTweens = [tween];
//    return this;
//  }
//
//  /**
//   * Loop a chain of tweens
//   *
//   * Usage:
//   * game.add.tween(p).to({ x: 700 }, 1000, Phaser.Easing.Linear.None, true)
//   * .to({ y: 300 }, 1000, Phaser.Easing.Linear.None)
//   * .to({ x: 0 }, 1000, Phaser.Easing.Linear.None)
//   * .to({ y: 0 }, 1000, Phaser.Easing.Linear.None)
//   * .loop();
//   * @method Phaser.Tween#loop
//   * @return {Phaser.Tween} Itself.
//   */
//
//  loop() {
//
//    this._lastChild.chain(this);
//    return this;
//
//  }
//
//  /**
//   * Sets a callback to be fired each time this tween updates.
//   *
//   * @method Phaser.Tween#onUpdateCallback
//   * @param {function} callback - The callback to invoke each time this tween is updated.
//   * @param {object} callbackContext - The context in which to call the onUpdate callback.
//   * @return {Phaser.Tween} Itself.
//   */
//
//  onUpdateCallback(callback, callbackContext) {
//
//    this._onUpdateCallback = callback;
//    this._onUpdateCallbackContext = callbackContext;
//
//    return this;
//
//  }
//
//  /**
//   * Pauses the tween.
//   *
//   * @method Phaser.Tween#pause
//   */
//
//  pause() {
//
//    this._codePaused = true;
//    this._paused = true;
//    this._pausedTime = this.game.time.now;
//
//  }
//
//  /**
//   * This is called by the core Game loop. Do not call it directly, instead use Tween.pause.
//   * @method Phaser.Tween#_pause
//   * @private
//   */
//
//  _pause() {
//
//    if (!this._codePaused) {
//      this._paused = true;
//      this._pausedTime = this.game.time.now;
//    }
//
//  }
//
//  /**
//   * Resumes a paused tween.
//   *
//   * @method Phaser.Tween#resume
//   */
//
//  resume() {
//    if (this._paused) {
//      this._paused = false;
//      this._codePaused = false;
//      this._startTime += (this.game.time.now - this._pausedTime);
//    }
//  }
//
//  /**
//   * This is called by the core Game loop. Do not call it directly, instead use Tween.pause.
//   * @method Phaser.Tween#_resume
//   * @private
//   */
//
//  _resume() {
//
//    if (this._codePaused) {
//      return;
//    }
//    else {
//      this._startTime += this.game.time.pauseDuration;
//      this._paused = false;
//    }
//
//  }
//
//  /**
//   * Core tween update function called by the TweenManager. Does not need to be invoked directly.
//   *
//   * @method Phaser.Tween#update
//   * @param {number} time - A timestamp passed in by the TweenManager.
//   * @return {boolean} false if the tween has completed and should be deleted from the manager, otherwise true (still active).
//   */
//
//  update(time) {
//
//    if (this.pendingDelete) {
//      return false;
//    }
//
//    if (this._paused || time < this._startTime) {
//      return true;
//    }
//
//    var property;
//
//    if (time < this._startTime) {
//      return true;
//    }
//
//    if (this._onStartCallbackFired == false) {
//      this.onStart.dispatch(this._object);
//      this._onStartCallbackFired = true;
//    }
//
//    double elapsed = (time - this._startTime) / this._duration;
//    elapsed = elapsed > 1 ? 1 : elapsed;
//
//    var value = this._easingFunction(elapsed);
//
//    for (property in this._valuesEnd.keys) {
//      var start = this._valuesStart[property];
//      var end = this._valuesEnd[property];
//
//      if (end is List) {
//        this._object[property] = this._interpolationFunction(end, value);
//      }
//      else {
//        // Parses relative end values with start as base (e.g.: +10, -3)
//        if (end is String) {
//          end = start + double.parse(end);
//        }
//
//        // protect against non numeric properties.
//        if (end is num) {
//          this._object[property] = start + ( end - start ) * value;
//        }
//      }
//    }
//
//    if (this._onUpdateCallback != null) {
//      this._onUpdateCallback.call(this._onUpdateCallbackContext, this, value);
//
//      if (!this.isRunning) {
//        return false;
//      }
//    }
//
//    if (elapsed == 1) {
//      if (this._repeat > 0) {
////        if ((this._repeat >= double.MAX_FINITE.toInt())) {
////          this._repeat--;
////        }
//
//        // reassign starting values, restart by making startTime = now
//        for (property in this._valuesStartRepeat) {
//          if ((this._valuesEnd[property]) is String) {
//            this._valuesStartRepeat[property] = this._valuesStartRepeat[property] + double.parse(this._valuesEnd[property]);
//          }
//
//          if (this._yoyo) {
//            var tmp = this._valuesStartRepeat[property];
//            this._valuesStartRepeat[property] = this._valuesEnd[property];
//            this._valuesEnd[property] = tmp;
//          }
//
//          this._valuesStart[property] = this._valuesStartRepeat[property];
//        }
//
//        if (this._yoyo) {
//          this._reversed = !this._reversed;
//        }
//
//        this._startTime = time + this._delayTime;
//
//        this.onLoop.dispatch(this._object);
//
//        return true;
//      }
//      else {
//        this.isRunning = false;
//        this.onComplete.dispatch(this._object);
//
//        for (var i = 0, numChainedTweens = this._chainedTweens.length; i < numChainedTweens; i ++) {
//          this._chainedTweens[i].start();
//        }
//
//        return false;
//      }
//
//    }
//
//    return true;
//
//  }
//
//}
//
