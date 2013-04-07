package Bodies
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class Body extends Sprite
	{
		public static const NAME:String = "body";
		public static const BODY_TYPES_COUNT:int = 2;
		public static const LABEL_SWIMING:String = "swiming";
		public static const LABEL_SAVED:String = "saved";
		public static const LABEL_SAVED_STOPPED:String = "saved_stopped";
		public static const LABEL_WITH_ROUND:String = "withroung";
		public static const LABEL_RUNNING:String = "running";
		public static const STARTING_PHASE:int = 4;
		public static const ISLAND_SAVING_POINT:Point = new Point(1720 , 2200);
		public static const STUN_TIMER_DELAY:int = 3000;
		
		public static const DISTANCE_TO_SAVE:int = 30;
		public static const PHASE_TIME:int = 1200;
		public static const ONE_PHASE_TIMER_COUNTS:int = 5;
		public static var universe:Universe;
		private var _drownTimer:Timer = new Timer(PHASE_TIME);
		private var _phase_timer_counter:int = 0;
		private var _phase:int;
		private var _movieGirl:MovieClip = new BodyGirl();
		private var _movieBoy:MovieClip = new BodyMan();
		private var _bodyMovie:MovieClip;
		private var _arrow:MovieClip = new ArrowMovie();
		private var _arrowAdded:Boolean = false;
		private var _arrowLayer:Sprite;
		private var _hero:Hero;
		private var _model:String;
		private var _label_name:String;
		private var _isDead:Boolean;
		private var _generator:BodyGenerator;
		private var _isHaveARound:Boolean;
		private var _visualTimer:MovieClip = new save_timer();
		private var _totalFrames:int = _visualTimer.totalFrames;
		private var _totalDrowningTime:int = (STARTING_PHASE + 1) * PHASE_TIME;
		private var _savingToIsland:Boolean = false;
		private var _islandSavingStartingPoint:Point;
		private var _islandSavingDelay:Number;
		private var _islandSavingTotalNumber:Number = 0;
		private var _movedToSavingState:Boolean = false;
		private var _savingDown:Boolean = false;
		private var _starsMovie:MovieClip;
		private var _isStunned:Boolean = false;
		private var _stunTimer:Timer = new Timer(STUN_TIMER_DELAY);
		
		private var _round_firstPoint:Point;
		private var _round_destinationPoint:Point;
		private var _round_step:Number;
		private var _round_totalStep:Number;
		private var _round_savingDown:Boolean;
		private var _bodyBody:b2Body;
		private var _currentCount:int;
		private var _isFlashing:Boolean;
		private var _alpha_direction:int = -1;
		
		private var _listenersArray:Array = [];
		
		public function Body()
		{
			arrow.gotoAndStop(1);
		}
		
		public function Init(layerForArrows:Sprite, hero:Hero, generator:BodyGenerator, onlyGirls:Boolean = false):void 
		{
			_isFlashing = false;
			if (!onlyGirls)
			{
				switch(App.randomInt(1, BODY_TYPES_COUNT + 1))
				{
					case 1:
					_bodyMovie = _movieGirl;
					_model = "girl";
					break;
					case 2:
					_bodyMovie = _movieBoy;
					_model = "man";
					break;
				}
			}
			else
			{
				_bodyMovie = _movieGirl;
				_model = "girl";
			}
			_bodyMovie.gotoAndStop(LABEL_SWIMING);
			_starsMovie = _bodyMovie.stars;
			_starsMovie.visible = false;
			
			_currentCount = 0;
			_bodyBody = CreateBody();
			_bodyBody.SetUserData(this);
			addChild(_bodyMovie);
			_savingDown = false;
			_savingToIsland = false;
			_movedToSavingState = false;
			_isHaveARound = false;
			isDead = false;
			_arrowLayer = layerForArrows;
			_hero = hero;
			_arrowLayer.addChild(arrow);
			arrowAdded = true;
			_phase = STARTING_PHASE;
			_label_name = _model + "_phase" + String(_phase - 1);
			arrow.gotoAndStop(2);
			arrow.rounding.gotoAndStop(_label_name);
			rotation = App.randomInt(0, 360);
			_visualTimer.visible = true;
			addChild(_visualTimer);
			_visualTimer.gotoAndStop(1);
			_visualTimer.rotation = - rotation;
			_drownTimer.start();
			_drownTimer.addEventListener(TimerEvent.TIMER, onChangePhase, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateVisualTimer, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateState, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateArrow, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateBodyPosition, false, 0, true);
			_generator = generator;
			_generator.addEventListener(Destroying.DESTROY, onDestroying, false, 0, true);
			
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			_drownTimer.start();
			
			while(_listenersArray.length != 0)
			{
				var tmpObject:Object = _listenersArray.shift();
				tmpObject.target.addEventListener(tmpObject.type, tmpObject.handler, false, 0, true);
			}
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_listenersArray.length = 0;
			_drownTimer.stop();
			
			var tmpObject:Object = new Object();
			tmpObject.target = this;
			tmpObject.type = Event.ENTER_FRAME;
			tmpObject.handler = onUpdateVisualTimer;
			_listenersArray.push(tmpObject);
			removeEventListener(Event.ENTER_FRAME, onUpdateVisualTimer, false);
			
			var tmpObject1:Object = new Object();
			tmpObject1.target = this;
			tmpObject1.type = Event.ENTER_FRAME;
			tmpObject1.handler = onUpdateState;
			_listenersArray.push(tmpObject1);
			removeEventListener(Event.ENTER_FRAME, onUpdateState, false);
			
			var tmpObject2:Object = new Object();
			tmpObject2.target = this;
			tmpObject2.type = Event.ENTER_FRAME;
			tmpObject2.handler = onUpdateArrow;
			_listenersArray.push(tmpObject2);
			removeEventListener(Event.ENTER_FRAME, onUpdateArrow, false);
			
			var tmpObject3:Object = new Object();
			tmpObject3.target = this;
			tmpObject3.type = Event.ENTER_FRAME;
			tmpObject3.handler = onUpdateBodyPosition;
			_listenersArray.push(tmpObject3);
			removeEventListener(Event.ENTER_FRAME, onUpdateBodyPosition, false);
		}
		
		private function onUpdateBodyPosition(e:Event):void 
		{
			var pos:b2Vec2 = new b2Vec2();
			pos.x = x / App.WORLD_SCALE;
			pos.y = y / App.WORLD_SCALE;
			_bodyBody.SetPosition(pos);
		}
		
		private function CreateBody():b2Body 
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(x / App.WORLD_SCALE, y / App.WORLD_SCALE);
			myBody.type = b2Body.b2_dynamicBody;
			myBody.allowSleep = false;
			var myBall:b2CircleShape = new b2CircleShape(5/App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.isSensor = true;
			myFixture.shape = myBall;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			return worldBody;
		}
		
		private function onUpdateVisualTimer(e:Event):void 
		{
			var currentPoint:Number = _currentCount / ((STARTING_PHASE + 1) * ONE_PHASE_TIMER_COUNTS);
			_visualTimer.gotoAndStop(Math.ceil( currentPoint * _totalFrames));
		}
		
		private function onDestroying(e:Destroying):void 
		{
			Destroy();
		}
		
		private function onChangePhase(e:TimerEvent):void 
		{
			if (!isDead)
			{
				_currentCount++;
				_phase_timer_counter++;
				if (_phase_timer_counter == ONE_PHASE_TIMER_COUNTS)
				{
					_phase_timer_counter = 0;
					_phase--;
					if (_phase < 0)
					{
						App.universe.deathsCount++;
						Destroy();
					}
					else if (_phase == 0)
					{
						arrow.gotoAndStop(1);
						_isFlashing = true;
						addEventListener(Event.ENTER_FRAME, onUpdateFlashing, false, 0, true);
					}
					else
					{
						_label_name = _model + "_phase" + String(_phase - 1);
						arrow.rounding.gotoAndStop(_label_name);
					}
				}
			}
		}
		
		private function onUpdateFlashing(e:Event):void 
		{
			alpha += _alpha_direction * (0.1);
			if (alpha <= 0.3) { _alpha_direction = 1; }
			else if (alpha >= 1) { _alpha_direction = -1; }
		}
		
		private function onUpdateArrow(e:Event):void 
		{
			if (!isDead)
			{
				var thisOnStage:Point = universe.localToGlobal(new Point(x, y));
				
				if (!(thisOnStage.x < 0 || thisOnStage.x > App.STAGE_WIDTH || thisOnStage.y < 0 || thisOnStage.y > App.STAGE_HEIGHT))
				{
					arrow.visible = false;
				}
				else
				{
					var stageCenter:Point = universe.globalToLocal(new Point(App.STAGE_HALF_WIDTH, App.STAGE_HALF_HEIGHT));
					arrow.visible = true;
					var tmpIdentify:Number = Math.abs((this.y - stageCenter.y) / (this.x - stageCenter.x));
					var tmpStep:Number;
					if (tmpIdentify > App.STAGE_WIDTH_TO_HEIGHT)
					{
						tmpStep = Math.abs(App.STAGE_HALF_HEIGHT / (this.y - stageCenter.y));
					}
					else
					{
						tmpStep = Math.abs(App.STAGE_HALF_WIDTH / (this.x - stageCenter.x));
					}
					
					var arrowPoint:Point = Point.interpolate(new Point(this.x, this.y), stageCenter, tmpStep);
					arrow.x = arrowPoint.x;
					arrow.y = arrowPoint.y;
					arrow.rotation = App.angleFinding(stageCenter, new Point(this.x, this.y));
					if (_phase > 0)
					{ arrow.rounding.rotation = - arrow.rotation;} 
				}
			}
		}
		
		public function resetDrawningPhase():void 
		{
			if (_phase == 0)
			{
				stopFlashing();
			}
			_currentCount = 0;
			_phase = 3;
			_drownTimer.reset();
			_drownTimer.start();
			_label_name = _model + "_phase" + _phase.toString();
			arrow.gotoAndStop(2);
			arrow.rounding.gotoAndStop(_label_name);
		}
		
		private function stopFlashing():void 
		{
			arrow.gotoAndStop(1);
			removeEventListener(Event.ENTER_FRAME, onUpdateFlashing, false);
			_isFlashing = false;
			alpha = 1;
		}
		
		public function takeARound():void 
		{
			if (_isFlashing)
			{
				stopFlashing();
			}
			_isHaveARound = true;
			_bodyMovie.gotoAndStop(LABEL_WITH_ROUND);
			_visualTimer.visible = false;
			_drownTimer.removeEventListener(TimerEvent.TIMER, onChangePhase, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateVisualTimer, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateState, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateArrow, false);
			
			
			_round_firstPoint = new Point(this.x, this.y);
			var _round_downPoint:Point = new Point(this.x, Universe.MAP_HEIGHT);
			var downDistance:int = Point.distance(_round_firstPoint, _round_downPoint);
			var islandDistance:int = Point.distance(_round_firstPoint, ISLAND_SAVING_POINT);
			
			if (downDistance > islandDistance)
			{
				_round_destinationPoint = ISLAND_SAVING_POINT;
				_round_step = 1 / islandDistance;
				_round_savingDown = false;
			}
			else
			{
				_round_destinationPoint = _round_downPoint;
				_round_step = 1 / downDistance;
				_round_savingDown = true;
			}
			_round_totalStep = 0;
			
			addEventListener(Event.ENTER_FRAME, onSavingByRound, false, 0, true);
			rotation = App.angleFinding(_round_firstPoint, _round_destinationPoint);
		}
		
		private function onSavingByRound(e:Event):void 
		{
			_round_totalStep += _round_step;
			var point:Point = Point.interpolate(_round_destinationPoint, _round_firstPoint, _round_totalStep);
			this.x = point.x;
			this.y = point.y;
			
			if (_round_totalStep >= 1)
			{
				
				Destroy();
			}
		}
		
		private function onSavingDown(e:Event):void 
		{
			if (!_savingToIsland)
			{
				this.y++;
				rotation = 180;
				if (y > Universe.SAND_START)
				{
					//_bodyMovie.gotoAndStop(LABEL_RUNNING);
					this.y++;
				}
				if (y > Universe.MAP_HEIGHT)
				{
					
					Destroy();
				}
			}
			else
			{
				_islandSavingTotalNumber += _islandSavingDelay;
				rotation = App.angleFinding(_islandSavingStartingPoint, ISLAND_SAVING_POINT);
				var tmpPoint:Point = Point.interpolate(ISLAND_SAVING_POINT, _islandSavingStartingPoint, _islandSavingTotalNumber);
				this.x = tmpPoint.x;
				this.y = tmpPoint.y;
				if (_islandSavingTotalNumber >= 1)
				{
					Destroy();
				}
			}
		}
		
		private function onUpdateState(e:Event):void 
		{
			if (!_hero.isHasABody && !isDead)
			{
				var distance:int = Point.distance(new Point(this.x, this.y), new Point(_hero.x, _hero.y));
				if (distance < DISTANCE_TO_SAVE)
				{
					_hero.takeAVictim(this);
					moveToSavingState();
				}
			}
		}
		
		private function moveToSavingState():void 
		{
			if (_isFlashing)
			{
				stopFlashing();
			}
			_movedToSavingState = true;
			if (_isStunned)
			{
				onTakeStunOff();
			}
			_drownTimer.reset();
			_visualTimer.visible = false;
			removeEventListener(Event.ENTER_FRAME, onUpdateVisualTimer, false);
			_drownTimer.removeEventListener(TimerEvent.TIMER, onChangePhase, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateState, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateArrow, false);
		}
		
		public function Destroy():void 
		{
			x = -500;
			y = -500;
			_phase = STARTING_PHASE;
			arrow.gotoAndStop(2);
			arrow.rounding.stop();
			_currentCount = 0;
			if (_isFlashing) { stopFlashing(); }
			if (isHaveARound)
			{
				removeEventListener(Event.ENTER_FRAME, onSavingByRound, false);
				_isHaveARound = false;
			}
			removeFromBodiesArray();
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			App.world.DestroyBody(_bodyBody);
			_savingToIsland = false;
			isDead = true;
			_arrowLayer.removeChild(this);
			if (contains(bodyMovie))
			{
				removeChild(bodyMovie);
			}
			removeEventListener(Event.ENTER_FRAME, onSavingDown, false);
			_arrowLayer.removeChild(_arrow);
			_visualTimer.visible = false;
			removeEventListener(Event.ENTER_FRAME, onUpdateVisualTimer, false);
			_drownTimer.reset();
			_drownTimer.removeEventListener(TimerEvent.TIMER, onChangePhase, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateBodyPosition, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateState, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateArrow, false);
			_generator.removeEventListener(Destroying.DESTROY, onDestroying, false);
			_bodyMovie = null;
			App.pools.returnPoolObject(NAME, this);
		}
		
		private function removeFromBodiesArray():void 
		{
			var length:int = BodyGenerator.bodiesArray.length;
			var tmpBody:Body;
			for (var i:int = 0; i < length; i++)
			{
				tmpBody = BodyGenerator.bodiesArray[i];
				if (tmpBody == this)
				{
					BodyGenerator.bodiesArray.splice(i, 1);
					return;
				}
			}
		}
		
		public function saved():void 
		{	
			addChild(bodyMovie);
			_bodyMovie.gotoAndStop(LABEL_RUNNING);
			x = _hero.x;
			y = _hero.y;
			if (y < Universe.SAND_START - 130)
			{
				_savingToIsland = true;
				_islandSavingStartingPoint = new Point(x, y);
				_islandSavingDelay = 1 / Point.distance(_islandSavingStartingPoint, ISLAND_SAVING_POINT);
				_islandSavingTotalNumber = 0;
			}
			else
			{
				_savingDown = true;
			}
			addEventListener(Event.ENTER_FRAME, onSavingDown, false, 0, true);
			
			var bonusScore:int;
			
			if (_model == "girl")
			{
				bonusScore = App.POINTS_FOR_GIRL * App.universe.multiplier * (App.universe.saved_bodies_count / 20 + 0.5);
			}
			else if (_model == "man")
			{
				bonusScore = App.POINTS_FOR_MAN * App.universe.multiplier * (App.universe.saved_bodies_count / 20 + 0.5);
			}
			
			var a:PopupMessage = App.pools.getPoolObject(PopupMessage.NAME);
			var string:String = "+" + bonusScore.toString();
			a.Init(x, y, PopupMessage.TYPE_INCREASED_SCORE, string);
			
			App.universe.score += bonusScore;
			App.universe.saved_bodies_count++;
		}
		
		public function aplyRocket():void 
		{
			if (_isDead || _isHaveARound || _movedToSavingState || _isHaveARound || _savingDown || _savingToIsland)
			{
				return;
			}
			_phase--;
			_currentCount += ONE_PHASE_TIMER_COUNTS;
			_starsMovie.visible = true;
			_isStunned = true;
			_stunTimer.start();
			_stunTimer.addEventListener(TimerEvent.TIMER, onTakeStunOff, false, 0, true);
		}
		
		private function onTakeStunOff(e:TimerEvent = null):void 
		{
			_isStunned = false;
			_stunTimer.reset();
			_stunTimer.removeEventListener(TimerEvent.TIMER, onTakeStunOff, false);
			_starsMovie.visible = false;
		}
		
		public function get arrow():MovieClip { return _arrow; }
		
		public function get arrowAdded():Boolean { return _arrowAdded; }
		
		public function set arrowAdded(value:Boolean):void 
		{
			_arrowAdded = value;
		}
		
		public function get bodyMovie():MovieClip { return _bodyMovie; }
		
		public function get isDead():Boolean { return _isDead; }
		
		public function set isDead(value:Boolean):void 
		{
			_isDead = value;
		}
		
		public function get isHaveARound():Boolean { return _isHaveARound; }
		
		public function get model():String { return _model; }
		
		public function get movedToSavingState():Boolean { return _movedToSavingState; }
	}
}