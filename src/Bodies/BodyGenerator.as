package Bodies 
{
	import Bonuses.BonusInfo;
	import Events.BarComplete;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import shark.Shark;
	/**
	 * ...
	 * @author 
	 */
	public class BodyGenerator extends Sprite
	{
		public static const DIFFICULTY_TIMER:int = 60000;
		//public static const DIFFICULTY_DELAY:int = 500;
		public static const Y_COORD_DELAY:int = 70;
		public static const STARTING_BODIES_ADDING_DELAY_MIN:int = 10000;
		public static const STARTING_BODIES_ADDING_DELAY_MAX:int = 32000;
		public static const MAX_BODIES_COUNT:int = 20;
		
		private var _count:int;
		private var _bodiesAddingTimer:Timer = new Timer(STARTING_BODIES_ADDING_DELAY_MIN);
		private var _difficultyTimer:Timer = new Timer(DIFFICULTY_TIMER);
		private var _timeToDiffiChange:Boolean = false;
		
		private var _maxYcoord:int;
		private var _minYcoord:int;
		private var _hero:Hero;
		private var _universe:Universe;
		private var _bodiesLayer:Sprite;
		private var _onlyGirlsMode:Boolean = false;
		public static var bodiesArray:Array = [];
		private var _firstAddedbody:Boolean = true;
		
		public function BodyGenerator()
		{
			Shark.bodiesArray = bodiesArray;
		}
		
		public function Init(lowY:int, highY:int, hero:Hero, universe:Universe):void 
		{
			_firstAddedbody = true;
			_count = 0;
			_universe = universe;
			_hero = hero;
			_bodiesLayer = _universe.bodiesLayer;
			_maxYcoord = highY;
			_minYcoord = lowY;
			_bodiesAddingTimer.start();
			_difficultyTimer.start();
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
			_bodiesAddingTimer.addEventListener(TimerEvent.TIMER, onAddNewBody, false, 0, true);
			_difficultyTimer.addEventListener(TimerEvent.TIMER, onAddNewDiffiLvl, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			_bodiesAddingTimer.start();
			_difficultyTimer.start();
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_bodiesAddingTimer.stop();
			_difficultyTimer.stop();
		}
		
		private function onAddNewDiffiLvl(e:TimerEvent):void 
		{
			if (_minYcoord >= 300)
			{
				_minYcoord -= Y_COORD_DELAY;
			}
			
			if (++_count % 3 == 0)
			{
				_universe.deathsCount--;
			}
			
			if (_count == App.DIFFICULTY_TO_START_ROUNDS) {
				_universe.startRounds();
			} else if (_count == App.DIFFICULTY_TO_START_SHARKS) {
				_universe.startSharks();
			} else if (_count == App.DIFFICULTY_TO_START_ROCKETS) {
				_universe.startRockets();
			} else if (_count == App.DIFFICULTY_TO_START_BONUSES) {
				_universe.startBonuses();
			}
		}
		
		private function onAddNewBody(e:TimerEvent):void 
		{
			var randomDelay:int = App.randomInt(STARTING_BODIES_ADDING_DELAY_MIN, STARTING_BODIES_ADDING_DELAY_MAX);
			_bodiesAddingTimer.reset();
			_bodiesAddingTimer.delay = randomDelay;
			_bodiesAddingTimer.start();
			if (bodiesArray.length <= 20)
			{
				addNewBody();
			}
			
			if (_firstAddedbody)
			{
				_firstAddedbody = false;
				App.gameInterface.tutorial.ShowTutorial(Tutorial.TYPE_SAVE);
			}
		}
		
		private function FindAPlaceForBody():Point
		{
			var randomY:int = App.randomInt(_minYcoord, _maxYcoord);
			var randomX:int = App.randomInt(25, Universe.MAP_WIDTH - 25);
			return new Point(randomX, randomY);
		}
		
		private function addNewBody():void 
		{
			var tmpPoint:Point = new Point();
			var tmpX:int;
			var tmpY:int;
			while (true)
			{
				tmpPoint = FindAPlaceForBody();
				tmpX = tmpPoint.x;
				tmpY = tmpPoint.y;
				if ((tmpX > Universe.ISLAND_X) && (tmpX < (Universe.ISLAND_X + Universe.ISLAND_WIDTH)) && (tmpY > Universe.ISLAND_Y) && (tmpY < (Universe.ISLAND_Y + Universe.ISLAND_HEIGHT)))
				{
					continue;
				}
				else if ((tmpX < (-1)*_universe.x + App.STAGE_WIDTH) && (tmpX > (-1)*_universe.x) && (tmpY < (-1)*_universe.y + App.STAGE_HEIGHT) && (tmpY > (-1)*_universe.y))
				{
					continue;	
				}
				else
				{
					break;
				}
			}
			
			var tmpBody:Body = App.pools.getPoolObject(Body.NAME);
			
			tmpBody.x = tmpX;
			//tmpBody.x = 400;
			tmpBody.y = tmpY;
			//tmpBody.y = 2200;
			
			_bodiesLayer.addChild(tmpBody);
			
			tmpBody.Init(_bodiesLayer, _hero, this, _onlyGirlsMode);
			bodiesArray.push(tmpBody);
		}
		
		public function Destroy():void 
		{
			if (_onlyGirlsMode)
			{
				_onlyGirlsMode = true;
			}
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			_bodiesAddingTimer.removeEventListener(TimerEvent.TIMER, onAddNewBody, false);
			_difficultyTimer.removeEventListener(TimerEvent.TIMER, onAddNewDiffiLvl, false);
			_bodiesAddingTimer.reset();
			_difficultyTimer.reset();
			dispatchEvent(new Destroying(Destroying.DESTROY, true, false));
			bodiesArray.length = 0;
		}
		
		public function SetOnlyGirlsMode():void 
		{
			if (!_onlyGirlsMode)
			{
				_onlyGirlsMode = true;
				App.gameInterface.barControl.addNewBonus(BonusInfo.TYPE_ONLY_GIRLS, BonusInfo.ONLY_GIRLS_TIME);
				App.gameInterface.barControl.addEventListener(BarComplete.BAR_COMPLETE, UnSetOnlyGirlsMode, false, 0, true);
			}
			else
			{
				App.gameInterface.barControl.resetBonusTimer(BonusInfo.TYPE_ONLY_GIRLS);
			}
		}
		
		private function UnSetOnlyGirlsMode(e:BarComplete):void 
		{
			if (e.bonusType == BonusInfo.TYPE_ONLY_GIRLS)
			{
				App.gameInterface.barControl.removeEventListener(BarComplete.BAR_COMPLETE, UnSetOnlyGirlsMode, false);
				_onlyGirlsMode = false;
			}
		}
	}

}