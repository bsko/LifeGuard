package Waves 
{
	import Events.Destroying;
	import Events.PauseEvent;
	import Events.SingleWaveDestroying;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import Waves.*;
	/**
	 * ...
	 * @author 
	 */
	public class WaveGenreator extends Sprite
	{
		public static const INTENSITY:Number = 1;
		private var _hero:Hero;
		private var _wavesArray:Array = [];
		private var _layer:Sprite;
		
		public function Init(hero:Hero, layer:Sprite):void
		{
			_wavesArray.length = 0;
			_hero = hero;
			_layer = layer;
			addEventListener(Event.ENTER_FRAME, onWavesAdder, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			addEventListener(Event.ENTER_FRAME, onWavesAdder, false, 0, true);
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, onWavesAdder, false);
		}
		
		private function onWavesAdder(e:Event):void 
		{
			var tmpX:int = App.randomInt(_hero.x - App.STAGE_WIDTH, _hero.x + App.STAGE_WIDTH);
			var tmpY:int = App.randomInt(_hero.y - App.STAGE_HEIGHT, _hero.y + App.STAGE_HEIGHT);
			if (tmpX < 0 || tmpX > Universe.MAP_WIDTH || tmpY < 0 || tmpY > Universe.SAND_START)
			{
				return;
			}
			if ((tmpX > Universe.ISLAND_X) && (tmpX < Universe.ISLAND_X + Universe.ISLAND_WIDTH) && (tmpY > Universe.ISLAND_Y) && (tmpY < Universe.ISLAND_Y + Universe.ISLAND_HEIGHT))
			{
				return;
			}
			
			var tmpWave:Wave = App.pools.getPoolObject(Wave.NAME);
			tmpWave.x = tmpX;
			tmpWave.y = tmpY;
			_layer.addChild(tmpWave);
			tmpWave.Init(this);
			_wavesArray.push(tmpWave);
			tmpWave.addEventListener(SingleWaveDestroying.DESTROY_ME, onDestroyWave, false, 0, true);
		}
		
		private function onDestroyWave(e:SingleWaveDestroying = null):void 
		{
			var tmpWave:Wave = _wavesArray.shift();
			tmpWave.removeEventListener(SingleWaveDestroying.DESTROY_ME, onDestroyWave, false);
			tmpWave.Destroy();
			_layer.removeChild(tmpWave);
			App.pools.returnPoolObject(Wave.NAME, tmpWave);
		}
		
		public function Destroy():void
		{
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			removeEventListener(Event.ENTER_FRAME, onWavesAdder, false);
			while (_wavesArray.length > 0)
			{
				onDestroyWave();
			}
			dispatchEvent(new Destroying(Destroying.DESTROY, true, false));
		}
		
		public function get wavesArray():Array { return _wavesArray; }
		
	}

}