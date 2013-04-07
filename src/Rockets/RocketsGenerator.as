package Rockets 
{
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author ...
	 */
	public class RocketsGenerator extends Sprite
	{
		public static const ADDING_DELAY:int = 22000;
		//public static const ADDING_DELAY:int = 220;
		public static const MAX_ROCKETS_COUNT:int = 20;
		
		public static var firesArray:Array = [];
		private var _universe:Universe;
		private var _layer:Sprite;
		private var _firesAddingTimer:Timer = new Timer(ADDING_DELAY);
		private var _zonesArray:Array;
		
		public function Init(universe:Universe):void
		{
			_universe = universe;
			_layer = _universe.downHeroSprite;
			firesArray.length = 0;
			_firesAddingTimer.start();
			_firesAddingTimer.addEventListener(TimerEvent.TIMER, onAddNewRocket, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			_firesAddingTimer.start();
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_firesAddingTimer.stop();
		}
		
		private function onAddNewRocket(e:TimerEvent):void 
		{
			if (firesArray.length <= MAX_ROCKETS_COUNT)
			{
				var tmpSprite:Sprite = _zonesArray[int(Math.random() * _zonesArray.length)];
				var tmpPoint:Point = new Point(int(Math.random() * tmpSprite.width) + tmpSprite.x, int(Math.random() * tmpSprite.height) + tmpSprite.y);
				var tmpRound:Rocket = App.pools.getPoolObject(Rocket.NAME);
				tmpRound.x = tmpPoint.x;
				tmpRound.y = tmpPoint.y + 2000;
				tmpRound.Init(_universe.hero, this, _layer);
				firesArray.push(tmpRound);
			}
		}
		
		public function Destroy():void
		{
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			_firesAddingTimer.removeEventListener(TimerEvent.TIMER, onAddNewRocket, false);
			_firesAddingTimer.reset();
			_firesAddingTimer.delay = ADDING_DELAY;
			//dispatchEvent(new Destroying(Destroying.DESTROY, true, false));
		}
		
		public function get zonesArray():Array { return _zonesArray; }
		
		public function set zonesArray(value:Array):void 
		{
			_zonesArray = value;
		}
	}

}