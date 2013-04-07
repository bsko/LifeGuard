package 
{
	import Events.StartGame;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import Interface.*;
	/**
	 * ...
	 * @author 
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{

		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			App.stage = stage;
			App.universe = new Universe();
			App.mainInterface = new MainInterface();
			App.gameInterface = new GameInterface();
			App.soundManager = new SoundsManager();
			App.soundManager.initSounds();
			App.rootMC = this;
			App.InitPool();
			App.InitGenerator();
			App.InitColorsArray();
			App.InitCheTo();
			startMainMenu();
		}
		
		private function startMainMenu():void 
		{
			addChild(App.mainInterface);
			App.mainInterface.Init();
			App.mainInterface.addEventListener(StartGame.START_GAME, onStartGame, false, 0, true);
		}
		
		private function onStartGame(e:StartGame):void 
		{
			removeChild(App.mainInterface);
			App.mainInterface.removeEventListener(StartGame.START_GAME, onStartGame, false);
			addChild(App.universe);
			App.universe.Init();
			addChild(App.gameInterface);
			App.gameInterface.Init();
			App.gameInterface.addEventListener(StartGame.QUIT_GAME, onQuitGame, false, 0, true);
			App.gameInterface.addEventListener(StartGame.RESTART_GAME, onRestartGame, false, 0, true);
		}
		
		private function onRestartGame(e:StartGame):void 
		{
			App.gameInterface.removeEventListener(StartGame.QUIT_GAME, onQuitGame, false);
			App.gameInterface.removeEventListener(StartGame.RESTART_GAME, onRestartGame, false);
			App.universe.Destroy();
			App.universe.Init();
			App.gameInterface.Init();
			App.gameInterface.addEventListener(StartGame.QUIT_GAME, onQuitGame, false, 0, true);
			App.gameInterface.addEventListener(StartGame.RESTART_GAME, onRestartGame, false, 0, true);
		}
		
		private function onQuitGame(e:StartGame):void 
		{
			App.gameInterface.removeEventListener(StartGame.QUIT_GAME, onQuitGame, false);
			App.gameInterface.removeEventListener(StartGame.RESTART_GAME, onRestartGame, false);
			App.universe.Destroy();
			removeChild(App.universe);
			removeChild(App.gameInterface);
			addChild(App.mainInterface);
			App.mainInterface.Init();
			App.mainInterface.addEventListener(StartGame.START_GAME, onStartGame, false, 0, true);
		}
	}

}