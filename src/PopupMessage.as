package  
{
	import Events.Destroying;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class PopupMessage extends Sprite
	{
		public static const MOVIE_LENGTH:int = 40;
		public static const NAME:String = "PopupMessage";
		public static const TYPE_INCREASED_SCORE:int = 101;
		public static const TYPE_DECREASED_SCORE:int = 102;
		public static const TYPE_ADD_BONUS:int = 103;
		
		private var _popupMovie:MovieClip = new PopupMovie();
		private var _layer:Sprite = App.universe.bonusesSprite;
		private var _counter:int;
		private var _type:int;
		private var _string:String;
		
		public function PopupMessage() 
		{
			addChild(_popupMovie);
			_counter = 0;
		}
		
		public function Init(x_coord:int, y_coord:int, type:int, string:String):void 
		{
			_type = type;
			_string = string;
			switch(_type)
			{
				case TYPE_ADD_BONUS:
				_popupMovie.gotoAndStop("addBonus");
				break;
				case TYPE_INCREASED_SCORE:
				_popupMovie.gotoAndStop("addScore");
				break;
				case TYPE_DECREASED_SCORE:
				_popupMovie.gotoAndStop("minusScore");
				break;
			}
			_popupMovie.clip.text.text = _string;
			x = x_coord;
			y = y_coord;
			_layer.addChild(this);
			
			addEventListener(Event.ENTER_FRAME, onCheck, false, 0, true);
			App.universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
		}
		
		private function onCheck(e:Event):void 
		{
			_counter++;
			_popupMovie.clip.gotoAndStop(_counter);
			if (_counter == MOVIE_LENGTH)
			{
				Destroy();
			}
		}
		
		public function Destroy(e:Destroying = null):void 
		{
			removeEventListener(Event.ENTER_FRAME, onCheck, false);
			App.universe.removeEventListener(Destroying.DESTROY, Destroy, false);
			_layer.removeChild(this);
			x = -100;
			y = -100;
			_counter = 0;
			App.pools.returnPoolObject(NAME, this);
		}
	}

}