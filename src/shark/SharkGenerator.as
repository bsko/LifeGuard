package shark 
{
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class SharkGenerator extends Sprite
	{
		public static const NUMBER_OF_SHARKS:int = 10;
		public static const LOW_END:int = 100;
		public static const HIGH_END:int = 1900;
		public static const ADDING_DELAY:int = 30000;
		//public static const ADDING_DELAY:int = 1000;
		
		private var _low_end:int = LOW_END;
		private var _high_end:int = HIGH_END;
		private var _universe:Universe;
		private var _layer:Sprite;
		public static var sharksArray:Array = [];
		public var stopEating:Boolean = false;
		private var _hero:Hero;
		private var _addingTimer:Timer = new Timer(ADDING_DELAY);
		
		public function Init(universe:Universe):void 
		{
			_universe = universe;
			_hero = _universe.hero;
			_layer = _universe.sharksLayer;
			_addingTimer.start();
			_addingTimer.addEventListener(TimerEvent.TIMER, onGenerateNewShark, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
			Generate();
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			_addingTimer.start();
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_addingTimer.stop();
		}
		
		private function onGenerateNewShark(e:TimerEvent):void 
		{
			if (sharksArray.length < NUMBER_OF_SHARKS)
			{
				Generate();
			}
		}
		
		private function FindAPlaceForShark():Point 
		{
			var randomY:int = App.randomInt(_low_end, _high_end);
			var randomX:int = App.randomInt(0, Universe.MAP_WIDTH);
			return new Point(randomX, randomY);
		}
		
		private function Generate():void 
		{
			var tmpShark:Shark = App.pools.getPoolObject(Shark.NAME);
			
			while (true)
			{
				var tmpPoint:Point = FindAPlaceForShark();
				var tmpX:int = tmpPoint.x;
				var tmpY:int = tmpPoint.y;
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
			
			tmpShark.Init(tmpPoint, _hero, this);
			//tmpShark.Init(new Point(1700, 1600), _hero, this);
			_layer.addChild(tmpShark);
			sharksArray.push(tmpShark);
		}
		
		public function Destroy():void 
		{
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			_addingTimer.reset();
			_addingTimer.removeEventListener(TimerEvent.TIMER, onGenerateNewShark, false);
			dispatchEvent(new Destroying(Destroying.DESTROY, true, false));
			sharksArray.length = 0;
		}
		
		public function get low_end():int { return _low_end; }
		
		public function get high_end():int { return _high_end; }
	}

}