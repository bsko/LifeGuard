package  
{
	import Events.Destroying;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class Tutorial extends Sprite
	{
		public static const TYPE_MOVING:int = 1;
		public static const TYPE_SAVE:int = 2;
		public static const TYPE_ROUNDS:int = 3;
		public static const TYPE_WISTLE:int = 4;
		public static const TYPE_ROCKET:int = 5;
		
		private var _seenMoving:Boolean = false;
		private var _seenSaving:Boolean = false;
		private var _seenRounds:Boolean = false;
		private var _seenWistle:Boolean = false;
		private var _seenRocket:Boolean = false;
		
		private var _movie:MovieClip = new TutorialMovie();
		private var _isOnScreen:Boolean = false;
		
		public function Tutorial() 
		{
			mouseEnabled = false;
			addChild(_movie);
			_movie.visible = false;
		}
		
		public function GameStarted():void
		{
			App.universe.addEventListener(Destroying.DESTROY, EndGame, false, 0, true);
		}
		
		public function ShowTutorial(type:int):void
		{
			switch(type)
			{                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
				case TYPE_SAVE:
				trace("TYPE SAVE");
				if (_seenSaving) {
					return;
				} else {
					_seenSaving = true;
				}
				break;
				case TYPE_MOVING:
				trace("TYPE_MOVING");
				if (_seenMoving) {
					return;
				} else {
					_seenMoving = true;
				}
				break;
				case TYPE_ROCKET:
				trace("TYPE_ROCKET");
				if (_seenRocket) {
					return;
				} else {
					_seenRocket = true;
				}
				break;
				case TYPE_ROUNDS:
				trace("TYPE_ROUNDS");
				if (_seenRounds) {
					return;
				} else {
					_seenRounds = true;
				}
				break;
			}
			App.gameInterface.Pause();
			_isOnScreen = true;
			_movie.gotoAndStop(type);
			_movie.visible = true;
			_movie.next_btn.addEventListener(MouseEvent.CLICK, onClose, false, 0, true);
		}
		
		private function onClose(e:MouseEvent = null):void 
		{
			_isOnScreen = false;
			_movie.next_btn.removeEventListener(MouseEvent.CLICK, onClose, false);
			_movie.visible = false;
			App.gameInterface.Unpause();
		}
		
		public function EndGame(e:Destroying = null):void
		{
			if (_isOnScreen) { onClose(); }
			App.universe.removeEventListener(Destroying.DESTROY, EndGame, false);
		}
	}

}