package Rounds 
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
	public class RoundsGenerator extends Sprite
	{
		public static const ADDING_DELAY:int = 22000;
		//public static const ADDING_DELAY:int = 220;
		public static const MAX_ROUNDS_COUNT:int = 20;
		public static var roundsArray:Array = [];
		private var _universe:Universe;
		private var _layer:Sprite;
		private var _roundsAddingTimer:Timer = new Timer(ADDING_DELAY);
		private var _zonesArray:Array;
		
		public function Init(universe:Universe):void
		{
			_universe = universe;
			_layer = _universe.downHeroSprite;
			roundsArray.length = 0;
			_roundsAddingTimer.start();
			_roundsAddingTimer.addEventListener(TimerEvent.TIMER, onAddNewRound, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_roundsAddingTimer.stop();
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			_roundsAddingTimer.start();
		}
		
		private function onAddNewRound(e:TimerEvent):void 
		{
			if (roundsArray.length <= MAX_ROUNDS_COUNT)
			{
				var tmpSprite:Sprite = _zonesArray[int(Math.random() * _zonesArray.length)];
				var tmpPoint:Point = new Point(int(Math.random() * tmpSprite.width) + tmpSprite.x, int(Math.random() * tmpSprite.height) + tmpSprite.y + 2000);
				var tmpRound:ROund = App.pools.getPoolObject(ROund.NAME);
				tmpRound.x = tmpPoint.x;
				tmpRound.y = tmpPoint.y;
				_layer.addChild(tmpRound);
				tmpRound.Init(_universe.hero, this); 
				roundsArray.push(tmpRound);
			}
		}
		
		public function Destroy():void
		{
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			_roundsAddingTimer.removeEventListener(TimerEvent.TIMER, onAddNewRound, false);
			_roundsAddingTimer.reset();
			_roundsAddingTimer.delay = ADDING_DELAY;
			dispatchEvent(new Destroying(Destroying.DESTROY, true, false));
		}
		
		public function get zonesArray():Array { return _zonesArray; }
		
		public function set zonesArray(value:Array):void 
		{
			_zonesArray = value;
		}
	}

}