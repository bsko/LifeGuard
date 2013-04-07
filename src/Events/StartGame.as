package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class StartGame extends Event 
	{
		public static const START_GAME:String = "startgame";
		public static const QUIT_GAME:String = "quitgame";
		public static const RESTART_GAME:String = "restartgame";
		
		public function StartGame(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new StartGame(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("StartGame", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}