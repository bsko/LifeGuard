package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class Camera extends Sprite
	{
		private var _universe:Universe;
		private var _hero:Hero;
		
		public function Init(univ:Universe):void
		{
			_universe = univ;
			_hero = _universe.hero;
			addEventListener(Event.ENTER_FRAME, onUpdateUniversePosition, false, 0, true);
		}
		
		private function onUpdateUniversePosition(e:Event):void 
		{
			//trace(_hero.x, _hero.y);
			var delay_X:int = _hero.x - App.STAGE_HALF_WIDTH;
			var delay_Y:int = _hero.y - App.STAGE_HALF_HEIGHT;
			if (!(delay_X <= 0) && !(delay_X >= Universe.MAP_WIDTH - App.STAGE_WIDTH))
			{
				_universe.x = - delay_X;
			}
			if (!(delay_Y <= 0) && !(delay_Y >= Universe.MAP_HEIGHT- App.STAGE_HEIGHT))
			{
				_universe.y = - delay_Y;
			}
		}
		
		public function Destroy():void
		{
			_universe.x = 0;
			_universe.y = 0;
			removeEventListener(Event.ENTER_FRAME, onUpdateUniversePosition, false);
		}
	}

}