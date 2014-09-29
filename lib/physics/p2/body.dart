library P2;
//import "dart:html" as dom;
//import "../../phaser.dart";
import "../../phaser.dart" as Phaser;
import "package:p2/p2.dart" as p2;
//part "body.dart";

part "body_debug.dart";
part "collision_group.dart";
part "contact_material.dart";
part "distance_constraint.dart";
part "fixture_list.dart";
part "gear_constraint.dart";
part "inverse_point_proxy.dart";
part "lock_constraint.dart";
part "material.dart";
part "point_proxy.dart";
part "prismatic_constraint.dart";
part "revolute_constraint.dart";
part "rotational_spring.dart";
part "spring.dart";
part "world.dart";

class Body {
  /// Local reference to game.
  Phaser.Game game;
  /// Local reference to the P2 World.
  Phaser.World world;
  /// Reference to the parent Sprite.
  Phaser.Sprite sprite;
  /// The type of physics system this body belongs to.
  int type;
  /// The offset of the Physics Body from the Sprite x/y position.
  Phaser.Point offset;
  /// The p2 Body data.
  p2.Body data;

  InversePointProxy velocity;
  InversePointProxy force;
  Phaser.Point gravity;
  Phaser.Signal onBeginContact;
  Phaser.Signal onEndContact;
  List<Body> collidesWith;
  bool removeNextStep;
  BodyDebug debugBody;

  bool _collideWorldBounds;
  Map _bodyCallbacks;
  Map _groupCallbacks;



  Body(Phaser.Game game, [Phaser.Sprite sprite, num x=0, num y=0, num mass=1]) {

    this.game = game;
    this.world = game.physics.p2;
    this.sprite = sprite;
    this.type = Phaser.Physics.P2JS;
    this.offset = new Phaser.Point();

    /**
     * @property {p2.Body} data -
     * @protected
     */
    this.data = new p2.Body( position: [ this.world.pxmi(x), this.world.pxmi(y) ], mass: mass );

    this.data.parent = this;

    /**
     * @property {Phaser.InversePointProxy} velocity - The velocity of the body. Set velocity.x to a negative value to move to the left, position to the right. velocity.y negative values move up, positive move down.
     */
    this.velocity = new InversePointProxy(this.world, this.data.velocity);

    /**
     * @property {Phaser.InversePointProxy} force - The force applied to the body.
     */
    this.force = new InversePointProxy(this.world, this.data.force);

    /**
     * @property {Phaser.Point} gravity - A locally applied gravity force to the Body. Applied directly before the world step. NOTE: Not currently implemented.
     */
    this.gravity = new Phaser.Point();

    /**
     * Dispatched when a first contact is created between shapes in two bodies. This event is fired during the step, so collision has already taken place.
     * The event will be sent 4 parameters: The body it is in contact with, the shape from this body that caused the contact, the shape from the contact body and the contact equation data array.
     * @property {Phaser.Signal} onBeginContact
     */
    this.onBeginContact = new Phaser.Signal();

    /**
     * Dispatched when contact ends between shapes in two bodies. This event is fired during the step, so collision has already taken place.
     * The event will be sent 3 parameters: The body it is in contact with, the shape from this body that caused the contact and the shape from the contact body.
     * @property {Phaser.Signal} onEndContact
     */
    this.onEndContact = new Phaser.Signal();

    /**
     * @property {array} collidesWith - Array of CollisionGroups that this Bodies shapes collide with.
     */
    this.collidesWith = [];

    /**
     * @property {boolean} removeNextStep - To avoid deleting this body during a physics step, and causing all kinds of problems, set removeNextStep to true to have it removed in the next preUpdate.
     */
    this.removeNextStep = false;

    /**
     * @property {Phaser.Physics.P2.BodyDebug} debugBody - Reference to the debug body.
     */
    this.debugBody = null;

    /**
     * @property {boolean} _collideWorldBounds - Internal var that determines if this Body collides with the world bounds or not.
     * @private
     */
    this._collideWorldBounds = true;

    /**
     * @property {object} _bodyCallbacks - Array of Body callbacks.
     * @private
     */
    this._bodyCallbacks = {};

    /**
     * @property {object} _bodyCallbackContext - Array of Body callback contexts.
     * @private
     */
    //this._bodyCallbackContext = {};

    /**
     * @property {object} _groupCallbacks - Array of Group callbacks.
     * @private
     */
    this._groupCallbacks = {};

    /**
     * @property {object} _bodyCallbackContext - Array of Grouo callback contexts.
     * @private
     */
    //this._groupCallbackContext = {};

    //  Set-up the default shape
    if (sprite != null)
    {
      this.setRectangleFromSprite(sprite);

      if (sprite.exists)
      {
        this.game.physics.p2.addBody(this);
      }
    }

  }
  
  
  addToWorld(){
    
  }

  /**
   * Sets a callback to be fired any time a shape in this Body impacts with a shape in the given Body. The impact test is performed against body.id values.
   * The callback will be sent 4 parameters: This body, the body that impacted, the Shape in this body and the shape in the impacting body.
   * Note that the impact event happens after collision resolution, so it cannot be used to prevent a collision from happening.
   * It also happens mid-step. So do not destroy a Body during this callback, instead set safeDestroy to true so it will be killed on the next preUpdate.
   *
   * @method Phaser.Physics.P2.Body#createBodyCallback
   * @param {Phaser.Sprite|Phaser.TileSprite|Phaser.Physics.P2.Body|p2.Body} object - The object to send impact events for.
   * @param {function} callback - The callback to fire on impact. Set to null to clear a previously set callback.
   * @param {object} callbackContext - The context under which the callback will fire.
   */
  createBodyCallback (object, callback, callbackContext) {

    var id = -1;

    if (object['id'])
    {
      id = object.id;
    }
    else if (object['body'])
    {
      id = object.body.id;
    }

    if (id > -1)
    {
      if (callback == null)
      {
        delete (this._bodyCallbacks[id]);
        delete (this._bodyCallbackContext[id]);
      }
      else
      {
        this._bodyCallbacks[id] = callback;
        this._bodyCallbackContext[id] = callbackContext;
      }
    }

  }

  /**
   * Sets a callback to be fired any time this Body impacts with the given Group. The impact test is performed against shape.collisionGroup values.
   * The callback will be sent 4 parameters: This body, the body that impacted, the Shape in this body and the shape in the impacting body.
   * This callback will only fire if this Body has been assigned a collision group.
   * Note that the impact event happens after collision resolution, so it cannot be used to prevent a collision from happening.
   * It also happens mid-step. So do not destroy a Body during this callback, instead set safeDestroy to true so it will be killed on the next preUpdate.
   *
   * @method Phaser.Physics.P2.Body#createGroupCallback
   * @param {Phaser.Physics.CollisionGroup} group - The Group to send impact events for.
   * @param {function} callback - The callback to fire on impact. Set to null to clear a previously set callback.
   * @param {object} callbackContext - The context under which the callback will fire.
   */
  createGroupCallback (CollisionGroup group, Function callback) {

    if (callback == null)
    {
      delete (this._groupCallbacks[group.mask]);
      delete (this._groupCallbacksContext[group.mask]);
    }
    else
    {
      this._groupCallbacks[group.mask] = callback;
      this._groupCallbackContext[group.mask] = callbackContext;
    }

  }

  /**
   * Gets the collision bitmask from the groups this body collides with.
   *
   * @method Phaser.Physics.P2.Body#getCollisionMask
   * @return {number} The bitmask.
   */
  getCollisionMask () {

    var mask = 0;

    if (this._collideWorldBounds)
    {
      mask = this.game.physics.p2.boundsCollisionGroup.mask;
    }

    for (var i = 0; i < this.collidesWith.length; i++)
    {
      mask = mask | this.collidesWith[i].mask;
    }

    return mask;

  }

  /**
   * Updates the collisionMask.
   *
   * @method Phaser.Physics.P2.Body#updateCollisionMask
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the collision group will be added to all Shapes in this Body.
   */
  updateCollisionMask (p2.Shape shape) {

    var mask = this.getCollisionMask();

    if ( shape == null)
    {
      for (var i = this.data.shapes.length - 1; i >= 0; i--)
      {
        this.data.shapes[i].collisionMask = mask;
      }
    }
    else
    {
      shape.collisionMask = mask;
    }

  }

  /**
   * Sets the given CollisionGroup to be the collision group for all shapes in this Body, unless a shape is specified.
   * This also resets the collisionMask.
   *
   * @method Phaser.Physics.P2.Body#setCollisionGroup
   * @param {Phaser.Physics.CollisionGroup} group - The Collision Group that this Bodies shapes will use.
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the collision group will be added to all Shapes in this Body.
   */
  setCollisionGroup (CollisionGroup group,p2.Shape shape) {

    var mask = this.getCollisionMask();

    if ( shape == null)
    {
      for (var i = this.data.shapes.length - 1; i >= 0; i--)
      {
        this.data.shapes[i].collisionGroup = group.mask;
        this.data.shapes[i].collisionMask = mask;
      }
    }
    else
    {
      shape.collisionGroup = group.mask;
      shape.collisionMask = mask;
    }

  }

  /**
   * Clears the collision data from the shapes in this Body. Optionally clears Group and/or Mask.
   *
   * @method Phaser.Physics.P2.Body#clearCollision
   * @param {boolean} [clearGroup=true] - Clear the collisionGroup value from the shape/s?
   * @param {boolean} [clearMask=true] - Clear the collisionMask value from the shape/s?
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the collision data will be cleared from all Shapes in this Body.
   */
  clearCollision ([bool clearGroup=true, bool clearMask=true, p2.Shape shape]) {

    if (shape == null)
    {
      for (var i = this.data.shapes.length - 1; i >= 0; i--)
      {
        if (clearGroup)
        {
          this.data.shapes[i].collisionGroup = null;
        }

        if (clearMask)
        {
          this.data.shapes[i].collisionMask = null;
        }
      }
    }
    else
    {
      if (clearGroup)
      {
        shape.collisionGroup = null;
      }

      if (clearMask)
      {
        shape.collisionMask = null;
      }
    }

    if (clearGroup)
    {
      this.collidesWith.clear();
    }

  }

  /**
   * Adds the given CollisionGroup, or array of CollisionGroups, to the list of groups that this body will collide with and updates the collision masks.
   *
   * @method Phaser.Physics.P2.Body#collides
   * @param {Phaser.Physics.CollisionGroup|array} group - The Collision Group or Array of Collision Groups that this Bodies shapes will collide with.
   * @param {function} [callback] - Optional callback that will be triggered when this Body impacts with the given Group.
   * @param {object} [callbackContext] - The context under which the callback will be called.
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the collision mask will be added to all Shapes in this Body.
   */
  collides (group, callback, shape) {

    if (Array.isArray(group))
    {
      for (var i = 0; i < group.length; i++)
      {
        if (this.collidesWith.indexOf(group[i]) == -1)
        {
          this.collidesWith.push(group[i]);

          if (callback)
          {
            this.createGroupCallback(group[i], callback, callbackContext);
          }
        }
      }
    }
    else
    {
      if (this.collidesWith.indexOf(group) == -1)
      {
        this.collidesWith.push(group);

        if (callback)
        {
          this.createGroupCallback(group, callback, callbackContext);
        }
      }
    }

    var mask = this.getCollisionMask();

    if ( shape == null)
    {
      for (var i = this.data.shapes.length - 1; i >= 0; i--)
      {
        this.data.shapes[i].collisionMask = mask;
      }
    }
    else
    {
      shape.collisionMask = mask;
    }

  }

  /**
   * Moves the shape offsets so their center of mass becomes the body center of mass.
   *
   * @method Phaser.Physics.P2.Body#adjustCenterOfMass
   */
  adjustCenterOfMass () {

    this.data.adjustCenterOfMass();

  }

  /**
   * Apply damping, see http://code.google.com/p/bullet/issues/detail?id=74 for details.
   *
   * @method Phaser.Physics.P2.Body#applyDamping
   * @param {number} dt - Current time step.
   */
  applyDamping (dt) {

    this.data.applyDamping(dt);

  }

  /**
   * Apply force to a world point. This could for example be a point on the RigidBody surface. Applying force this way will add to Body.force and Body.angularForce.
   *
   * @method Phaser.Physics.P2.Body#applyForce
   * @param {Float32Array|Array} force - The force vector to add.
   * @param {number} worldX - The world x point to apply the force on.
   * @param {number} worldY - The world y point to apply the force on.
   */
  applyForce (force, worldX, worldY) {

    this.data.applyForce(force, [this.world.pxmi(worldX), this.world.pxmi(worldY)]);

  }

  /**
   * Sets the force on the body to zero.
   *
   * @method Phaser.Physics.P2.Body#setZeroForce
   */
  setZeroForce () {

    this.data.setZeroForce();

  }

  /**
   * If this Body is dynamic then this will zero its angular velocity.
   *
   * @method Phaser.Physics.P2.Body#setZeroRotation
   */
  setZeroRotation () {

    this.data.angularVelocity = 0;

  }

  /**
   * If this Body is dynamic then this will zero its velocity on both axis.
   *
   * @method Phaser.Physics.P2.Body#setZeroVelocity
   */
  setZeroVelocity () {

    this.data.velocity[0] = 0;
    this.data.velocity[1] = 0;

  }

  /**
   * Sets the Body damping and angularDamping to zero.
   *
   * @method Phaser.Physics.P2.Body#setZeroDamping
   */
  setZeroDamping () {

    this.data.damping = 0;
    this.data.angularDamping = 0;

  }

  /**
   * Transform a world point to local body frame.
   *
   * @method Phaser.Physics.P2.Body#toLocalFrame
   * @param {Float32Array|Array} out - The vector to store the result in.
   * @param {Float32Array|Array} worldPoint - The input world vector.
   */
  toLocalFrame (out, worldPoint) {

    return this.data.toLocalFrame(out, worldPoint);

  }

  /**
   * Transform a local point to world frame.
   *
   * @method Phaser.Physics.P2.Body#toWorldFrame
   * @param {Array} out - The vector to store the result in.
   * @param {Array} localPoint - The input local vector.
   */
  toWorldFrame (out, localPoint) {

    return this.data.toWorldFrame(out, localPoint);

  }

  /**
   * This will rotate the Body by the given speed to the left (counter-clockwise).
   *
   * @method Phaser.Physics.P2.Body#rotateLeft
   * @param {number} speed - The speed at which it should rotate.
   */
  rotateLeft (speed) {

    this.data.angularVelocity = this.world.pxm(-speed);

  }

  /**
   * This will rotate the Body by the given speed to the left (clockwise).
   *
   * @method Phaser.Physics.P2.Body#rotateRight
   * @param {number} speed - The speed at which it should rotate.
   */
  rotateRight (speed) {

    this.data.angularVelocity = this.world.pxm(speed);

  }

  /**
   * Moves the Body forwards based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveForward
   * @param {number} speed - The speed at which it should move forwards.
   */
  moveForward (speed) {

    var magnitude = this.world.pxmi(-speed);
    var angle = this.data.angle + Math.PI / 2;

    this.data.velocity[0] = magnitude * Math.cos(angle);
    this.data.velocity[1] = magnitude * Math.sin(angle);

  }

  /**
   * Moves the Body backwards based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveBackward
   * @param {number} speed - The speed at which it should move backwards.
   */
  moveBackward (speed) {

    var magnitude = this.world.pxmi(-speed);
    var angle = this.data.angle + Math.PI / 2;

    this.data.velocity[0] = -(magnitude * Math.cos(angle));
    this.data.velocity[1] = -(magnitude * Math.sin(angle));

  }

  /**
   * Applies a force to the Body that causes it to 'thrust' forwards, based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#thrust
   * @param {number} speed - The speed at which it should thrust.
   */
  thrust (speed) {

    var magnitude = this.world.pxmi(-speed);
    var angle = this.data.angle + Math.PI / 2;

    this.data.force[0] += magnitude * Math.cos(angle);
    this.data.force[1] += magnitude * Math.sin(angle);

  }

  /**
   * Applies a force to the Body that causes it to 'thrust' backwards (in reverse), based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#reverse
   * @param {number} speed - The speed at which it should reverse.
   */
  reverse (speed) {

    var magnitude = this.world.pxmi(-speed);
    var angle = this.data.angle + Math.PI / 2;

    this.data.force[0] -= magnitude * Math.cos(angle);
    this.data.force[1] -= magnitude * Math.sin(angle);

  }

  /**
   * If this Body is dynamic then this will move it to the left by setting its x velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveLeft
   * @param {number} speed - The speed at which it should move to the left, in pixels per second.
   */
  moveLeft (speed) {

    this.data.velocity[0] = this.world.pxmi(-speed);

  }

  /**
   * If this Body is dynamic then this will move it to the right by setting its x velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveRight
   * @param {number} speed - The speed at which it should move to the right, in pixels per second.
   */
  moveRight (speed) {

    this.data.velocity[0] = this.world.pxmi(speed);

  }

  /**
   * If this Body is dynamic then this will move it up by setting its y velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveUp
   * @param {number} speed - The speed at which it should move up, in pixels per second.
   */
  moveUp (speed) {

    this.data.velocity[1] = this.world.pxmi(-speed);

  }

  /**
   * If this Body is dynamic then this will move it down by setting its y velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveDown
   * @param {number} speed - The speed at which it should move down, in pixels per second.
   */
  moveDown (speed) {

    this.data.velocity[1] = this.world.pxmi(speed);

  }

  /**
   * Internal method. This is called directly before the sprites are sent to the renderer and after the update function has finished.
   *
   * @method Phaser.Physics.P2.Body#preUpdate
   * @protected
   */
  preUpdate () {

    if (this.removeNextStep)
    {
      this.removeFromWorld();
      this.removeNextStep = false;
    }

  }

  /**
   * Internal method. This is called directly before the sprites are sent to the renderer and after the update function has finished.
   *
   * @method Phaser.Physics.P2.Body#postUpdate
   * @protected
   */
  postUpdate () {

    this.sprite.x = this.world.mpxi(this.data.position[0]);
    this.sprite.y = this.world.mpxi(this.data.position[1]);

    if (!this.fixedRotation)
    {
      this.sprite.rotation = this.data.angle;
    }

  }

  /**
   * Resets the Body force, velocity (linear and angular) and rotation. Optionally resets damping and mass.
   *
   * @method Phaser.Physics.P2.Body#reset
   * @param {number} x - The new x position of the Body.
   * @param {number} y - The new x position of the Body.
   * @param {boolean} [resetDamping=false] - Resets the linear and angular damping.
   * @param {boolean} [resetMass=false] - Sets the Body mass back to 1.
   */
  reset (num x, num y, [bool resetDamping=false, bool resetMass=false]) {

    if ( resetDamping == null) { resetDamping = false; }
    if ( resetMass == null) { resetMass = false; }

    this.setZeroForce();
    this.setZeroVelocity();
    this.setZeroRotation();

    if (resetDamping)
    {
      this.setZeroDamping();
    }

    if (resetMass)
    {
      this.mass = 1;
    }

    this.x = x;
    this.y = y;

  }

  /**
   * Adds this physics body to the world.
   *
   * @method Phaser.Physics.P2.Body#addToWorld
   */
  addToWorld () {

    if (this.game.physics.p2._toRemove)
    {
      for (var i = 0; i < this.game.physics.p2._toRemove.length; i++)
      {
        if (this.game.physics.p2._toRemove[i] == this)
        {
          this.game.physics.p2._toRemove.splice(i, 1);
        }
      }
    }

    if (this.data.world != this.game.physics.p2.world)
    {
      this.game.physics.p2.addBody(this);
    }

  }

  /**
   * Removes this physics body from the world.
   *
   * @method Phaser.Physics.P2.Body#removeFromWorld
   */
  removeFromWorld () {

    if (this.data.world == this.game.physics.p2.world)
    {
      this.game.physics.p2.removeBodyNextStep(this);
    }

  }

  /**
   * Destroys this Body and all references it holds to other objects.
   *
   * @method Phaser.Physics.P2.Body#destroy
   */
  destroy () {

    this.removeFromWorld();

    this.clearShapes();

    this._bodyCallbacks = {};
    this._bodyCallbackContext = {};
    this._groupCallbacks = {};
    this._groupCallbackContext = {};

    if (this.debugBody)
    {
      this.debugBody.destroy();
    }

    this.debugBody = null;
    this.sprite.body = null;
    this.sprite = null;

  }

  /**
   * Removes all Shapes from this Body.
   *
   * @method Phaser.Physics.P2.Body#clearShapes
   */
  clearShapes () {

    var i = this.data.shapes.length;

    while (i-- >0)
    {
      this.data.removeShape(this.data.shapes[i]);
    }

    this.shapeChanged();

  }

  /**
   * Add a shape to the body. You can pass a local transform when adding a shape, so that the shape gets an offset and an angle relative to the body center of mass.
   * Will automatically update the mass properties and bounding radius.
   *
   * @method Phaser.Physics.P2.Body#addShape
   * @param {p2.Shape} shape - The shape to add to the body.
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Shape} The shape that was added to the body.
   */
  p2.Shape addShape (shape, offsetX, offsetY, rotation) {

    if ( offsetX == null) { offsetX = 0; }
    if ( offsetY == null) { offsetY = 0; }
    if ( rotation == null) { rotation = 0; }

    this.data.addShape(shape, [this.world.pxmi(offsetX), this.world.pxmi(offsetY)], rotation);
    this.shapeChanged();

    return shape;

  }

  /**
   * Adds a Circle shape to this Body. You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addCircle
   * @param {number} radius - The radius of this circle (in pixels)
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Circle} The Circle shape that was added to the Body.
   */
  p2.Circle addCircle(num radius,[num offsetX=0, num offsetY=0, num rotation=0]) {

    var shape = new p2.Circle(this.world.pxm(radius));

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Rectangle shape to this Body. You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addRectangle
   * @param {number} width - The width of the rectangle in pixels.
   * @param {number} height - The height of the rectangle in pixels.
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Rectangle} The Rectangle shape that was added to the Body.
   */
  p2.Rectangle addRectangle (num width, num height,[num offsetX=0, num offsetY=0, num rotation=0]) {

    var shape = new p2.Rectangle(this.world.pxm(width), this.world.pxm(height));

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Plane shape to this Body. The plane is facing in the Y direction. You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addPlane
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Plane} The Plane shape that was added to the Body.
   */
  p2.Plane addPlane ([num offsetX=0, num offsetY=0, num rotation=0]) {

    var shape = new p2.Plane();

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Particle shape to this Body. You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addParticle
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Particle} The Particle shape that was added to the Body.
   */
  p2.Particle addParticle ([num offsetX=0, num offsetY=0,num rotation=0]) {

    var shape = new p2.Particle();

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Line shape to this Body.
   * The line shape is along the x direction, and stretches from [-length/2, 0] to [length/2,0].
   * You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addLine
   * @param {number} length - The length of this line (in pixels)
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Line} The Line shape that was added to the Body.
   */
  p2.Line addLine (num length, [num offsetX=0, num offsetY=0, num rotation=0]) {

    var shape = new p2.Line(this.world.pxm(length));

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Capsule shape to this Body.
   * You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addCapsule
   * @param {number} length - The distance between the end points in pixels.
   * @param {number} radius - Radius of the capsule in pixels.
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Capsule} The Capsule shape that was added to the Body.
   */
  p2.Capsule addCapsule (num length, num radius, [num offsetX=0, num offsetY=0, num rotation=0]) {
    var shape = new p2.Capsule(this.world.pxm(length), this.world.pxm(radius));
    return this.addShape(shape, offsetX, offsetY, rotation);
  }

  /**
   * Reads a polygon shape path, and assembles convex shapes from that and puts them at proper offset points. The shape must be simple and without holes.
   * This function expects the x.y values to be given in pixels. If you want to provide them at p2 world scales then call Body.data.fromPolygon directly.
   *
   * @method Phaser.Physics.P2.Body#addPolygon
   * @param {object} options - An object containing the build options:
   * @param {boolean} [options.optimalDecomp=false] - Set to true if you need optimal decomposition. Warning: very slow for polygons with more than 10 vertices.
   * @param {boolean} [options.skipSimpleCheck=false] - Set to true if you already know that the path is not intersecting itself.
   * @param {boolean|number} [options.removeCollinearPoints=false] - Set to a number (angle threshold value) to remove collinear points, or false to keep all points.
   * @param {(number[]|...number)} points - An array of 2d vectors that form the convex or concave polygon.
   *                                       Either [[0,0], [0,1],...] or a flat array of numbers that will be interpreted as [x,y, x,y, ...],
   *                                       or the arguments passed can be flat x,y values e.g. `setPolygon(options, x,y, x,y, x,y, ...)` where `x` and `y` are numbers.
   * @return {boolean} True on success, else false.
   */
  bool addPolygon (options, points) {

    options = options || {};

    if (!Array.isArray(points))
    {
      points = Array.prototype.slice.call(arguments, 1);
    }

    var path = [];

    //  Did they pass in a single array of points?
    if (points.length == 1 && points[0] is List)
  {
  path = points[0].slice(0);
  }
  else if (points[0] is List)
  {
  path = points.slice();
  }
  else if ( points[0] is num)
  {
  //  We've a list of numbers
  for (var i = 0, len = points.length; i < len; i += 2)
  {
  path.push([points[i], points[i + 1]]);
  }
  }

  //  top and tail
  var idx = path.length - 1;

  if (path[idx][0] == path[0][0] && path[idx][1] == path[0][1])
  {
  path.pop();
  }

  //  Now process them into p2 values
  for (var p = 0; p < path.length; p++)
  {
  path[p][0] = this.world.pxmi(path[p][0]);
  path[p][1] = this.world.pxmi(path[p][1]);
  }

  var result = this.data.fromPolygon(path, options);

  this.shapeChanged();

  return result;

}

/**
 * Remove a shape from the body. Will automatically update the mass properties and bounding radius.
 *
 * @method Phaser.Physics.P2.Body#removeShape
 * @param {p2.Circle|p2.Rectangle|p2.Plane|p2.Line|p2.Particle} shape - The shape to remove from the body.
 * @return {boolean} True if the shape was found and removed, else false.
 */
bool removeShape (p2.Shape shape) {

  bool result = this.data.removeShape(shape);

  this.shapeChanged();

  return result;
}

/**
 * Clears any previously set shapes. Then creates a new Circle shape and adds it to this Body.
 *
 * @method Phaser.Physics.P2.Body#setCircle
 * @param {number} radius - The radius of this circle (in pixels)
 * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
 * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
 * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
 */
setCircle (num radius, [num offsetX=0, num offsetY=0, num rotation=0]) {

  this.clearShapes();

  return this.addCircle(radius, offsetX, offsetY, rotation);

}

/**
 * Clears any previously set shapes. The creates a new Rectangle shape at the given size and offset, and adds it to this Body.
 * If you wish to create a Rectangle to match the size of a Sprite or Image see Body.setRectangleFromSprite.
 *
 * @method Phaser.Physics.P2.Body#setRectangle
 * @param {number} [width=16] - The width of the rectangle in pixels.
 * @param {number} [height=16] - The height of the rectangle in pixels.
 * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
 * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
 * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
 * @return {p2.Rectangle} The Rectangle shape that was added to the Body.
 */
setRectangle ([num width, num height, num offsetX=0, num offsetY=0, num rotation=0]) {

  if ( width == null) { width = 16; }
  if ( height == null) { height = 16; }

  this.clearShapes();

  return this.addRectangle(width, height, offsetX, offsetY, rotation);

}

/**
 * Clears any previously set shapes.
 * Then creates a Rectangle shape sized to match the dimensions and orientation of the Sprite given.
 * If no Sprite is given it defaults to using the parent of this Body.
 *
 * @method Phaser.Physics.P2.Body#setRectangleFromSprite
 * @param {Phaser.Sprite|Phaser.Image} [sprite] - The Sprite on which the Rectangle will get its dimensions.
 * @return {p2.Rectangle} The Rectangle shape that was added to the Body.
 */
setRectangleFromSprite (Phaser.SpriteInterface sprite) {

  if ( sprite == null) { sprite = this.sprite; }

  this.clearShapes();

  return this.addRectangle(sprite.width, sprite.height, 0, 0, sprite.rotation);

}

/**
 * Adds the given Material to all Shapes that belong to this Body.
 * If you only wish to apply it to a specific Shape in this Body then provide that as the 2nd parameter.
 *
 * @method Phaser.Physics.P2.Body#setMaterial
 * @param {Phaser.Physics.P2.Material} material - The Material that will be applied.
 * @param {p2.Shape} [shape] - An optional Shape. If not provided the Material will be added to all Shapes in this Body.
 */
setMaterial (Material material,Shape shape) {

  if (shape == null)
  {
    for (var i = this.data.shapes.length - 1; i >= 0; i--)
    {
      this.data.shapes[i].material = material;
    }
  }
  else
  {
    shape.material = material;
  }

}

/**
 * Updates the debug draw if any body shapes change.
 *
 * @method Phaser.Physics.P2.Body#shapeChanged
 */
shapeChanged() {

  if (this.debugBody)
  {
    this.debugBody.draw();
  }

}

/**
 * Reads the shape data from a physics data file stored in the Game.Cache and adds it as a polygon to this Body.
 * The shape data format is based on the custom phaser export in.
 *
 * @method Phaser.Physics.P2.Body#addPhaserPolygon
 * @param {string} key - The key of the Physics Data file as stored in Game.Cache.
 * @param {string} object - The key of the object within the Physics data file that you wish to load the shape data from.
 */
addPhaserPolygon (String key, String object) {

  var data = this.game.cache.getPhysicsData(key, object);
  var createdFixtures = [];

  //  Cycle through the fixtures
  for (var i = 0; i < data.length; i++)
  {
    var fixtureData = data[i];
    var shapesOfFixture = this.addFixture(fixtureData);

    //  Always add to a group
    createdFixtures[fixtureData.filter.group] = createdFixtures[fixtureData.filter.group] || [];
    createdFixtures[fixtureData.filter.group] = createdFixtures[fixtureData.filter.group].concat(shapesOfFixture);

    //  if (unique) fixture key is provided
    if (fixtureData.fixtureKey)
    {
      createdFixtures[fixtureData.fixtureKey] = shapesOfFixture;
    }
  }

  this.data.aabbNeedsUpdate = true;
  this.shapeChanged();

  return createdFixtures;

}

/**
 * Add a polygon fixture. This is used during #loadPolygon.
 *
 * @method Phaser.Physics.P2.Body#addFixture
 * @param {string} fixtureData - The data for the fixture. It contains: isSensor, filter (collision) and the actual polygon shapes.
 * @return {array} An array containing the generated shapes for the given polygon.
 */
List addFixture (String fixtureData) {

  var generatedShapes = [];

  if (fixtureData.circle)
  {
    var shape = new p2.Circle(this.world.pxm(fixtureData.circle.radius));
    shape.collisionGroup = fixtureData.filter.categoryBits;
    shape.collisionMask = fixtureData.filter.maskBits;
    shape.sensor = fixtureData.isSensor;

    var offset = p2.vec2.create();
    offset[0] = this.world.pxmi(fixtureData.circle.position[0] - this.sprite.width/2);
    offset[1] = this.world.pxmi(fixtureData.circle.position[1] - this.sprite.height/2);

    this.data.addShape(shape, offset);
    generatedShapes.push(shape);
  }
  else
  {
    var polygons = fixtureData.polygons;
    var cm = p2.vec2.create();

    for (var i = 0; i < polygons.length; i++)
    {
      var shapes = polygons[i];
      var vertices = [];

      for (var s = 0; s < shapes.length; s += 2)
      {
        vertices.push([ this.world.pxmi(shapes[s]), this.world.pxmi(shapes[s + 1]) ]);
      }

      var shape = new p2.Convex(vertices);

      //  Move all vertices so its center of mass is in the local center of the convex
      for (var j = 0; j != shape.vertices.length; j++)
      {
        var v = shape.vertices[j];
        p2.vec2.sub(v, v, shape.centerOfMass);
      }

      p2.vec2.scale(cm, shape.centerOfMass, 1);

      cm[0] -= this.world.pxmi(this.sprite.width / 2);
      cm[1] -= this.world.pxmi(this.sprite.height / 2);

      shape.updateTriangles();
      shape.updateCenterOfMass();
      shape.updateBoundingRadius();

      shape.collisionGroup = fixtureData.filter.categoryBits;
      shape.collisionMask = fixtureData.filter.maskBits;
      shape.sensor = fixtureData.isSensor;

      this.data.addShape(shape, cm);

      generatedShapes.push(shape);
    }
  }

  return generatedShapes;

}

/**
 * Reads the shape data from a physics data file stored in the Game.Cache and adds it as a polygon to this Body.
 *
 * @method Phaser.Physics.P2.Body#loadPolygon
 * @param {string} key - The key of the Physics Data file as stored in Game.Cache.
 * @param {string} object - The key of the object within the Physics data file that you wish to load the shape data from.
 * @return {boolean} True on success, else false.
 */
bool loadPolygon (String key, String object) {

  var data = this.game.cache.getPhysicsData(key, object);

  //  We've multiple Convex shapes, they should be CCW automatically
  var cm = p2.vec2.create();

  for (var i = 0; i < data.length; i++)
  {
    var vertices = [];

    for (var s = 0; s < data[i].shape.length; s += 2)
    {
      vertices.push([ this.world.pxmi(data[i].shape[s]), this.world.pxmi(data[i].shape[s + 1]) ]);
    }

    var c = new p2.Convex(vertices);

    // Move all vertices so its center of mass is in the local center of the convex
    for (var j = 0; j != c.vertices.length; j++)
    {
      var v = c.vertices[j];
      p2.vec2.sub(v, v, c.centerOfMass);
    }

    p2.vec2.scale(cm, c.centerOfMass, 1);

    cm[0] -= this.world.pxmi(this.sprite.width / 2);
    cm[1] -= this.world.pxmi(this.sprite.height / 2);

    c.updateTriangles();
    c.updateCenterOfMass();
    c.updateBoundingRadius();

    this.data.addShape(c, cm);
  }

  this.data.aabbNeedsUpdate = true;
  this.shapeChanged();

  return true;

}



//Phaser.Physics.P2.Body.prototype.constructor = Phaser.Physics.P2.Body;

/// Dynamic body. Dynamic bodies body can move and respond to collisions and forces.
static const int DYNAMIC = 1;

/// Static body. Static bodies do not move, and they do not respond to forces or collision.
static const int STATIC = 2;

/// Kinematic body. Kinematic bodies only moves according to its .velocity, and does not respond to collisions or force.
static const int KINEMATIC = 4;

}