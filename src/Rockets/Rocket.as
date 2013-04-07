package Rockets 
{
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class Rocket extends Sprite
	{
		public static const NAME:String = "Rocket";
		public static const DISTANCE_TO_TAKE:int = 30;
		public static const AVAILABLE_TIME:int = 1000;
		
		private var _round_movie:MovieClip = new ShellMovie();
		private var _hero:Hero;
		private var _generator:RocketsGenerator;
		private var _counter:int;
		private var _layer:Sprite;
		
		public function Rocket()
		{
			_round_movie.gotoAndStop("standart");
		}
		
		public function Init(hero:Hero, rGenerator:RocketsGenerator, sprite:Sprite):void
		{
			_round_movie.gotoAndStop("standart");
			_counter = 0;
			_hero = hero;
			_layer = sprite;
			_generator = rGenerator;
			addChild(_round_movie);
			_round_movie.rotation = App.randomInt(0, 360);
			_round_movie.scaleX = _round_movie.scaleY = 0;
			_round_movie.alpha = 0;
			sprite.addChild(this);
			addEventListener(Event.ENTER_FRAME, onUpdateGrowing, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateTaking, false, 0, true);
			App.universe.addEventListener(Destroying.DESTROY, onDestroy, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			_round_movie.play();
			addEventListener(Event.ENTER_FRAME, onUpdateGrowing, false, 0, true);
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			_round_movie.stop();
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
				_hero.takeARocket();
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
			_layer.removeChild(this);
			_round_movie.gotoAndStop(1);
			x = -100;
			y = -100;
			_counter = 0;
			removeEventListener(Event.ENTER_FRAME, onUpdateGrowing, false);
			removeChild(_round_movie);
			App.universe.removeEventListener(Destroying.DESTROY, onDestroy, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateTaking, false);
			removeFromFiresArray();
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			App.pools.returnPoolObject(NAME, this);
		}
		
		private function removeFromFiresArray():void 
		{
			var length:int = RocketsGenerator.firesArray.length;
			var tmpFire:Rocket;
			for (var i:int = 0; i < length; i++)
			{
				tmpFire = RocketsGenerator.firesArray[i];
				if (tmpFire == this)
				{
					RocketsGenerator.firesArray.splice(i, 1);
					return;
				}
			}
		}
	}

}