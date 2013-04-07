package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class Destroying extends Event 
	{
		
		public static const DESTROY:String = "destroy";
		
		public function Destroying(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new Destroying(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("Destroy", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}