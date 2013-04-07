package Waves 
{
	import Events.Destroying;
	import Events.SingleWaveDestroying;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class Wave extends Sprite
	{
		public static const NAME:String = "wave";
		private var _wave_movie:MovieClip = new WaveMovie();
		private var _generator:WaveGenreator;
		
		public function Wave() 
		{
			_wave_movie.alpha = 0.75;
			addChild(_wave_movie);
		}
		
		public function Init(generator:WaveGenreator):void
		{
			_generator = generator;
			_wave_movie.play();
			
			_wave_movie.scaleX = _wave_movie.scaleY = 0.7 + Math.random();
			_wave_movie.addEventListener("deleteme", onDeleteWave, false, 0, true);
			_generator.addEventListener(Destroying.DESTROY, onDeleteWave, false, 0, true);
		}
		
		private function onDeleteWave(e:Event):void 
		{
			dispatchEvent(new SingleWaveDestroying(SingleWaveDestroying.DESTROY_ME, true, false));
		}
		
		public function Destroy():void 
		{
			_wave_movie.gotoAndStop(1);
			_wave_movie.removeEventListener("deleteme", onDeleteWave, false);
			_generator.removeEventListener(Destroying.DESTROY, onDeleteWave, false);
			
		}
		
	}

}