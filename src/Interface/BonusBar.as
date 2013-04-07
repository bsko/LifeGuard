package Interface 
{
	import Bonuses.Bonus;
	import Bonuses.BonusInfo;
	import Events.BarComplete;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class BonusBar extends Sprite
	{
		public static const NAME:String = "BonusBar";
		public static const UPDATES_COUNT:int = 100;
		public static const INDEX_DELAY:int = 70;
		public static const LEFT_DELAY:int = 20;
		public static const Y_DELAY:int = 35;
		
		private var _timer:Timer = new Timer(1000);
		private var _movie:MovieClip = new menuBars();
		private var _progress:MovieClip = _movie.progress;
		private var _icon:MovieClip = _movie.bonus_type;
		private var _isFree:Boolean;
		private var _counter:int;
		private var _fullTime:int;
		private var _index:int;
		private var _bonusType:int;
		
		public function BonusBar() 
		{
			_isFree = true;
			addChild(_movie);
		}
		
		public function Init(type:int, delay:int, index:int):void 
		{
			SetIndex(index);
			_bonusType = type;
			_icon.gotoAndStop("bonus_" + String(_bonusType));
			_fullTime = delay;
			_counter = 0;
			_timer.delay = _fullTime / UPDATES_COUNT;
			_bonusType = type;
			_progress.gotoAndStop(1);
			if (_isFree)
			{
				_isFree = false;
				_timer.start();
				_timer.addEventListener(TimerEvent.TIMER, onUpdateBar, false, 0, true);
				App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
				App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
				App.universe.addEventListener(Destroying.DESTROY, onDestroy, false, 0, true);
			}
		}
		
		private function onDestroy(e:Destroying):void 
		{
			Destroy(false);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			_timer.start();
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_timer.stop();
		}
		
		public function SetIndex(index:int):void 
		{
			x = LEFT_DELAY + index * INDEX_DELAY;
			y = Y_DELAY;
		}
		
		private function onUpdateBar(e:TimerEvent):void 
		{
			_counter++;
			if (_counter < UPDATES_COUNT)
			{
				_progress.gotoAndStop(_counter + 1);
			}
			else
			{
				stopCounter();
			}
		}
		
		private function stopCounter():void 
		{
			_timer.removeEventListener(TimerEvent.TIMER, onUpdateBar, false);
			_timer.reset();
			_counter = 0;
			_isFree = true;
			if (_bonusType == BonusInfo.TYPE_SCORE_MULTIPL && App.universe.multiplier > 2)
			{
				_timer.addEventListener(TimerEvent.TIMER, onUpdateBar, false, 0, true);
				_timer.start();
				_counter = 0;
				_isFree = false;
				App.universe.multiplier--;
				_icon.multi.text = String(int(App.universe.multiplier));
			}
			else
			{
				dispatchEvent(new BarComplete(BarComplete.BAR_COMPLETE, true, false, this, _bonusType));
			}
		}
		
		public function Destroy(boolean:Boolean):void 
		{
			_counter = 0;
			removeChild(_movie);
			if (!_isFree)
			{
				_timer.removeEventListener(TimerEvent.TIMER, onUpdateBar, false);
				_timer.reset();
			}
			_isFree = false;
			App.pools.returnPoolObject(NAME, this);
			if (boolean)
			{
				dispatchEvent(new BarComplete(BarComplete.BAR_COMPLETE, false, false, this, _bonusType));
			}
		}
		
		public function get bonusType():int { return _bonusType; }
		
		public function get counter():int { return _counter; }
		
		public function set counter(value:int):void 
		{
			_counter = value;
		}
		
		public function get timer():Timer { return _timer; }
		
		public function set timer(value:Timer):void 
		{
			_timer = value;
		}
		
		public function get icon():MovieClip { return _icon; }
		
		public function get progress():MovieClip { return _progress; }
	}

}