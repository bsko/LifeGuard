package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class SingleWaveDestroying extends Event 
	{
		public static const DESTROY_ME:String = "destroyme";
		
		
		public function SingleWaveDestroying(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new SingleWaveDestroying(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SingleWaveDestroying", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}