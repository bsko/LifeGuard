package  
{
	import Bodies.Body;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import Box2DBodies.*;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class Hero extends Sprite
	{
		private static const LABEL_RUNNING:String = "running";
		private static const LABEL_STANDING:String = "standing";
		private static const LABEL_SWIMING:String = "swimming";
		private static const LABEL_STAND_SWIMING:String = "stand_swiming";
		private static const LABEL_SHOOTING_ROUND:String = "shooting_round";
		private static const LABEL_SHOOTING_ROCKET:String = "shooting_rocket";
		
		public static const HERO_IS_ON_WATER:int = 101;
		public static const HERO_IS_ON_SAND:int = 102;
		public static const HERO_IS_MOVING:int = 103;
		public static const HERO_IS_STANDING:int = 104;
		public static const HERO_IS_SHOOTING_ROUND:int = 105;
		public static const HERO_IS_SHOOTING_ROCKET:int = 106;
		
		public static const SOUND_UPDATE_DELAY:int = 800;
		
		private var _isMoving:Boolean = false;
		private var _state:int;
		
		public static const DEFAULT_SPEED:int = 3;
		public static const UPPED_SPEED:int = 5;
		public static const REDUCED_SPEED:int = 2;
		
		public static const BONUS_FOR_SAND:int = 2;
		
		private var _killedSharks:int;
		private var _heroMovie:MovieClip = new HeroFullMovie();
		private var _movingSprite:Sprite;
		private var _speed:Number = DEFAULT_SPEED;
		private var _bonus_speed:int = 0;
		private var _isHasABody:Boolean;
		private var _bodyToSave:Body;
		private var _roundsCount:int;
		private var _flairsCount:int;
		private var _heroBody:b2Body;
		private var _heroSpeedUpMode:Boolean = false;
		private var _heroSpeedDownMode:Boolean = false;
		private var _soundTimer:Timer = new Timer(SOUND_UPDATE_DELAY);
		
		public function Hero() 
		{
			addChild(_heroMovie);
		}
		
		public function Init():void 
		{
			_bonus_speed = 0;
			_heroMovie.gotoAndStop(LABEL_STANDING);
			this.x = 330;
			this.y = 2750;
			isMoving = false;
			state = HERO_IS_ON_SAND;
			updateState();
			_heroBody = CreateBody();
			_heroBody.SetUserData(this);
			_isHasABody = false;
			_roundsCount = 0;
			_flairsCount = 0;
			_killedSharks = 0;
			addEventListener(Event.ENTER_FRAME, onUpdateBody, false, 0, true);
		}
		
		/*private function onUpdateSound(e:TimerEvent):void 
		{
			if (_isMoving)
			{
				if (state == HERO_IS_ON_SAND)
				{
					App.soundManager.playSound("runningSnd");
					//App.soundManager.playSound(
				}
				else if (state == HERO_IS_ON_WATER)
				{
					App.soundManager.playSound("swimmingSnd");
				}
			}
		}*/
		
		private function onUpdateBody(e:Event):void 
		{
			this.x = _heroBody.GetPosition().x * App.WORLD_SCALE;
			this.y = _heroBody.GetPosition().y * App.WORLD_SCALE;
		}
		
		private function CreateBody():b2Body 
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(x / App.WORLD_SCALE, y / App.WORLD_SCALE);
			myBody.type = b2Body.b2_dynamicBody;
			myBody.allowSleep = false;
			var myBall:b2CircleShape = new b2CircleShape(_heroMovie.width/4/App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			return worldBody;
		}
		
		public function updateState():void 
		{
			if (isMoving)
			{
				if (state == HERO_IS_ON_SAND)
				{
					_heroMovie.gotoAndStop(LABEL_RUNNING)
					App.soundManager.stopMovingSound();
					App.soundManager.playSound("runningSnd");
					_bonus_speed = BONUS_FOR_SAND;
					if (isHasABody)
					{
						saveABody();
					}
				}
				else if (state == HERO_IS_ON_WATER)
				{
					App.soundManager.stopMovingSound();
					App.soundManager.playSound("swimmingSnd");
					_heroMovie.gotoAndStop(LABEL_SWIMING);
					_bonus_speed = 0;
				}
				
				if (_bodyToSave != null)
				{
					_bodyToSave.bodyMovie.gotoAndStop(Body.LABEL_SAVED);
				}
			}
			else
			{
				App.soundManager.stopMovingSound();
				if (state == HERO_IS_ON_SAND)
				{
					_heroMovie.gotoAndStop(LABEL_STANDING)
				}
				else if (state == HERO_IS_ON_WATER)
				{
					_heroMovie.gotoAndStop(LABEL_STAND_SWIMING)
				}
				else if (state == HERO_IS_SHOOTING_ROUND)
				{
					_heroMovie.gotoAndStop(LABEL_SHOOTING_ROUND);
				}
				else if (state == HERO_IS_SHOOTING_ROCKET)
				{
					_heroMovie.gotoAndStop(LABEL_SHOOTING_ROCKET);
				}
				
				if (_bodyToSave != null)
				{
					_bodyToSave.bodyMovie.gotoAndStop(Body.LABEL_SAVED_STOPPED);
				}
			}
		}
		
		private function saveABody():void 
		{
			if (_isHasABody)
			{
				_isHasABody = false;
			}
			removeChild(_bodyToSave.bodyMovie);
			_bodyToSave.saved();
			_bodyToSave = null;
		}
		
		public function takeAVictim(body:Body):void 
		{
			isHasABody = true;
			_bodyToSave = body;
			_bodyToSave.bodyMovie.gotoAndStop(Body.LABEL_SAVED);
			addChild(_bodyToSave.bodyMovie);
		}
		
		public function Destroy():void 
		{
			_heroMovie.alpha = 1;
			_heroMovie.gotoAndStop(LABEL_STANDING);
			isMoving = false;
			state = HERO_IS_ON_SAND;
			updateState();
			App.world.DestroyBody(_heroBody);
			_isHasABody = false;
			_roundsCount = 0;
			_flairsCount = 0;
			_bodyToSave = null;
			//_soundTimer.stop();
			while (numChildren != 0)
			{
				removeChildAt(0);
			}
			//_soundTimer.removeEventListener(TimerEvent.TIMER, onUpdateSound, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateBody, false);
			
			
			//removeEventListener(Event.ENTER_FRAME, updateMyBody, false);
		}
		
		public function takeARound():void 
		{
			App.soundManager.playSound("deviceSnd");
			App.universe.roundsCount++;
		}
		
		public function takeARocket():void 
		{
			App.soundManager.playSound("deviceSnd");
			App.universe.flaresCount++;
		}
		
		public function Die():void 
		{
			_heroMovie.alpha = 0;
		}
		
		public function get speed():Number { return _speed; }
		
		public function get isHasABody():Boolean { return _isHasABody; }
		
		public function set isHasABody(value:Boolean):void 
		{
			_isHasABody = value;
		}
		
		public function get isMoving():Boolean { return _isMoving; }
		
		public function set isMoving(value:Boolean):void 
		{
			_isMoving = value;
		}
		
		public function get state():int { return _state; }
		
		public function set state(value:int):void 
		{
			_state = value;
		}
		
		public function get heroBody():b2Body { return _heroBody; }
		
		public function set heroBody(value:b2Body):void 
		{
			_heroBody = value;
		}
		
		public function get heroSpeedUpMode():Boolean { return _heroSpeedUpMode; }
		
		public function set heroSpeedUpMode(value:Boolean):void 
		{
			_heroSpeedUpMode = value;
		}
		
		public function get heroSpeedDownMode():Boolean { return _heroSpeedDownMode; }
		
		public function set heroSpeedDownMode(value:Boolean):void 
		{
			_heroSpeedDownMode = value;
		}
	
		public function set speed(value:Number):void 
		{
			_speed = value;
		}
		
		public function get killedSharks():int { return _killedSharks; }
		
		public function set killedSharks(value:int):void 
		{
			_killedSharks = value;
		}
		
		public function get bonus_speed():int { return _bonus_speed; }
		
		public function set bonus_speed(value:int):void 
		{
			_bonus_speed = value;
		}
		
	}

}