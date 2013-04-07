package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class Abilities extends Event 
	{
		
		public static const PISTOL:String = "pistol";
		public static const ROUND:String = "round";
		public static const WISTLE:String = "wistle";
		
		public function Abilities(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new Abilities(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("Abilities", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}