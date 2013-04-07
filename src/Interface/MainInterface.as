package Interface
{
	import Events.StartGame;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class MainInterface extends Sprite
	{
		
		private static const LABEL_MAIN_MENU:String = "main-menu";
		private static const LABEL_CREDITS:String = "credits";
		private static const LABEL_HI_SCORE:String = "hi-score";
		
		private var _mainMenu:MovieClip = new MainMenuMovie();
		
		public function MainInterface() 
		{
			addChild(mainMenu);
		}
		
		public function Init():void 
		{
			App.soundManager.setMusic("music2");
			MainMenuPage();
		}
		
		private function MainMenuPage():void 
		{
			mainMenu.gotoAndStop(LABEL_MAIN_MENU);
			mainMenu.playBtn.addEventListener(MouseEvent.CLICK, onMainMenu_TO_playGame, false, 0, true);
			mainMenu.hiscoreBtn.addEventListener(MouseEvent.CLICK, onMainMenu_TO_hiScore, false, 0, true);
			mainMenu.credits.addEventListener(MouseEvent.CLICK, onMainMenu_TO_credits, false, 0, true);
			mainMenu.soundBtn.addEventListener(MouseEvent.CLICK, onChangeSoundStatus, false, 0, true);
			mainMenu.musicBtn.addEventListener(MouseEvent.CLICK, onChangeMusicStatus, false, 0, true);
			UpdateSndBtns();
		}
		
		private function onChangeMusicStatus(e:MouseEvent):void 
		{
			App.isMusicOn = !App.isMusicOn;
			App.soundManager.changeMusicMode();
			UpdateSndBtns();
		}
		
		private function onChangeSoundStatus(e:MouseEvent):void 
		{
			App.isSoundOn = !App.isSoundOn;
			App.soundManager.changeSoundsMode();
			UpdateSndBtns();
		}
		
		private function HiScorePage():void 
		{
			mainMenu.gotoAndStop(LABEL_HI_SCORE);
			mainMenu.backBtn.addEventListener(MouseEvent.CLICK, onHiScore_TO_MainMenu, false, 0, true);
			mainMenu.soundBtn.addEventListener(MouseEvent.CLICK, onChangeSoundStatus, false, 0, true);
			mainMenu.musicBtn.addEventListener(MouseEvent.CLICK, onChangeMusicStatus, false, 0, true);
			UpdateSndBtns();
		}
				
		private function CreditsPage():void 
		{
			mainMenu.gotoAndStop(LABEL_CREDITS);
			mainMenu.backBtn.addEventListener(MouseEvent.CLICK, onCredits_TO_MainMenu, false, 0, true);
			mainMenu.soundBtn.addEventListener(MouseEvent.CLICK, onChangeSoundStatus, false, 0, true);
			mainMenu.musicBtn.addEventListener(MouseEvent.CLICK, onChangeMusicStatus, false, 0, true);
			UpdateSndBtns();
		}
		
		private function onHiScore_TO_MainMenu(e:MouseEvent):void 
		{
			mainMenu.soundBtn.removeEventListener(MouseEvent.CLICK, onChangeSoundStatus, false);
			mainMenu.musicBtn.removeEventListener(MouseEvent.CLICK, onChangeMusicStatus, false);
			mainMenu.backBtn.removeEventListener(MouseEvent.CLICK, onHiScore_TO_MainMenu, false);
			MainMenuPage();
		}
		
		private function onCredits_TO_MainMenu(e:MouseEvent):void 
		{
			mainMenu.soundBtn.removeEventListener(MouseEvent.CLICK, onChangeSoundStatus, false);
			mainMenu.musicBtn.removeEventListener(MouseEvent.CLICK, onChangeMusicStatus, false);
			mainMenu.backBtn.removeEventListener(MouseEvent.CLICK, onCredits_TO_MainMenu, false);
			MainMenuPage();
		}
		
		private function onMainMenu_TO_credits(e:MouseEvent):void 
		{
			removeListenersFromMainMenu();
			CreditsPage();
		}
		
		private function onMainMenu_TO_hiScore(e:MouseEvent):void 
		{
			removeListenersFromMainMenu();
			HiScorePage();
		}
		
		private function onMainMenu_TO_playGame(e:MouseEvent):void 
		{
			removeListenersFromMainMenu();
			dispatchEvent(new StartGame(StartGame.START_GAME, true, false));
		}
		
		private function removeListenersFromMainMenu():void 
		{
			mainMenu.soundBtn.removeEventListener(MouseEvent.CLICK, onChangeSoundStatus, false);
			mainMenu.musicBtn.removeEventListener(MouseEvent.CLICK, onChangeMusicStatus, false);
			mainMenu.playBtn.removeEventListener(MouseEvent.CLICK, onMainMenu_TO_playGame, false);
			mainMenu.hiscoreBtn.removeEventListener(MouseEvent.CLICK, onMainMenu_TO_hiScore, false);
			mainMenu.credits.removeEventListener(MouseEvent.CLICK, onMainMenu_TO_credits, false);
		}
		
		private function UpdateSndBtns():void 
		{
			if (App.isSoundOn)
			{
				_mainMenu.soundBtn.gotoAndStop("on");
			}
			else
			{
				_mainMenu.soundBtn.gotoAndStop("off");
			}
			if (App.isMusicOn)
			{
				_mainMenu.musicBtn.gotoAndStop("on");
			}
			else
			{
				_mainMenu.musicBtn.gotoAndStop("off");
			}
		}
		
		public function get mainMenu():MovieClip { return _mainMenu; }
		
	}

}