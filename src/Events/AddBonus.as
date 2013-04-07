package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class AddBonus extends Event 
	{
		public static const NEW_BONUS:String = "newbonus";
		private var _bType:int;
		
		public function AddBonus(type:String, bubbles:Boolean=false, cancelable:Boolean=false, b_type:int = -1) 
		{ 
			super(type, bubbles, cancelable);
			_bType = b_type;
		} 
		
		public override function clone():Event 
		{ 
			return new AddBonus(type, bubbles, cancelable, _bType);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("AddBonus", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get bType():int {  return _bType; }
		
		public function set bType(value:int):void 
		{
			_bType = value;
		}
		
	
	}
	
}