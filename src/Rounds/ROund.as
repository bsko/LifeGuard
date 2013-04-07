package Rounds 
{
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class ROund extends Sprite
	{
		public static const DISTANCE_TO_TAKE:int = 30;
		public static const NAME:String = "ROund";
		public static const AVAILABLE_TIME:int = 1000;
		private var _round_movie:MovieClip = new Kryg_movie();
		private var _hero:Hero;
		private var _generator:RoundsGenerator;
		private var _counter:int;
		
		public function Init(hero:Hero, roundGenerator:RoundsGenerator):void
		{
			_counter = 0;
			_hero = hero;
			_generator = roundGenerator;
			addChild(_round_movie);
			_round_movie.scaleX = _round_movie.scaleY = 0;
			_round_movie.alpha = 0;
			addEventListener(Event.ENTER_FRAME, onUpdateGrowing, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateTaking, false, 0, true);
			_generator.addEventListener(Destroying.DESTROY, onDestroy, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			addEventListener(Event.ENTER_FRAME, onUpdateGrowing, false, 0, true);
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, onUpdateGrowing, false);
		}
		
		private function onUpdateGrowing(e:Event):void 
		{
			_round_movie.alpha += 0.05;
			_round_movie.scaleX += 0.05;
			_round_movie.scaleY += 0.05;
			if (_round_movie.alpha >= 1)
			{
				_round_movie.alpha = 1;
				_round_movie.scaleX = _round_movie.scaleY = 1;
				removeEventListener(Event.ENTER_FRAME, onUpdateGrowing, false);
			}
		}
		
		private function onDestroy(e:Destroying):void 
		{
			Destroy();
		}
		
		private function onUpdateTaking(e:Event):void 
		{
			_counter++;
			
			var distance:int = Point.distance(new Point(this.x, this.y), new Point(_hero.x, _hero.y));
			if (distance < DISTANCE_TO_TAKE)
			{
				_hero.takeARound();
				Destroy();
				return;
			}
			
			if (_counter >= AVAILABLE_TIME)
			{
				Destroy();
			}
		}
		
		public function Destroy():void
		{
			_counter = 0;
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateGrowing, false);
			removeChild(_round_movie);
			removeFromRoundsArray();
			_generator.removeEventListener(Destroying.DESTROY, onDestroy, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateTaking, false);
			App.pools.returnPoolObject(NAME, this);
		}
		
		private function removeFromRoundsArray():void 
		{
			var length:int = RoundsGenerator.roundsArray.length;
			var tmpRound:ROund;
			for (var i:int = 0; i < length; i++)
			{
				tmpRound = RoundsGenerator.roundsArray[i];
				if (tmpRound == this)
				{
					RoundsGenerator.roundsArray.splice(i, 1);
					return;
				}
			}
		}
	}

}