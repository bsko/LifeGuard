package  
{
	import Events.Destroying;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class Buyok extends Sprite
	{
		public static const NAME:String = "Buyok";
		public static const BYUOKS_LINE_Y:int = 130;
		private var _buyok_movie:MovieClip = new Buyok_movie();
		private var _universe:Universe;
		
		public function	Init():void
		{
			_universe = App.universe;
			addChild(_buyok_movie);
			_buyok_movie.gotoAndPlay(App.randomInt(1, _buyok_movie.totalFrames));
			_universe.addEventListener(Destroying.DESTROY, onDestroy, false, 0, true);
		}
		
		private function onDestroy(e:Destroying):void 
		{
			Destroy();
		}
		
		private function Destroy():void
		{
			_universe.removeEventListener(Destroying.DESTROY, onDestroy, false);
			removeChild(_buyok_movie);
			App.pools.returnPoolObject(NAME, this);
		}
	}

}