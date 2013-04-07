package Interface 
{
	import Bonuses.BonusInfo;
	import Events.BarComplete;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class BarsControl extends Sprite
	{
		private var _barsArray:Array = [];
		
		public function BarsControl() 
		{
			_barsArray.length = 0;
		}
		
		public function addNewBonus(type:int, delay:int):void 
		{
			var tmpBonusBar:BonusBar = App.pools.getPoolObject(BonusBar.NAME);
			tmpBonusBar.Init(type, delay, _barsArray.length);
			_barsArray.push(tmpBonusBar);
			tmpBonusBar.addEventListener(BarComplete.BAR_COMPLETE, onUpdateBars, false, 0, true);
			addChild(tmpBonusBar);
		}
		
		public function resetBonusTimer(type:int):void 
		{
			var tmpBar:BonusBar;
			for (var i:int = 0; i < _barsArray.length; i++)
			{
				tmpBar = _barsArray[i];
				if (tmpBar.bonusType == type)
				{
					tmpBar.timer.reset();
					tmpBar.timer.start();
					tmpBar.progress.gotoAndStop(1);
					tmpBar.counter = 0;
					return;
				}
			}
		}
		
		public function updateMultiplier(multiplier:Number):void 
		{
			var tmpBar:BonusBar;
			for (var i:int = 0; i < _barsArray.length; i++)
			{
				tmpBar = _barsArray[i];
				if (tmpBar.bonusType == BonusInfo.TYPE_SCORE_MULTIPL)
				{
					tmpBar.icon.multi.text = String(int(multiplier));
					return;
				}
			}
		}
		
		public function removeBar():void 
		{
			var tmpBar:BonusBar;
			for (var i:int = 0; i < _barsArray.length; i++)
			{
				tmpBar = _barsArray[i];
				if (tmpBar.bonusType == BonusInfo.TYPE_SCORE_MULTIPL)
				{
					tmpBar.Destroy(false);
					App.universe.multiplier = 1;
					_barsArray.splice(i, 1);
					return;
				}
			}
		}
		
		private function onUpdateBars(e:BarComplete):void 
		{
			var tmpBar:BonusBar;
			for (var i:int = 0; i < _barsArray.length; i++)
			{
				tmpBar = _barsArray[i];
				if (tmpBar == e.bar)
				{
					_barsArray.splice(i, 1);
					removeChild(e.bar);
					i--;
				}
				tmpBar.SetIndex(i);
			}
			
			dispatchEvent(new BarComplete(BarComplete.BAR_COMPLETE, true, false, e.bar, e.bonusType));
		}
		
		public function Destroy():void 
		{
			while (_barsArray.length != 0)
			{
				var tmpBar:BonusBar;
				tmpBar = _barsArray.shift();
				tmpBar.Destroy(false);
			}
		}
	}

}