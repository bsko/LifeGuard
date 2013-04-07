package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author GG.Gurov - samoh
	 */
	public class SoundsControlEvent extends Event 
	{
		public static const CHANGE_MUSIC_MODE:String = "changemusicmode";
		public static const CHANGE_SOUNDS_MODE:String = "changesoundsmode";
		
		private var _soundStatus:Boolean = false;
		
		public function SoundsControlEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, newSoundStatus:Boolean = false) 
		{ 
			super(type, bubbles, cancelable);
			_soundStatus = newSoundStatus;
		} 
		
		public override function clone():Event 
		{ 
			return new SoundsControlEvent(type, bubbles, cancelable, _soundStatus);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SoundsControlEvent", "type", "bubbles", "cancelable", "eventPhase", "_soundStatus"); 
		}
		
		public function get soundStatus():Boolean { return _soundStatus; }
		
		public function set soundStatus(value:Boolean):void {
			_soundStatus = value;
		}
		
	}
	
}