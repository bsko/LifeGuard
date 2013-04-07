package shark 
{
	import Bodies.Body;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class Shark extends Sprite
	{
		public static const ATTACKS_DELAY:int = 4000;
		public static const LABEL_SWIMING:String = "swiming";
		public static const LABEL_EATING:String = "eating";
		public static const ANGLE_TO_EAT:int = 70;
		public static const DISTANCE_TO_EAT:int = 160;
		public static const DISTANCE_TO_STOP_ATTACKING:int = 230;
		public static const SHARK_SWIMMING_RADIUS:int = 200;
		public static const SHARK_SPEED:Number = 0.5;
		public static const SHARK_ROTATING_SPEED:Number = 9;
		public static const NAME:String = "shark";
		public static const STATE_SWIMMING:int = 1001;
		public static const STATE_ROUNDING_TO_EAT:int = 1002;
		public static const STATE_ROUNDING_TO_SWIM:int = 1003;
		public static const STATE_SWIMMING_TO_EAT:int = 1004;
		public static const MAX_DOWN_X:int = SharkGenerator.HIGH_END + SHARK_SWIMMING_RADIUS;
		
		public static var bodiesArray:Array;
		private var _movingArray:Array;
		private var _radius:int = SHARK_SWIMMING_RADIUS;
		private var _currentAngle:Number;
		private var _shark_movie:MovieClip = new SharkMovie();
		private var _currentPoint:Point;
		private var _direction:int;
		private var tmpBody:Body;
		private var _pointsArray:Array = [];
		private var _hero:Hero;
		private var _generator:SharkGenerator;
		private var _frames_counter:int = 0;
		private var _pointsCount:int;
		private var _state:int;
		private var _startingPoint:Point;
		private var _destinationTargetPoint:Point;
		private var _angle_to_rotate:int;
		private var _bodyToEat:Body;
		private var _heroToEat:Boolean;
		private var _startingAngle:int;
		private var _attack_swimming_delay:Number;
		private var _total_attack_swimming_delay:Number = 0;
		private var _isStoppedAttacking:Boolean;
		private	var _attackTimer:Timer = new Timer(ATTACKS_DELAY);
		private var _eatedHero:Boolean = false;
		
		public function Shark()
		{
			_movingArray = [];
			var tmpPoint:Point;
			var tmpObject:Object;
			var endAngle:Number;
			var rotation:Number;
			_currentAngle = App.randomInt(0, 360);
			_currentPoint = new Point(0, 0);
			if (Math.random() > .5)
			{
				_direction = 1;
				endAngle = _currentAngle + 360 * App.DEG_TO_RAD;
				while (_currentAngle < endAngle)
				{
					tmpPoint = new Point();
					tmpPoint.x = _currentPoint.x + _radius * Math.cos(_currentAngle);
					tmpPoint.y = _currentPoint.y + _radius * Math.sin(_currentAngle);
					rotation = _currentAngle * App.RAD_TO_DEG - 180;
					tmpObject = new Object();
					tmpObject.point = tmpPoint;
					tmpObject.angle = rotation;
					_movingArray.push(tmpObject);
					_currentAngle += _direction * 0.02;
				}
			}
			else
			{
				_direction = -1;
				endAngle = _currentAngle - 360 * App.DEG_TO_RAD;
				while (_currentAngle > endAngle)
				{
					tmpPoint = new Point();
					tmpPoint.x = _currentPoint.x + _radius * Math.cos(_currentAngle);
					tmpPoint.y = _currentPoint.y + _radius * Math.sin(_currentAngle);
					rotation = _currentAngle * App.RAD_TO_DEG;
					tmpObject = new Object();
					tmpObject.point = tmpPoint;
					tmpObject.angle = rotation;
					_movingArray.push(tmpObject);
					_currentAngle += _direction * 0.02;
				}
			}
			_pointsCount = _movingArray.length;
		}
		
		public function Init(startPosition:Point, hero:Hero, generator:SharkGenerator):void 
		{
			_isStoppedAttacking = false;
			_state = STATE_SWIMMING;
			_currentPoint = startPosition;
			_frames_counter = 0;
			_hero = hero;
			addChild(_shark_movie);
			_shark_movie.gotoAndStop(LABEL_SWIMING);
			addEventListener(Event.ENTER_FRAME, onUpdateSharkSwiming, false, 0, true);
			_generator = generator;
			_generator.addEventListener(Destroying.DESTROY, onDestroying, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			addEventListener(Event.ENTER_FRAME, onUpdateSharkSwiming, false, 0, true);
			_attackTimer.start();
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, onUpdateSharkSwiming, false);
			_attackTimer.stop();
		}
		
		private function onUpdateSharkSwiming(e:Event):void 
		{
			switch(_state)
			{
				case STATE_SWIMMING:
				_frames_counter++;
				if (_frames_counter == _movingArray.length)
				{
					_frames_counter = 0;
				}
				var tmpObject:Object = _movingArray[_frames_counter];
				var tmpPoint:Point = tmpObject.point;
				x = tmpPoint.x + _currentPoint.x;
				y = tmpPoint.y + _currentPoint.y;
				rotation = tmpObject.angle;
				
				if (!_isStoppedAttacking)
				{
					findTarget();
				}
				
				break;
				case STATE_ROUNDING_TO_EAT:
				if (_heroToEat)
				{
					var distance:int = Point.distance(new Point(this.x, this.y), new Point(_hero.x, _hero.y));
					if (distance > DISTANCE_TO_EAT)
					{
						TargetLost();
						break;
					}
				}
				else
				{
					distance = Point.distance(new Point(_bodyToEat.x, _bodyToEat.y), new Point(this.x, this.y));
					if (distance > DISTANCE_TO_EAT)
					{
						TargetLost();
						break;
					}
				}
				if (Math.abs(rotation - _angle_to_rotate) > SHARK_ROTATING_SPEED)
				{
					if (Math.abs(rotation - _angle_to_rotate) < 180)
					{
						if (rotation > _angle_to_rotate)
						{
							rotation -= SHARK_ROTATING_SPEED;
						}
						else
						{
							rotation += SHARK_ROTATING_SPEED;
						}
					}
					else
					{
						if (rotation > _angle_to_rotate)
						{
							rotation += SHARK_ROTATING_SPEED;
						}
						else
						{
							rotation -= SHARK_ROTATING_SPEED;
						}
					}
				}
				else
				{
					rotation = _angle_to_rotate;
					TargetCaptured();
				}
				break;
				case STATE_ROUNDING_TO_SWIM:
				if (Math.abs(rotation - _angle_to_rotate) > SHARK_ROTATING_SPEED)
				{
					if (Math.abs(rotation - _angle_to_rotate) < 180)
					{
						if (rotation > _angle_to_rotate)
						{
							rotation -= SHARK_ROTATING_SPEED;
						}
						else
						{
							rotation += SHARK_ROTATING_SPEED;
						}
					}
					else
					{
						if (rotation > _angle_to_rotate)
						{
							rotation += SHARK_ROTATING_SPEED;
						}
						else
						{
							rotation -= SHARK_ROTATING_SPEED;
						}
					}
				}
				else
				{
					rotation = _angle_to_rotate;
					_state = STATE_SWIMMING;
				}
				break;
				case STATE_SWIMMING_TO_EAT:
				_total_attack_swimming_delay += _attack_swimming_delay;
				var destinationPoint:Point;
				if (_heroToEat)
				{
					destinationPoint = new Point(_hero.x, _hero.y);
				}
				else
				{
					destinationPoint = new Point(_bodyToEat.x, _bodyToEat.y);
					if (_bodyToEat.movedToSavingState)
					{
						StopAttacking();
					}
				}
				var sharkPoint:Point = new Point(this.x, this.y);
				tmpPoint = Point.interpolate(destinationPoint, _startingPoint,  _total_attack_swimming_delay);
				if (tmpPoint.y > MAX_DOWN_X)
				{
					_total_attack_swimming_delay = 0;
					StopAttacking(true);
				}
				rotation = App.angleFinding(destinationPoint,  sharkPoint) + 180;
				this.x = tmpPoint.x;
				this.y = tmpPoint.y;
				if (_total_attack_swimming_delay >= 1)
				{
					_total_attack_swimming_delay = 0;
					if (_heroToEat)
					{
						eatHero();
					}
					else
					{
						eatBody(_bodyToEat);
					}
				}
				distance = Point.distance(sharkPoint, _startingPoint);
				if (distance > DISTANCE_TO_STOP_ATTACKING)
				{
					_total_attack_swimming_delay = 0;
					StopAttacking();
				}
				break;
			}
		}
		
		private function findTarget():void 
		{
			if (!_generator.stopEating)
			{
				var distance:int;
				distance = Point.distance(new Point(_hero.x, _hero.y), new Point(this.x, this.y));
				if (distance < DISTANCE_TO_EAT)
				{
					_heroToEat = true;
					TargetFound();
				}
				
				var length:int = bodiesArray.length;
				var tmpBody:Body;
				for (var i:int = 0; i < length; i++)
				{
					tmpBody = bodiesArray[i];
					if (!tmpBody.isDead)
					{
						distance = Point.distance(new Point(tmpBody.x, tmpBody.y), new Point(this.x, this.y));
						if (distance < DISTANCE_TO_EAT)
						{
							_bodyToEat = tmpBody;
							TargetFound();
						}
					}
				}
			}
		}
		
		private function StopAttacking(warning:Boolean = false):void 
		{
			var tmpObject:Object;
			var tmpPoint:Point;
			var length:int = _movingArray.length;
			var maxY:Number = 0;
			var thisFrame:int;
			if (warning)
			{
				for (var i:int = 0; i < length; i++)
				{
					tmpObject = _movingArray[i];
					tmpPoint = tmpObject.point;
					if (maxY < tmpPoint.y)
					{
						maxY = tmpPoint.y;
						thisFrame = i;
					}
				}
				
				tmpObject = _movingArray[thisFrame];
				tmpPoint = tmpObject.point;
				_currentPoint.x = this.x - tmpPoint.x;
				_currentPoint.y = this.y - tmpPoint.y;
				_frames_counter = thisFrame;
				_angle_to_rotate = tmpObject.angle;
				while (Math.abs(_angle_to_rotate) > 181)
				{
					if (_angle_to_rotate > 0)
					{
						_angle_to_rotate -= 360;
					}
					else
					{
						_angle_to_rotate += 360;
					}
				}
				_state = STATE_ROUNDING_TO_SWIM;
			}
			else
			{
				tmpObject = _movingArray[_frames_counter];
				tmpPoint = tmpObject.point;
				_currentPoint.x = this.x - tmpPoint.x;
				_currentPoint.y = this.y - tmpPoint.y;	
				_angle_to_rotate = tmpObject.angle;
				while (Math.abs(_angle_to_rotate) > 181)
				{
					if (_angle_to_rotate > 0)
					{
						_angle_to_rotate -= 360;
					}
					else
					{
						_angle_to_rotate += 360;
					}
				}
				_state = STATE_ROUNDING_TO_SWIM;
			}
			x = tmpPoint.x + _currentPoint.x;
			y = tmpPoint.y + _currentPoint.y;
			_isStoppedAttacking = true;
			_attackTimer.start();
			_attackTimer.addEventListener(TimerEvent.TIMER, onStartAttacking, false, 0, true);
		}
		
		private function onStartAttacking(e:TimerEvent):void 
		{
			_attackTimer.reset();
			_attackTimer.removeEventListener(TimerEvent.TIMER, onStartAttacking, false);
			_isStoppedAttacking = false;
		}
		
		private function TargetCaptured():void 
		{
			_startingPoint = new Point(this.x, this.y);
			var distance:int;
			if (_heroToEat)
			{
				distance = Point.distance(new Point(this.x, this.y), new Point(_hero.x, _hero.y));
			}
			else
			{
				distance = Point.distance(new Point(this.x, this.y), new Point(_bodyToEat.x, _bodyToEat.y));
			}
			_attack_swimming_delay = 1 / ( distance * SHARK_SPEED );
			_state = STATE_SWIMMING_TO_EAT;
		}
		
		private function TargetLost():void 
		{
			_angle_to_rotate = _startingAngle;
			_heroToEat = false;
			_bodyToEat = null;
			_state = STATE_ROUNDING_TO_SWIM;
		}
		
		private function TargetFound():void 
		{
			_state = STATE_ROUNDING_TO_EAT;
			
			if (_heroToEat)
			{
				_destinationTargetPoint = new Point(_hero.x, _hero.y);
			}
			else
			{
				_destinationTargetPoint = new Point(_bodyToEat.x, _bodyToEat.y);
			}
			
			_startingAngle = rotation;
			_angle_to_rotate = App.angleFinding(new Point(this.x, this.y), _destinationTargetPoint);
			
			while (_angle_to_rotate > 180)
			{
				_angle_to_rotate -= 360;
			}
		}
		
		private function eatHero():void 
		{
			_shark_movie.gotoAndStop(LABEL_EATING);
			removeEventListener(Event.ENTER_FRAME, onUpdateSharkSwiming, false);
			_shark_movie.shark.addEventListener("eated", onDestroying1, false, 0, true);
			_eatedHero = true;
		}
		
		private function onDestroying1(e:Event):void 
		{
			if (_eatedHero)
			{
				_hero.Die();
				App.gameInterface.endLevel();
			}
			Destroy();
		}
		
		private function eatBody(tmpBody:Body):void 
		{
			_shark_movie.gotoAndStop(LABEL_EATING);
			removeEventListener(Event.ENTER_FRAME, onUpdateSharkSwiming, false);
			_shark_movie.shark.addEventListener("eated", onDestroying1, false, 0, true);
			tmpBody.Destroy();
			App.universe.deathsCount++;
		}
		
		private function onDestroying(e:Destroying):void 
		{
			Destroy();
		}
		
		public function Destroy():void 
		{
			_eatedHero = false;
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			if (contains(_shark_movie))
			{
				removeChild(_shark_movie);
			}
			removeEventListener(Event.ENTER_FRAME, onUpdateSharkSwiming, false);
			/*if (_isEating)
			{
				_shark_movie.shark.addEventListener("eated", onDestroying, false, 0, true);
				_shark_movie.gotoAndStop(LABEL_EATING);
				_isEating = true;
			}*/
			removeFromSharksArray();
			App.pools.returnPoolObject(NAME, this);
			_generator.removeEventListener(Destroying.DESTROY, onDestroying, false);
		}
		
		private function removeFromSharksArray():void 
		{
			var length:int = SharkGenerator.sharksArray.length;
			var tmpShark:Shark;
			for (var i:int = 0; i < length; i++)
			{
				tmpShark = SharkGenerator.sharksArray[i];
				if (tmpShark == this)
				{
					SharkGenerator.sharksArray.splice(i, 1);
					return;
				}
			}
		}
	}

}