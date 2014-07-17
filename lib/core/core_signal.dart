part of Phaser;

class Signal {
  List<SignalBinding> _bindings = new List<SignalBinding>();
  var _prevParams = null;
  Signal self;

  bool memorize = false;
  bool _shouldPropagate = true;
  bool active = true;


  Signal() {
    self = this;

  }

//  dispatch() {
//    Signal.prototype.dispatch.apply(self, arguments);
//  }

  validateListener(Function listener, String fnName) {
    if (!(listener is Function)) {
      throw new Exception('listener is a required param of {fn}() and should be a Function.'.replaceFirst('{fn}', fnName));
    }
  }

  _registerListener(Function listener, bool isOnce, Object listenerContext, [int priority]) {

    var prevIndex = this._indexOfListener(listener, listenerContext),
    binding;

    if (prevIndex != -1) {
      binding = this._bindings[prevIndex];
      if (binding.isOnce() != isOnce) {
        throw new Exception('You cannot add${(isOnce ? '' : 'Once')}() then add${(!isOnce ? '' : 'Once')}() the same listener without removing the relationship first.');
      }
    } else {
      binding = new SignalBinding(this, listener, isOnce, listenerContext, priority);
      this._addBinding(binding);
    }

    if (this.memorize && this._prevParams) {
      binding.execute(this._prevParams);
    }

    return binding;
  }

  _addBinding(SignalBinding binding) {
    //simplified insertion sort
    var n = this._bindings.length;
    do {
      --n;
    } while (this._bindings[n] && binding._priority <= this._bindings[n]._priority);
    this._bindings.insert(n + 1, binding);
  }


  _indexOfListener(Function listener, context) {
    int n = this._bindings.length;
    SignalBinding cur;
    while (n-- != 0) {
      cur = this._bindings[n];
      if (cur._listener == listener && cur.context == context) {
        return n;
      }
    }
    return -1;
  }


  has(Function listener, context) {
    return this._indexOfListener(listener, context) != -1;
  }


  add(Function listener, listenerContext, [int priority]) {
    this.validateListener(listener, 'add');
    return this._registerListener(listener, false, listenerContext, priority);
  }


  addOnce(Function listener, listenerContext, [int priority]) {
    this.validateListener(listener, 'addOnce');
    return this._registerListener(listener, true, listenerContext, priority);
  }


  remove(Function listener, context) {

    this.validateListener(listener, 'remove');

    var i = this._indexOfListener(listener, context);

    if (i != -1) {
      this._bindings[i]._destroy(); //no reason to a Phaser.SignalBinding exist if it isn't attached to a signal
      this._bindings.removeAt(i);
    }
    return listener;
  }


  removeAll() {
    int n = this._bindings.length;
    while (n-- != 0) {
      this._bindings[n]._destroy();
    }
    this._bindings.length = 0;
  }


  getNumListeners() {
    return this._bindings.length;
  }


  halt() {
    this._shouldPropagate = false;
  }


  dispatch(List arguments) {

    if (!this.active) {
      return;
    }

    List paramsArr = new List.from(arguments);
    int n = this._bindings.length;
    List<SignalBinding> bindings;

    if (this.memorize) {
      this._prevParams = paramsArr;
    }

    if (n == 0) {
      //  Should come after memorize
      return;
    }

    bindings = new List.from(this._bindings); //clone array in case add/remove items during dispatch
    this._shouldPropagate = true; //in case `halt` was called before dispatch or during the previous dispatch.

    //execute all callbacks until end of the list or until a callback returns `false` or stops propagation
    //reverse loop since listeners with higher priority will be added at the end of the list
    do {
      n--;
    } while (bindings[n] != null && this._shouldPropagate && bindings[n].execute(paramsArr) != false);

  }


  forget() {
    this._prevParams = null;
  }


  dispose() {
    this.removeAll();
    this._bindings = null;
    this._prevParams = null;
  }


  toString() {
    return '[Phaser.Signal active:' + this.active + ' numListeners:' + this.getNumListeners() + ']';
  }
}