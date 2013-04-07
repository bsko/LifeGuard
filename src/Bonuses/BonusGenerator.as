package Bonuses 
{
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class BonusGenerator extends Sprite
	{
		public static const BONUS_ADDING_DELAY:int = 30000;
		//public static const BONUS_ADDING_DELAY:int = 3000;
		public static const LOW_END:int = 2000;
		public static const HIGH_END:int = 100;
		public static const MAX_BONUSES_COUNT:int = 20;
		
		private var _low_end:int = LOW_END;
		private var _high_end:int = HIGH_END;
		private var _layer:Sprite;
		private var _universe:Universe;
		private var _hero:Hero;
		private static var _bonusesArray:Array = [];
		private var _addingTimer:Timer = new Timer(BONUS_ADDING_DELAY);
		public static var _counter:int = 0;
		
		public function Init(universe:Universe):void 
		{
			_universe = universe;
			_hero = _universe.hero;
			_layer = _universe.bonusesLayer;
			_bonusesArray.length = 0;
			_addingTimer.start();
			_addingTimer.addEventListener(TimerEvent.TIMER, onUpdateBonuses, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			_addingTimer.start();
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_addingTimer.stop();
		}
		
		private function FindAPlaceForBonus():Point 
		{
			var randomY:int = App.randomInt(_high_end, _low_end);
			var randomX:int = App.randomInt(0, Universe.MAP_WIDTH);
			return new Point(randomX, randomY);
		}
		
		private function onUpdateBonuses(e:TimerEvent):void 
		{
			if (_bonusesArray.length <= MAX_BONUSES_COUNT)
			{
				var tmpBonus:Bonus = App.pools.getPoolObject(Bonus.NAME);
				while (true)
				{
					var tmpPoint:Point = FindAPlaceForBonus();
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
				
				/*_counter++;
				
				tmpPoint.x = 200 + _counter * 40;
				tmpPoint.y = 2400;*/
				
				
				tmpBonus.Init(tmpPoint, _hero, this);
				_layer.addChild(tmpBonus);
				_bonusesArray.push(tmpBonus);
			}
		}
		
		public static function deleteSingleBonus(bonus:Bonus):void 
		{
			var length:int = _bonusesArray.length;
			var tmpBonus:Bonus;
			for (var i:int = 0; i < length; i++)
			{
				tmpBonus = _bonusesArray[i];
				if (tmpBonus == bonus)
				{
					_bonusesArray.splice(i, 1);
					return;
				}
			}
		}
		
		public function Destroy():void 
		{
			_addingTimer.removeEventListener(TimerEvent.TIMER, onUpdateBonuses, false);
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			_addingTimer.reset();
			_addingTimer.delay = BONUS_ADDING_DELAY;
			dispatchEvent(new Destroying(Destroying.DESTROY, true, false));
			_bonusesArray.length = 0;
		}
	}

}