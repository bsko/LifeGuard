package  
{
	import adobe.utils.ProductManager;
	import Bodies.Body;
	import Bodies.BodyGenerator;
	import Bonuses.BonusGenerator;
	import Bonuses.BonusInfo;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2DBodies.Ball;
	import Box2DBodies.BlackRect;
	import Box2DBodies.CircleBody;
	import Box2DBodies.ReverseActor;
	import Box2DBodies.SensorToSwim;
	import Box2DBodies.SensorToWalk;
	import Box2DBodies.SquareBody;
	import Events.Abilities;
	import Events.BarComplete;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import Rockets.RocketsGenerator;
	import Rounds.FlyingRound;
	import Rounds.RoundsGenerator;
	import shark.Shark;
	import shark.SharkGenerator;
	import Waves.WaveGenreator;
	/**
	 * ...
	 * @author 
	 */
	public class Universe extends Sprite
	{
		public static const HERO_STATE_STANDING:int = 101;
		public static const HERO_STATE_RUNNING:int = 102;
		public static const HERO_STATE_SWIMING:int = 103;
		public static const HERO_STATE_STAND_SWIMING:int = 104;
		
		public static const MODE_STANDART:int = 201;
		public static const MODE_PISTOL:int = 202;
		public static const MODE_ROUND:int = 203;
		
		public static var ISLAND_WIDTH:int;
		public static var ISLAND_HEIGHT:int;
		public static var ISLAND_X:int;
		public static var ISLAND_Y:int;
		
		public static const TILE_SIZE:int = 200;
		public static const MAP_WIDTH:int = 2000;
		public static const MAP_HEIGHT:int = 3000;
		public static const CELLS_WIDTH:int = MAP_WIDTH / TILE_SIZE;
		public static const CELLS_HEIGHT:int = MAP_HEIGHT / TILE_SIZE;
		public static const BUYOKS_Y:int = 100;
		public static const BUYOKS_X_DELAY:int = 100;
		public static const SAND_ROW:int = 2;
		public static const SAND_START:int = MAP_HEIGHT - SAND_ROW * TILE_SIZE;
		public static const FIRST_ADDING_BODIES_POINT:int = 2000;
		
		private var _tilesSprite:MovieClip = new MovieClip();
		private var _backgroundSprite:MovieClip = new MovieClip();
		private var _buyokSprite:MovieClip = new MovieClip();
		private var _downHeroSprite:MovieClip = new MovieClip();
		private var _ballsSprite:MovieClip = new MovieClip();
		private var _bonusesLayer:MovieClip = new MovieClip();
		private var _bodiesLayer:MovieClip = new MovieClip();
		private var _sharksLayer:MovieClip = new MovieClip();
		private var _heroSprite:MovieClip = new MovieClip();
		private var _upperHeroSprite:MovieClip = new MovieClip();
		private var _bonusesSprite:Sprite = new Sprite();
		private var _hero:Hero;
		private var _camera:Camera;
		private var _waveGenerator:WaveGenreator;
		private var _bodiesGenerator:BodyGenerator = new BodyGenerator();
		private var _sharksGenerator:SharkGenerator = new SharkGenerator();
		private var _bonusesGenerator:BonusGenerator = new BonusGenerator();
		private var _roundGenerator:RoundsGenerator = new RoundsGenerator();
		private var _rocketGenerator:RocketsGenerator = new RocketsGenerator();
		private var _heroState:int;
		private var _startPoint:Point;
		private var _destinationPoint:Point;
		private var _distance:Number;
		private var _isReachedMapSize:Boolean;
		private var _buyoksArray:Array = [];
		private var _checkpoint:MovieClip = new CheckpointMovie();
		private var _currentMode:int;
		private var _roundsCount:int;
		private var _flaresCount:int;
		private var _whistleAnim:MovieClip = new whistle_animation();
		private var _score:int;
		private var tmpBeach:MovieClip = new Beach_movie();
		private var tmpUpBeach:MovieClip = new Beach_up_movie();
		private var _hero_timer:Timer = new Timer(250);
		private var _prevMode:int;
		private var debugSprite:Sprite = new Sprite();
		private var _deathsCount:int;
		private var _generatingZonesArray:Array = [];
		
		private var _eventListenersArray:Array = [];
		private var _nonStopRocketsMode:Boolean = false;
		private var _nonStopRoundsMode:Boolean = false;
		
		private var _multiplier:Number = 1;
		private var _saved_bodies_count:int;
		
		private var _sharksON:Boolean = false;
		private var _rocketsON:Boolean = false;
		private var _roundsON:Boolean = false;
		private var _bonusesON:Boolean = false;
		
		public function Universe() 
		{
			fillTilesSprite();
			addChild(_backgroundSprite);
			addChild(_buyokSprite);
			addChild(_downHeroSprite);
			addChild(_bonusesLayer);
			addChild(_bodiesLayer);
			addChild(_ballsSprite);
			addChild(_sharksLayer);
			addChild(_heroSprite);
			addChild(_upperHeroSprite);
			addChild(_bonusesSprite);
			_upperHeroSprite.addChild(_whistleAnim);
			_whistleAnim.visible = false;
			Body.universe = this;
		}
		
		public function Init():void 
		{
			deathsCount = 0;
			
			_saved_bodies_count = 0;
			_score = 0;
			InitHero();
			InitCamera();
			InitWavegenerator();
			InitBuyoks();
			_bodiesGenerator.Init(FIRST_ADDING_BODIES_POINT, SAND_START - 200, _hero, this);
			App.world_step = 1/App.WORLD_SCALE;
			addEventListeners();
			_currentMode = MODE_STANDART;
			flaresCount = 5;
			roundsCount = 5;
			startParser();
			//debugDraw();
			
			
			App.gameInterface.tutorial.ShowTutorial(Tutorial.TYPE_MOVING);
			
			/*startBonuses();
			startRockets();
			startSharks();
			startRounds();*/
		}
		
		private function onStopBonus(e:BarComplete):void 
		{
			switch(e.bonusType)
			{
				case BonusInfo.TYPE_NON_STOP_ROCKETS:
				_nonStopRocketsMode = false;
				App.gameInterface.changePistolsCount(flaresCount);
				break;
				case BonusInfo.TYPE_NON_STOP_ROUNDS:
				_nonStopRoundsMode = false;
				App.gameInterface.changeRoundsCount(roundsCount);
				break;
				case BonusInfo.TYPE_HERO_SPEED_UP:
				hero.heroSpeedUpMode = false;
				if (!hero.heroSpeedDownMode)
				{
					hero.speed = Hero.DEFAULT_SPEED;
					if (hero.isMoving)
					{
						var tmp:b2Vec2 = hero.heroBody.GetLinearVelocity();
						tmp.x = tmp.x / Hero.UPPED_SPEED * Hero.DEFAULT_SPEED;
						tmp.y = tmp.y / Hero.UPPED_SPEED * Hero.DEFAULT_SPEED;
						hero.heroBody.SetLinearVelocity(tmp);
					}
				}
				else
				{
					hero.speed = Hero.REDUCED_SPEED;
					if (hero.isMoving)
					{
						tmp = hero.heroBody.GetLinearVelocity();
						tmp.x = tmp.x / Hero.DEFAULT_SPEED * Hero.REDUCED_SPEED;
						tmp.y = tmp.y / Hero.DEFAULT_SPEED * Hero.REDUCED_SPEED;
						hero.heroBody.SetLinearVelocity(tmp);
					}
				}
				break;
				case BonusInfo.TYPE_HERO_SPEED_DOWN:
				hero.heroSpeedDownMode = false;
				if (!hero.heroSpeedUpMode)
				{
					hero.speed = Hero.DEFAULT_SPEED;
					if (hero.isMoving)
					{
						tmp = hero.heroBody.GetLinearVelocity();
						tmp.x = tmp.x / Hero.REDUCED_SPEED * Hero.DEFAULT_SPEED;
						tmp.y = tmp.y / Hero.REDUCED_SPEED * Hero.DEFAULT_SPEED;
						hero.heroBody.SetLinearVelocity(tmp);
					}
				}
				else
				{
					hero.speed = Hero.DEFAULT_SPEED;
					if (hero.isMoving)
					{
						tmp = hero.heroBody.GetLinearVelocity();
						tmp.x = tmp.x / Hero.UPPED_SPEED * Hero.DEFAULT_SPEED;
						tmp.y = tmp.y / Hero.UPPED_SPEED * Hero.DEFAULT_SPEED;
						hero.heroBody.SetLinearVelocity(tmp);
					}
				}
				break;
				case BonusInfo.TYPE_NON_EATING_SHARKS:
				_sharksGenerator.stopEating = false;
				break;
				case BonusInfo.TYPE_SCORE_MULTIPL:
				multiplier = 1;
				break;
			}
		}
		
		private function onUpdateWorld(e:Event):void 
		{
			App.world.Step(App.world_step, 10, 10);
			App.world.ClearForces();
			//App.world.DrawDebugData();
		}
		
		private function debugDraw():void 
		{
			var debugDrawVar:b2DebugDraw = new b2DebugDraw();
			addChild(debugSprite);
			debugDrawVar.SetFillAlpha(0.5);
			debugDrawVar.SetSprite(debugSprite);
			debugDrawVar.SetDrawScale(App.WORLD_SCALE);
			debugDrawVar.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
			App.world.SetDebugDraw(debugDrawVar);
		}
		
		private function startParser():void 
		{
			var length:int = tmpBeach.numChildren;
			var tmpMovie:MovieClip;
			var tmpDO:DisplayObject;
			
			for (var i:int = 0; i < length; i++)
			{
				tmpDO = tmpBeach.getChildAt(i);
				if (tmpDO is box2dpoebotina)
				{
					tmpMovie = tmpDO as MovieClip;
					var tmpSquareBody:BlackRect = App.pools.getPoolObject(BlackRect.NAME);
					var tmpPoint:Point = new Point(tmpMovie.x, tmpMovie.y + tmpBeach.y);
					tmpSquareBody.Init(tmpMovie, tmpPoint);
					tmpMovie.alpha = 0;
				}
				else if (tmpDO is box2dround)
				{
					tmpMovie = tmpDO as MovieClip;
					var tmpCircleBody:Ball = App.pools.getPoolObject(Ball.NAME);
					tmpPoint = new Point(tmpMovie.x, tmpMovie.y + tmpBeach.y);
					tmpCircleBody.Init(tmpMovie, tmpPoint);
					_ballsSprite.addChild(tmpCircleBody);
				}
				else if (tmpDO is Box2DSensorToSwim)
				{
					tmpMovie = tmpDO as MovieClip;
					var tmpSwimSensor:SensorToSwim = App.pools.getPoolObject(SensorToSwim.NAME);
					tmpPoint = new Point(tmpMovie.x, tmpMovie.y + tmpBeach.y);
					tmpSwimSensor.Init(tmpMovie, tmpPoint);
				}
				else if (tmpDO is Box2DSensorToWalk)
				{
					tmpMovie = tmpDO as MovieClip;
					var tmpWalkSensor:SensorToWalk = App.pools.getPoolObject(SensorToWalk.NAME);
					tmpPoint = new Point(tmpMovie.x, tmpMovie.y + tmpBeach.y);
					tmpWalkSensor.Init(tmpMovie, tmpPoint);
				}
				else if (tmpDO is ZoneForObjects)
				{
					var tmpSprite:Sprite = tmpDO as Sprite;
					tmpSprite.visible = false;
					_generatingZonesArray.push(tmpSprite);
				}
				else if (tmpDO is IslandZone)
				{
					tmpSprite = tmpDO as Sprite;
					tmpSprite.visible = false;
					ISLAND_X = tmpSprite.x;
					ISLAND_Y = tmpSprite.y + 2000;
					ISLAND_WIDTH = tmpSprite.width;
					ISLAND_HEIGHT = tmpSprite.height;
				}
			}
			
			_rocketGenerator.zonesArray = _generatingZonesArray;
			_roundGenerator.zonesArray = _generatingZonesArray;
		}
		
		private function onUpdateFocus(e:Event):void 
		{
			App.stage.focus = App.stage;
			App.gameInterface.updateScore(score);
		}
		
		private function onKeyboardEvent(e:KeyboardEvent):void 
		{
			if (e.keyCode == 32)
			{
				if (_currentMode != MODE_STANDART)
				{
					App.gameInterface.HidePressSpace();
					_currentMode = MODE_STANDART;
					_hero.state = _prevMode;
					_hero.updateState();
				}
			}
			else if (e.keyCode == 49)
			{
				App.gameInterface.onWistleEvent();
			}
			else if (e.keyCode == 50)
			{
				App.gameInterface.onPistolEvent();
			}
			else if (e.keyCode == 51)
			{
				App.gameInterface.onRoundEvent();
			}
			else if (e.keyCode == Keyboard.ESCAPE || e.keyCode == 80)
			{
				App.gameInterface.onMenuEvent();
			}
		}
		
		private function InitBuyoks():void 
		{
			_buyoksArray.length = 0;
			var tmpX:int = BUYOKS_X_DELAY;
			while (tmpX < MAP_WIDTH)
			{
				var tmpBuyok:Buyok = App.pools.getPoolObject(Buyok.NAME);
				tmpBuyok.x = tmpX + App.randomInt(-12, 12);
				tmpBuyok.y = BUYOKS_Y + App.randomInt( -12, 12);
				tmpBuyok.Init();
				_buyokSprite.addChild(tmpBuyok);
				_buyoksArray.push(tmpBuyok);
				tmpX += BUYOKS_X_DELAY;
			}
		}
		
		private function InitWavegenerator():void 
		{
			_waveGenerator.Init(_hero, backgroundSprite);
		}
		
		private function InitCamera():void 
		{
			_camera = new Camera();
			_camera.Init(this);
		}
		
		private function addEventListeners():void 
		{
			App.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateFocus, false, 0, true);
			addEventListener(MouseEvent.MOUSE_MOVE, onUpdateAngle, false, 0, true);
			addEventListener(MouseEvent.CLICK, onClickEvent, false, 0, true);
			App.gameInterface.addEventListener(Abilities.PISTOL, onPistolMode, false, 0, true);
			App.gameInterface.addEventListener(Abilities.WISTLE, onWistleMode, false, 0, true);
			App.gameInterface.addEventListener(Abilities.ROUND, onRoundMode, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateWorld, false, 0, true);
			App.gameInterface.barControl.addEventListener(BarComplete.BAR_COMPLETE, onStopBonus, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			while(_eventListenersArray.length != 0)
			{
				var tmpObject:Object = _eventListenersArray.shift();
				tmpObject.target.addEventListener(tmpObject.type, tmpObject.handler, false, 0, true);
			}
			
			_hero_timer.start();
			tmpBeach.play();
			App.world_step = 1 / App.WORLD_SCALE;
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_eventListenersArray.length = 0;
			
			if (hero.isMoving)
			{
				var tmpObject1:Object = new Object();
				tmpObject1.target = this;
				tmpObject1.type = Event.ENTER_FRAME;
				tmpObject1.handler = onUpdateHeroPosition;
				removeEventListener(Event.ENTER_FRAME, onUpdateHeroPosition, false);
				_eventListenersArray.push(tmpObject1);
				
				_hero_timer.stop();
			}
			
			tmpBeach.stop();
			App.world_step = 0;
		}
		
		private function onRoundMode(e:Abilities = null):void 
		{
			if (_roundsCount == 0 && nonStopRoundsMode == false)
			{
				return;
			}
			
			if (_currentMode != MODE_ROUND)
			{
				StopHero();
				_currentMode = MODE_ROUND;
				if (_hero.state != Hero.HERO_IS_SHOOTING_ROCKET)
				{
					_prevMode = _hero.state;
				}
				_hero.state = Hero.HERO_IS_SHOOTING_ROUND;
				_hero.updateState();
				App.gameInterface.ShowPressSpace();
				_checkpoint.visible = false;
			}
			else
			{
				_hero.state = _prevMode;
				_hero.updateState();
				_currentMode = MODE_STANDART;
				App.gameInterface.HidePressSpace();
			}
		}
		
		private function onWistleMode(e:Abilities):void 
		{
			App.soundManager.playSound("whistleSnd");
			var length:int = BodyGenerator.bodiesArray.length;
			var tmpBody:Body;
			var tmpBodyPoint:Point;
			for (var i:int = 0; i < length; i++)
			{
				tmpBody = BodyGenerator.bodiesArray[i];
				tmpBodyPoint = this.localToGlobal(new Point(tmpBody.x, tmpBody.y));
				if (tmpBodyPoint.x < App.STAGE_WIDTH && tmpBodyPoint.x > 0 && tmpBodyPoint.y > 0 && tmpBodyPoint.y < App.STAGE_HEIGHT)
				{
					tmpBody.resetDrawningPhase();
				}
			}
			_whistleAnim.x = _hero.x;
			_whistleAnim.y = _hero.y;
			_whistleAnim.gotoAndPlay(1);
			_whistleAnim.visible = true;
		}
		
		private function onPistolMode(e:Abilities = null):void 
		{
			if (_flaresCount == 0 && nonStopRocketsMode == false)
			{
				return;
			}
			if (_currentMode != MODE_PISTOL)
			{
				StopHero();
				_currentMode = MODE_PISTOL;
				if (_hero.state != Hero.HERO_IS_SHOOTING_ROUND)
				{
					_prevMode = _hero.state;
				}
				_hero.state = Hero.HERO_IS_SHOOTING_ROCKET;
				_hero.updateState();
				App.gameInterface.ShowPressSpace();
				_checkpoint.visible = false;
			}
			else
			{
				_hero.state = _prevMode;
				_hero.updateState();
				_currentMode = MODE_STANDART;
				App.gameInterface.HidePressSpace();
			}
		}
		
		private function onClickEvent(e:MouseEvent):void 
		{
			_destinationPoint = this.globalToLocal(new Point(e.stageX, e.stageY));
			if (_currentMode == MODE_STANDART)
			{
				if (_destinationPoint.y < Buyok.BYUOKS_LINE_Y)
				{
					_destinationPoint.y = Buyok.BYUOKS_LINE_Y;
				}
				_checkpoint.x = _destinationPoint.x;
				_checkpoint.y = _destinationPoint.y;
				_checkpoint.visible = true;
				removeEventListener(MouseEvent.MOUSE_MOVE, onUpdateAngle, false);
				
				updateDestinationPoint();
				if (!hero.isMoving)
				{
					hero.isMoving = true;
					hero.updateState();
				}
			}
			else if (_currentMode == MODE_ROUND)
			{
				if (!nonStopRoundsMode)
				{
					roundsCount--;
				}
				var tmpFlyingRound:FlyingRound = App.pools.getPoolObject(FlyingRound.NAME);
				tmpFlyingRound.Init(_hero, _destinationPoint, _upperHeroSprite);
				
				App.gameInterface.HidePressSpace();
				_currentMode = MODE_STANDART;
				_hero.state = _prevMode;
				_hero.updateState();
				if (!nonStopRoundsMode)
				{
					App.gameInterface.StartRoundCooldown();
				}
			}
			else if (_currentMode == MODE_PISTOL)
			{
				if (!nonStopRocketsMode)
				{
					flaresCount--;
				}
				
				var tmpFlyingBullet:FlyingBullet = App.pools.getPoolObject(FlyingBullet.NAME);
				tmpFlyingBullet.Init(_hero, _destinationPoint, _upperHeroSprite);
				App.soundManager.playSound("rocketSnd");
				App.gameInterface.HidePressSpace();
				_currentMode = MODE_STANDART;
				_hero.state = _prevMode;
				_hero.updateState();
				if (!nonStopRocketsMode)
				{
					App.gameInterface.StartPistolCooldown();
				}
			}
		}
		
		private function updateDestinationPoint():void 
		{
			_startPoint = new Point(_hero.x, _hero.y);
			hero.heroBody.SetLinearVelocity(new b2Vec2(0, 0));
			
			_distance = Point.distance(_destinationPoint, _startPoint);
			if (_distance > 2)
			{
				var width:Number = _destinationPoint.x - _startPoint.x;
				var height:Number = _destinationPoint.y - _startPoint.y;
				
				width = width / _distance;
				height = height / _distance;
				width *= (hero.speed + hero.bonus_speed);
				height *= (hero.speed + hero.bonus_speed);
				
				hero.heroBody.SetLinearVelocity(new b2Vec2(width, height));
				
				_hero.rotation = App.angleFinding(_startPoint, _destinationPoint);
				_hero_timer.start();
				_hero_timer.addEventListener(TimerEvent.TIMER, onTimerEvent, false, 0, true);
				addEventListener(Event.ENTER_FRAME, onUpdateHeroPosition, false, 0, true);
			}
			else
			{
				_hero.isMoving = false;
				_hero.updateState();
			}
		}
		
		public function StopHero():void 
		{
			hero.heroBody.SetLinearVelocity(new b2Vec2(0, 0));
			_destinationPoint = null;
			removeEventListener(Event.ENTER_FRAME, onUpdateHeroPosition, false);
			_hero_timer.removeEventListener(TimerEvent.TIMER, onTimerEvent, false);
			_hero_timer.reset();
			addEventListener(MouseEvent.MOUSE_MOVE, onUpdateAngle, false, 0, true);
			hero.isMoving = false;
			hero.updateState();
		}
		
		private function onTimerEvent(e:TimerEvent):void 
		{
			_startPoint = new Point(_hero.x, _hero.y);
			hero.heroBody.SetLinearVelocity(new b2Vec2(0, 0));
			
			_distance = Point.distance(_destinationPoint, _startPoint);
			var width:Number = _destinationPoint.x - _startPoint.x;
			var height:Number = _destinationPoint.y - _startPoint.y;
			
			width = width / _distance;
			height = height / _distance;
			width *= (hero.speed + hero.bonus_speed);
			height *= (hero.speed + hero.bonus_speed);
			
			hero.heroBody.SetLinearVelocity(new b2Vec2(width, height));
			
			_hero.rotation = App.angleFinding(_startPoint, _destinationPoint);
		}
		
		private function onUpdateHeroPosition(e:Event):void 
		{
			var _currentPoint:Point = new Point(_hero.x, _hero.y);
			var distance:Number = Point.distance(_destinationPoint, _currentPoint);
			if (distance < 20) { _checkpoint.visible = false; }
			if (distance < 5)
			{
				StopHero();
			}
		}
		
		private function removeEventListeners():void 
		{
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateHeroPosition, false);
			App.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateFocus, false);
			removeEventListener(MouseEvent.MOUSE_MOVE, onUpdateAngle, false);
			removeEventListener(MouseEvent.CLICK, onClickEvent, false);
			App.gameInterface.removeEventListener(Abilities.PISTOL, onPistolMode, false);
			App.gameInterface.removeEventListener(Abilities.WISTLE, onWistleMode, false);
			App.gameInterface.removeEventListener(Abilities.ROUND, onRoundMode, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateWorld, false);
			App.gameInterface.barControl.removeEventListener(BarComplete.BAR_COMPLETE, onStopBonus, false);
		}
		
		private function onUpdateAngle(e:MouseEvent):void 
		{
			var tmpPoint:Point = backgroundSprite.globalToLocal(new Point(e.stageX, e.stageY));
			_hero.rotation = App.angleFinding(new Point(_hero.x, _hero.y), tmpPoint);
		}
		
		private function InitHero():void 
		{
			_heroSprite.addChild(_checkpoint);
			_checkpoint.visible = false;
			_hero = new Hero();
			_hero.x = App.STAGE_HALF_WIDTH;
			_hero.y = App.STAGE_HALF_HEIGHT;
			_hero.Init();
			_heroSprite.addChild(_hero);
			
		}
		
		private function fillTilesSprite():void 
		{
			var tmpSandSprite:Sprite;
			for (var j:int = 0; j < CELLS_HEIGHT; j++)
			{
				for (var i:int = 0; i < CELLS_WIDTH; i++)
				{
					if (j < SAND_ROW)
					{
						tmpSandSprite = new SandTile();
						tmpSandSprite.x = i * TILE_SIZE;
						tmpSandSprite.y = MAP_HEIGHT - TILE_SIZE * (j + 1);
						_tilesSprite.addChild(tmpSandSprite);
					}
					else
					{
						tmpSandSprite = new FarWaterTile();
						tmpSandSprite.x = i * TILE_SIZE;
						tmpSandSprite.y = MAP_HEIGHT - TILE_SIZE * (j + 1);
						_tilesSprite.addChild(tmpSandSprite);
					}
				}
			}
			_backgroundSprite.addChild(_tilesSprite);
			_backgroundSprite.addChild(tmpBeach);
			
			tmpBeach.x = 0;
			tmpBeach.y = 2000;
			
			_upperHeroSprite.addChild(tmpUpBeach);
			tmpUpBeach.x = 0;
			tmpUpBeach.y = 2000;
		}
		
		public function Destroy():void 
		{
			_multiplier = 1;
			_eventListenersArray.length = 0;
			_hero_timer.removeEventListener(TimerEvent.TIMER, onTimerEvent, false);
			_hero_timer.reset();
			_destinationPoint = null;
			dispatchEvent(new Destroying(Destroying.DESTROY, true, false));
			App.world_step = 0;
			/*while (App.world.GetBodyCount() != 0)
			{
				App.world.DestroyBody(App.world.GetBodyList());
			}*/
			while (_ballsSprite.numChildren != 0)
			{
				_ballsSprite.removeChildAt(0);
			}
			_hero.Destroy();
			_heroSprite.removeChild(_checkpoint);
			_heroSprite.removeChild(_hero);
			
			_waveGenerator.Destroy();
			_bodiesGenerator.Destroy();
			
			if (_sharksON) { _sharksGenerator.Destroy(); _sharksON = false; }
			if (_bonusesON) { _bonusesGenerator.Destroy(); _bonusesON = false; }
			if (_roundsON) { _roundGenerator.Destroy(); _roundsON = false; }
			if (_rocketsON) { _rocketGenerator.Destroy(); _rocketsON = false; }
			_camera.Destroy();
			_generatingZonesArray.length = 0;
			removeEventListeners();
		}
		
		public function onlyGirlsMode():void 
		{
			_bodiesGenerator.SetOnlyGirlsMode();
		}
		
		public function nonStopRocketsModeFunc():void 
		{
			if (!_nonStopRocketsMode)
			{
				_nonStopRocketsMode = true;
				App.gameInterface.barControl.addNewBonus(BonusInfo.TYPE_NON_STOP_ROCKETS, BonusInfo.ROCKETS_TIME);
				App.gameInterface.changePistolsCount(99);
			}
			else
			{
				App.gameInterface.barControl.resetBonusTimer(BonusInfo.TYPE_NON_STOP_ROCKETS);
			}
		}
		
		public function nonStopRoundsModeFunc():void 
		{
			if (!_nonStopRoundsMode)
			{
				_nonStopRoundsMode = true;
				App.gameInterface.barControl.addNewBonus(BonusInfo.TYPE_NON_STOP_ROUNDS, BonusInfo.ROUNDS_TIME);
				App.gameInterface.changeRoundsCount(99);
			}
			else
			{
				App.gameInterface.barControl.resetBonusTimer(BonusInfo.TYPE_NON_STOP_ROUNDS);
			}
		}
		
		public function giveThemRounds():void 
		{
			var length:int = BodyGenerator.bodiesArray.length;
			var tmpBody:Body;
			for (var i:int = 0; i < length; i++)
			{
				tmpBody = BodyGenerator.bodiesArray[i];
				if (!tmpBody.isDead && !tmpBody.movedToSavingState)
				{
					if (tmpBody.x > hero.x - 320 && tmpBody.x < hero.x + 320)
					{
						if (tmpBody.y > hero.y - 240 && tmpBody.y < hero.y + 240)
						{
							tmpBody.takeARound();
						}
					}
				}
			}
		}
		
		public function giveSpeedToHero():void 
		{
			if (!hero.heroSpeedUpMode)
			{
				hero.heroSpeedUpMode = true;
				App.gameInterface.barControl.addNewBonus(BonusInfo.TYPE_HERO_SPEED_UP, BonusInfo.SPEEDUP_TIME);
				if (!hero.heroSpeedDownMode)
				{
					hero.speed = Hero.UPPED_SPEED;
					if (hero.isMoving)
					{
						var tmp:b2Vec2 = hero.heroBody.GetLinearVelocity();
						tmp.x = tmp.x / Hero.DEFAULT_SPEED * Hero.UPPED_SPEED;
						tmp.y = tmp.y / Hero.DEFAULT_SPEED * Hero.UPPED_SPEED;
						hero.heroBody.SetLinearVelocity(tmp);
					}
				}
				else
				{
					hero.speed = Hero.DEFAULT_SPEED;
					if (hero.isMoving)
					{
						tmp = hero.heroBody.GetLinearVelocity();
						tmp.x = tmp.x / Hero.REDUCED_SPEED * Hero.DEFAULT_SPEED;
						tmp.y = tmp.y / Hero.REDUCED_SPEED * Hero.DEFAULT_SPEED;
						hero.heroBody.SetLinearVelocity(tmp);
					}
				}
			}
			else
			{
				App.gameInterface.barControl.resetBonusTimer(BonusInfo.TYPE_HERO_SPEED_UP);
			}
		}
		
		public function killSharks():void 
		{
			var length:int = SharkGenerator.sharksArray.length;
			var tmpShark:Shark;
			for (var i:int = 0; i < length; i++)
			{
				tmpShark = SharkGenerator.sharksArray[i];
				if (tmpShark.x > hero.x - 320 && tmpShark.x < hero.x + 320)
				{
					if (tmpShark.y > hero.y - 240 && tmpShark.y < hero.y + 240)
					{
						tmpShark.Destroy();
						length--;
						i--;
					}
				}
			}
		}
		
		public function giveDownSpeedToHero():void 
		{
			if (!hero.heroSpeedDownMode)
			{
				hero.heroSpeedDownMode = true;
				App.gameInterface.barControl.addNewBonus(BonusInfo.TYPE_HERO_SPEED_DOWN, BonusInfo.SPEEDDOWN_TIME);
				if (!hero.heroSpeedUpMode)
				{
					hero.speed = Hero.REDUCED_SPEED;
					if (hero.isMoving)
					{
						var tmp:b2Vec2 = hero.heroBody.GetLinearVelocity();
						tmp.x = tmp.x / Hero.DEFAULT_SPEED * Hero.REDUCED_SPEED;
						tmp.y = tmp.y / Hero.DEFAULT_SPEED * Hero.REDUCED_SPEED;
						hero.heroBody.SetLinearVelocity(tmp);
					}
				}
				else
				{
					hero.speed = Hero.DEFAULT_SPEED;
					if (hero.isMoving)
					{
						tmp = hero.heroBody.GetLinearVelocity();
						tmp.x = tmp.x / Hero.UPPED_SPEED * Hero.DEFAULT_SPEED;
						tmp.y = tmp.y / Hero.UPPED_SPEED * Hero.DEFAULT_SPEED;
						hero.heroBody.SetLinearVelocity(tmp);
					}
				}
			}
			else
			{
				App.gameInterface.barControl.resetBonusTimer(BonusInfo.TYPE_HERO_SPEED_DOWN);
			}
		}
		
		public function nonEatingSharks():void 
		{
			if (!_sharksGenerator.stopEating)
			{
				_sharksGenerator.stopEating = true;
				App.gameInterface.barControl.addNewBonus(BonusInfo.TYPE_NON_EATING_SHARKS, BonusInfo.NON_EATING_SHARKS_TIME);
			}
			else
			{
				App.gameInterface.barControl.resetBonusTimer(BonusInfo.TYPE_NON_EATING_SHARKS);
			}
		}
		
		public function updateMultiplier(arg1:Boolean):void 
		{
			if (arg1)
			{
				if (multiplier == 1)
				{
					multiplier += 1;
					App.gameInterface.barControl.addNewBonus(BonusInfo.TYPE_SCORE_MULTIPL, BonusInfo.SCORE_MULTIPLIER_TIME);
					App.gameInterface.barControl.updateMultiplier(multiplier);
				}
				else
				{
					multiplier++;
					App.gameInterface.barControl.updateMultiplier(multiplier);
					App.gameInterface.barControl.resetBonusTimer(BonusInfo.TYPE_SCORE_MULTIPL);
				}
			}
			else
			{
				if (multiplier == 1)
				{
					return;
				}
				else if (multiplier == 2)
				{
					App.gameInterface.barControl.removeBar();
				}
				else if (multiplier > 2)
				{
					multiplier--;
					App.gameInterface.barControl.updateMultiplier(multiplier);
					App.gameInterface.barControl.resetBonusTimer(BonusInfo.TYPE_SCORE_MULTIPL);
				}
			}
		}
		
		public function startRounds():void 
		{
			_roundGenerator.Init(this);
			_roundsON = true;
			App.gameInterface.tutorial.ShowTutorial(Tutorial.TYPE_ROUNDS);
		}
		
		public function startRockets():void 
		{
			_rocketGenerator.Init(this);
			_rocketsON = true;
			
			App.gameInterface.tutorial.ShowTutorial(Tutorial.TYPE_ROCKET);
		}
		
		public function startSharks():void 
		{
			_sharksGenerator.Init(this);
			_sharksON = true;
		}
		
		public function startBonuses():void 
		{
			_bonusesGenerator.Init(this);
			_bonusesON = true;
		}
		
		public function get backgroundSprite():Sprite { return _backgroundSprite; }
		
		public function get hero():Hero { return _hero; }
		
		public function get waveGenerator():WaveGenreator { return _waveGenerator; }
		
		public function set waveGenerator(value:WaveGenreator):void 
		{
			_waveGenerator = value;
		}
		
		public function get bodiesLayer():Sprite { return _bodiesLayer; }
		
		public function get sharksLayer():Sprite { return _sharksLayer; }
		
		public function get bonusesLayer():Sprite { return _bonusesLayer; }
		
		public function get downHeroSprite():Sprite { return _downHeroSprite; }
		
		public function get roundsCount():int { return _roundsCount; }
		
		public function set roundsCount(value:int):void 
		{
			if (value < 0) { _roundsCount = 0; }
			else {_roundsCount = value; }
			if (!_nonStopRoundsMode)
			{
				App.gameInterface.changeRoundsCount(value);
			}
		}
		
		public function get flaresCount():int { return _flaresCount; }
		
		public function set flaresCount(value:int):void 
		{
			if (value < 0) { _flaresCount = 0; }
			else {_flaresCount = value; }
			if (!_nonStopRocketsMode)
			{
				App.gameInterface.changePistolsCount(value);
			}
		}
		
		public function get score():int { return _score; }
		
		public function set score(value:int):void 
		{
			_score = value;
		}
		
		public function get generatingZonesArray():Array { return _generatingZonesArray; }
		
		public function set generatingZonesArray(value:Array):void 
		{
			_generatingZonesArray = value;
		}
		
		public function get nonStopRoundsMode():Boolean { return _nonStopRoundsMode; }
		
		public function get nonStopRocketsMode():Boolean { return _nonStopRocketsMode; }
		
		public function get multiplier():Number { return _multiplier; }
		
		public function set multiplier(value:Number):void 
		{
			if (value > 9)
			{
				_multiplier = 9
			}
			if (value <= 0)
			{
				_multiplier = 1;
			}
			else
			{
				_multiplier = value;
			}
		}
		
		public function get saved_bodies_count():int { return _saved_bodies_count; }
		
		public function set saved_bodies_count(value:int):void 
		{
			_saved_bodies_count = value;
		}
		
		public function get bonusesSprite():Sprite { return _bonusesSprite; }
		
		public function get deathsCount():int { return _deathsCount; }
		
		public function set deathsCount(value:int):void 
		{
			_deathsCount = value;
			if (_deathsCount == App.MAX_DEATHS_COUNT)
			{
				App.gameInterface.endLevel();
			}
			else
			{
				if (deathsCount < 0)
				{
					_deathsCount = 0;
				}
				App.gameInterface.SetDeathsCount(_deathsCount);
			}
		}
		
	}
}