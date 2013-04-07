package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class PauseEvent extends Event 
	{
		public static const PAUSE:String = "pause";
		public static const UNPAUSE:String = "unpause";
		
		public function PauseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new PauseEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PauseEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}