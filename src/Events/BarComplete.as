package Events 
{
	import flash.events.Event;
	import Interface.BonusBar;
	
	/**
	 * ...
	 * @author 
	 */
	public class BarComplete extends Event 
	{
		
		public static const BAR_COMPLETE:String = "barcomplete";
		
		private var _bar:BonusBar;
		private var _bonusType:int;
		
		public function BarComplete(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bonusBar:BonusBar = null, bonusType:int = -1) 
		{ 
			super(type, bubbles, cancelable);
			_bar = bonusBar;
			_bonusType = bonusType;
		} 
		
		public override function clone():Event 
		{ 
			return new BarComplete(type, bubbles, cancelable, bar);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("BarComplete", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get bar():BonusBar { return _bar; }
		
		public function set bar(value:BonusBar):void 
		{
			_bar = value;
		}
		
		public function get bonusType():int { return _bonusType; }
		
		public function set bonusType(value:int):void 
		{
			_bonusType = value;
		}
		
	}
	
}