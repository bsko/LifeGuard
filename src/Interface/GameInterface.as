package Interface
{
	import Events.Abilities;
	import Events.PauseEvent;
	import Events.StartGame;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 
	 */
	public class GameInterface extends Sprite
	{
		public static const WHISTLE_COOLDOWN:int = 200;
		public static const PISTOL_COOLDOWN:int = 200;
		public static const ROUND_COOLDOWN:int = 200;
		private var _gameInterface:MovieClip = new InGameMenu();
		private var _barControl:BarsControl = new BarsControl();
		private var _pressSpace:MovieClip;
		private var _scoreField:TextField;
		private var _whistle_cunter:int;
		private var _round_cunter:int;
		private var _pistol_cunter:int;
		private var _isCooldowningPistol:Boolean;
		private var _isCooldowningRound:Boolean;
		private var _isCooldowningWhistle:Boolean;
		private var _tutorial:Tutorial = new Tutorial();
		private var _isMenuOnScreen:Boolean = false;
		
		public function Init():void 
		{
			App.soundManager.setMusic("music1");
			_gameInterface.gotoAndStop("indagame");
			this.mouseEnabled = false;
			_pressSpace = _gameInterface.pressSpace as MovieClip;
			_scoreField = _gameInterface.scoreField as TextField;
			_pressSpace.visible = false;
			addChild(gameInterface);
			gameInterface.mouseEnabled = false;
			gameInterface.menuBtn.addEventListener(MouseEvent.CLICK, onMenuEvent, false, 0, true);
			gameInterface.soundBtn.addEventListener(MouseEvent.CLICK, onChangeSndStatus, false, 0, true);
			gameInterface.musicBtn.addEventListener(MouseEvent.CLICK, onChangeMscStatus, false, 0, true);
			gameInterface.wistleBtn.addEventListener(MouseEvent.CLICK, onWistleEvent, false, 0, true);
			gameInterface.pistolBtn.addEventListener(MouseEvent.CLICK, onPistolEvent, false, 0, true);
			gameInterface.ringBtn.addEventListener(MouseEvent.CLICK, onRoundEvent, false, 0, true);
			//gameInterface.wistleBtn.gotoAndStop("active");
			gameInterface.pistolBtn.gotoAndStop("active");
			gameInterface.ringBtn.gotoAndStop("active");
			gameInterface.wistleBtn.gotoAndStop("active");
			gameInterface.bestScore.mouseEnabled = false;
			gameInterface.scoreField.mouseEnabled = false;
			addChild(_tutorial);
			_tutorial.x = App.STAGE_HALF_WIDTH;
			_tutorial.y = App.STAGE_HALF_HEIGHT;
			_tutorial.GameStarted();
			_whistle_cunter = 0;
			_round_cunter = 0;
			_pistol_cunter = 0;
			_isCooldowningPistol = false;
			_isCooldowningWhistle = false;
			_isCooldowningRound = false;
			addChild(_barControl);
			UpdateSndBtns();
			_isMenuOnScreen = false;
		}
		
		public function changePistolsCount(a:int):void 
		{
			gameInterface.flaresCount.text = a.toString();
		}
		
		public function changeRoundsCount(a:int):void 
		{
			gameInterface.roundsCount.text = a.toString();
		}
		
		public function updateScore(a:int):void 
		{
			var a1:int = a % 1000;
			a /= 1000;
			if (a > 1)
			{
				var a2:int = a % 1000;
				a /= 1000;
				if ( a > 1)
				{
					var a3:int = a % 1000;
					_scoreField.text = "SCORE : " + a3.toString() + " " + a2.toString() + " " + a1.toString();
				}
				else
				{
					_scoreField.text = "SCORE : " + a2.toString() + " " + a1.toString();
				}
			}
			else
			{
				_scoreField.text = "SCORE : " + a1.toString();
			}
		}
		
		public function onRoundEvent(e:MouseEvent = null):void 
		{
			if (!_isCooldowningRound)
			{
				dispatchEvent(new Abilities(Abilities.ROUND, true, false));
			}
		}
		
		public function onPistolEvent(e:MouseEvent = null):void 
		{
			if (!_isCooldowningPistol)
			{
				dispatchEvent(new Abilities(Abilities.PISTOL, true, false));
			}
		}
		
		public function onWistleEvent(e:MouseEvent = null):void 
		{
			if (!_isCooldowningWhistle)
			{
				dispatchEvent(new Abilities(Abilities.WISTLE, true, false));
				StartWhistleCooldown();
			}
		}
		
		public function StartPistolCooldown():void
		{
			addEventListener(Event.ENTER_FRAME, onUpdatePistolCooldown, false, 0, true);
			_isCooldowningPistol = true;
				
			gameInterface.pistolBtn.gotoAndStop("passive");
		}
		
		public function StartRoundCooldown():void 
		{
			addEventListener(Event.ENTER_FRAME, onUpdateRoundCooldown, false, 0, true);
			_isCooldowningRound = true;
			gameInterface.ringBtn.gotoAndStop("passive");
		}
		
		public function StartWhistleCooldown():void 
		{
			addEventListener(Event.ENTER_FRAME, onUpdateWhistleCooldown, false, 0, true);
			_isCooldowningWhistle = true;
			gameInterface.wistleBtn.gotoAndStop("passive");
		}
		
		private function onUpdateRoundCooldown(e:Event):void 
		{
			_round_cunter++;
			if (_round_cunter >= ROUND_COOLDOWN)
			{
				_isCooldowningRound = false;
				removeEventListener(Event.ENTER_FRAME, onUpdateRoundCooldown, false);
				_round_cunter = 0;
				gameInterface.ringBtn.gotoAndStop("active");
				return;
			}
			//var totalFrames:int = gameInterface.ringBtn.progress.totalFrames;
			//var currentFrame:int = (_round_cunter / ROUND_COOLDOWN) * totalFrames;
			//gameInterface.ringBtn.progress.play();
			//gameInterface.ringBtn.progress.gotoAndStop(currentFrame);
		}
		
		private function onUpdatePistolCooldown(e:Event):void 
		{
			_pistol_cunter++;
			if (_pistol_cunter >= PISTOL_COOLDOWN)
			{
				_isCooldowningPistol = false;
				removeEventListener(Event.ENTER_FRAME, onUpdatePistolCooldown, false);
				_pistol_cunter = 0;
				gameInterface.pistolBtn.gotoAndStop("active");
				return;
			}
			//var totalFrames:int = gameInterface.pistolBtn.progress.totalFrames;
			//gameInterface.pistolBtn.progress.gotoAndStop((_pistol_cunter / PISTOL_COOLDOWN) * totalFrames);
			//gameInterface.pistolBtn.progress.play();
		}
		
		private function onUpdateWhistleCooldown(e:Event):void 
		{
			_whistle_cunter++;
			if (_whistle_cunter >= WHISTLE_COOLDOWN)
			{
				_isCooldowningWhistle = false;
				removeEventListener(Event.ENTER_FRAME, onUpdateWhistleCooldown, false);
				_whistle_cunter = 0;
				gameInterface.wistleBtn.gotoAndStop("active");
				return;
			}
			//gameInterface.wistleBtn.progress.play();
		}
		
		private function onChangeMscStatus(e:MouseEvent):void 
		{
			App.isMusicOn = !App.isMusicOn;
			App.soundManager.changeMusicMode();
			UpdateSndBtns();
		}
		
		private function onChangeSndStatus(e:MouseEvent):void 
		{
			App.isSoundOn = !App.isSoundOn;
			App.soundManager.changeSoundsMode();
			UpdateSndBtns();
		}
		
		public function ShowPressSpace():void 
		{
			_pressSpace.visible = true;
		}
		
		public function HidePressSpace():void 
		{
			_pressSpace.visible = false;
		}
		
		public function Pause():void
		{
			dispatchEvent(new PauseEvent(PauseEvent.PAUSE, true, false));
		}
		
		public function Unpause():void
		{
			dispatchEvent(new PauseEvent(PauseEvent.UNPAUSE, true, false));
		}
		
		public function onMenuEvent(e:MouseEvent = null):void 
		{
			if (!_isMenuOnScreen)
			{
				_isMenuOnScreen = true;
				Pause();
				_gameInterface.gotoAndStop("pause");
				
				_gameInterface.resumeBtn.addEventListener(MouseEvent.CLICK, onResume, false, 0, true);
				_gameInterface.restartBtn.addEventListener(MouseEvent.CLICK, onRestart, false, 0, true);
				_gameInterface.mainmenu.addEventListener(MouseEvent.CLICK, onMainMenu, false, 0, true);
			}
			else {
				onResume();
			}
		}
		
		public function SetDeathsCount(value:int):void
		{
			_gameInterface.bodies_bar.gotoAndStop(value + 1);
		}
		
		private function onMainMenu(e:MouseEvent):void 
		{
			dispatchEvent(new PauseEvent(PauseEvent.UNPAUSE, true, false));
			dispatchEvent(new StartGame(StartGame.QUIT_GAME, true, false));
		}
		
		private function onRestart(e:MouseEvent):void 
		{
			dispatchEvent(new PauseEvent(PauseEvent.UNPAUSE, true, false));
			dispatchEvent(new StartGame(StartGame.RESTART_GAME, true, false));
		}
		
		private function onResume(e:MouseEvent = null):void 
		{
			_isMenuOnScreen = false;
			_gameInterface.gotoAndStop("indagame");
			
			Unpause();
			gameInterface.menuBtn.addEventListener(MouseEvent.CLICK, onMenuEvent, false, 0, true);
			gameInterface.soundBtn.addEventListener(MouseEvent.CLICK, onChangeSndStatus, false, 0, true);
			gameInterface.musicBtn.addEventListener(MouseEvent.CLICK, onChangeMscStatus, false, 0, true);
			gameInterface.wistleBtn.addEventListener(MouseEvent.CLICK, onWistleEvent, false, 0, true);
			gameInterface.pistolBtn.addEventListener(MouseEvent.CLICK, onPistolEvent, false, 0, true);
			gameInterface.ringBtn.addEventListener(MouseEvent.CLICK, onRoundEvent, false, 0, true);
		}
		
		public function Destroy():void 
		{
			removeChild(_gameInterface);
			removeChild(_tutorial);
			_tutorial.EndGame();
			removeChild(_barControl);
			_whistle_cunter = 0;
			_round_cunter = 0;
			_pistol_cunter = 0;
			if (_isCooldowningPistol)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdatePistolCooldown, false);
			}
			if (_isCooldowningRound)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdateRoundCooldown, false);
			}
			if (_isCooldowningWhistle)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdateWhistleCooldown, false);
			}
		}
		
		public function endLevel():void 
		{
			dispatchEvent(new PauseEvent(PauseEvent.PAUSE, true, false));
			SetDeathsCount(5);
			_gameInterface.gotoAndStop("endgame");
			_gameInterface.total_score.text = String(App.universe.score);
			_gameInterface.mainmenu.addEventListener(MouseEvent.CLICK, onMainMenu, false, 0, true);
			_gameInterface.restart.addEventListener(MouseEvent.CLICK, onRestart, false, 0, true);
		}
		
		private function UpdateSndBtns():void
		{
			if (App.isSoundOn)
			{
				_gameInterface.soundBtn.gotoAndStop("on");
			}
			else
			{
				_gameInterface.soundBtn.gotoAndStop("off");
			}
			if (App.isMusicOn)
			{
				_gameInterface.musicBtn.gotoAndStop("on");
			}
			else
			{
				_gameInterface.musicBtn.gotoAndStop("off");
			}
		}
		
		public function get gameInterface():MovieClip { return _gameInterface; }
		
		public function get barControl():BarsControl { return _barControl; }
		
		public function get tutorial():Tutorial { return _tutorial; }
	}

}