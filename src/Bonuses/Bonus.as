package Bonuses 
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
	public class Bonus extends Sprite
	{	
		public static const NAME:String = "bonus";
		public static const DISTANCE_TO_TAKE:int = 30;
		public static const TIME_TO_SWITCH:int = 200;
		public static const BONUS_AVAILABLE_TIME:int = 1000;
		public static const BONUS_ENDING_TIME:int = 800;
		
		private var _bonusType:int;
		private var _bonus_movie:MovieClip;
		private var _startPoint:Point;
		private var _hero:Hero;
		private var _generator:BonusGenerator;
		private var _counter:int;
		private var _isReadyToTake:Boolean;
		private var _alpha_direct:int = -1;
		private var _alpha_delay:int = 0.05;
		
		public function Bonus() 
		{
			_bonus_movie = new BonusMovie_full();
			_bonusType = BonusInfo.BONUSES_ARRAY[App.randomInt(0, BonusInfo.BONUSES_ARRAY.length)];
		}
		
		public function Init(point:Point, hero:Hero, generator:BonusGenerator):void 
		{
			_bonus_movie.gotoAndStop(1);
			var rnd:int = (Math.random() > .5) ? 1 : 2;
			_bonus_movie.bonus_movie.gotoAndStop(rnd);
			
			_counter = 0;
			_isReadyToTake = false;
			_startPoint = point;
			_hero = hero;
			x = _startPoint.x;
			y = _startPoint.y;
			addChild(_bonus_movie);
			
			addEventListener(Event.ENTER_FRAME, onUpdateBonus, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
			_generator = generator;
			_generator.addEventListener(Destroying.DESTROY, onDestroying, false, 0, true);
			
			_bonus_movie.bonus_movie.gotoAndStop(1);
		}
		
		private function onUpdateBonus(e:Event):void 
		{
			_counter++;
			
			if (_counter < TIME_TO_SWITCH)
			{
				
			}
			else if (_counter < BONUS_ENDING_TIME)
			{
				if (!_isReadyToTake)
				{
					_bonus_movie.gotoAndStop(2);
					_bonus_movie.bonus_type.gotoAndStop("bonus_" + String(_bonusType));
				}
				onSearchForOwner();
			}
			else if (_counter < BONUS_AVAILABLE_TIME)
			{
				if (!_isReadyToTake)
				{
					_bonus_movie.gotoAndStop(2);
					_bonus_movie.bonus_type.gotoAndStop("bonus_" + String(_bonusType));
				}
				onSearchForOwner();
				
				alpha += _alpha_direct * _alpha_delay;
				
				if (alpha >= 1) { _alpha_direct = -1; }
				else if (alpha <= 0.5) { _alpha_direct = 1; }
			}
			else if (_counter >= BONUS_AVAILABLE_TIME)
			{
				Destroy();
			}
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			//_bonus_movie.play();
			addEventListener(Event.ENTER_FRAME, onUpdateBonus, false, 0, true);
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			//_bonus_movie.stop();
			removeEventListener(Event.ENTER_FRAME, onUpdateBonus, false);
		}
		
		private function onDestroying(e:Destroying):void 
		{
			Destroy();
		}
		
		private function onSearchForOwner():void 
		{
			if (Point.distance(_startPoint, new Point(_hero.x, _hero.y)) < DISTANCE_TO_TAKE)
			{
				takeTheBonus();
			}
		}
		
		private function takeTheBonus():void 
		{
			var string:String;
			switch(_bonusType)
			{
				case BonusInfo.TYPE_ONLY_GIRLS:
				App.universe.onlyGirlsMode();
				string = "Only Girls";
				break;
				case BonusInfo.TYPE_NON_STOP_ROCKETS:
				App.universe.nonStopRocketsModeFunc();
				string = "NonStop Rockets";
				break;
				case BonusInfo.TYPE_NON_STOP_ROUNDS:
				App.universe.nonStopRoundsModeFunc();
				string = "NonStop Rounds";
				break;
				case BonusInfo.TYPE_GIVE_ROUNDS:
				App.universe.giveThemRounds();
				string = "Rounds To Everyone";
				break;
				case BonusInfo.TYPE_HERO_SPEED_UP:
				App.universe.giveSpeedToHero();
				string = "Speed UP";
				break;
				case BonusInfo.TYPE_DIE_SHARKS_DIE:
				App.universe.killSharks();
				string = "Die Sharks!";
				break;
				case BonusInfo.TYPE_HERO_SPEED_DOWN:
				App.universe.giveDownSpeedToHero();
				string = "Speed DOWN";
				break;
				case BonusInfo.TYPE_NON_EATING_SHARKS:
				App.universe.nonEatingSharks();
				string = "Satisfied Sharks";
				break;
				case BonusInfo.TYPE_SCORE_MULTIPL:
				App.universe.updateMultiplier(true);
				string = "Multiplier UP";
				break;
				case BonusInfo.TYPE_SCORE_MULT_DOWN:
				App.universe.updateMultiplier(false);
				string = "Multiplier DOWN";
				break;
			}
			
			var a:PopupMessage = App.pools.getPoolObject(PopupMessage.NAME);
			a.Init(x, y, PopupMessage.TYPE_ADD_BONUS, string);
			
			Destroy();
		}
		
		private function Destroy():void 
		{
			_counter = 0;
			removeEventListener(Event.ENTER_FRAME, onUpdateBonus, false);
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			_generator.removeEventListener(Destroying.DESTROY, onDestroying, false);
			BonusGenerator.deleteSingleBonus(this);
			removeChild(_bonus_movie);
			App.pools.returnPoolObject(NAME, this);
		}
	}

}