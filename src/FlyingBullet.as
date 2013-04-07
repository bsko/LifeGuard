package  
{
	import Bodies.Body;
	import Bodies.BodyGenerator;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import shark.Shark;
	import shark.SharkGenerator;
	/**
	 * ...
	 * @author 
	 */
	public class FlyingBullet extends Sprite
	{
		public static const NAME:String = "FlyingBullet";
		public static const DISTANCE_TO_KILL:int = 30;
		public static const SHLEIF_DELAY_X:int = 10;
		public static const MAX_RADIUS:int = 7;
		public static const MIN_RADIUS:int = 4;
		
		private var _flyingBullet:MovieClip = new ShellMovie();
		private var _hero:Hero;
		private var _destination:Point = new Point();
		private var _currentPosition:Point;
		private var _distance:Number;
		private var _layer:Sprite;
		private var _step:Number;
		private var _speed:Number = 10;
		private var _universe:Universe;
		
		public function Init(hero:Hero, destinationPt:Point, layer:Sprite):void 
		{
			_universe = App.universe;
			_layer = layer;
			_hero = hero;
			addChild(_flyingBullet);
			_flyingBullet.gotoAndStop("standart");
			_layer.addChild(this);
			_currentPosition = new Point(_hero.x, _hero.y);
			var delay:int = Point.distance(_currentPosition, destinationPt) / 10;
			_destination.x = destinationPt.x + (Math.random() * delay * 2) - delay;
			_destination.y = destinationPt.y + (Math.random() * delay * 2) - delay;
			_distance = Point.distance(_currentPosition, _destination);
			_step = 1 / (_distance / _speed);
			this.rotation = App.angleFinding(_currentPosition, _destination);
			addEventListener(Event.ENTER_FRAME, onUpdateFlyingBullet, false, 0, true);
			_universe.addEventListener(Destroying.DESTROY, onDestroying, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			addEventListener(Event.ENTER_FRAME, onUpdateFlyingBullet, false, 0, true);
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, onUpdateFlyingBullet, false);
		}
		
		private function onDestroying(e:Destroying):void 
		{
			Destroy();
		}
		
		private function onUpdateFlyingBullet(e:Event):void 
		{
			_step += 1 / (_distance / _speed);
			var tmpPoint:Point = Point.interpolate(_destination, _currentPosition, _step);
			var scale:Number = 1.25 - Math.abs(_step - 0.5)/2;
			this.x = tmpPoint.x;
			this.y = tmpPoint.y;
			if(searchForBodies())
			{
				return;
			}
			
			var tmpKryzhochek:Sprite = new Sprite();
			var tmpColor:int = App.colorsArray[App.randomInt(0, App.colorsArray.length + 1)];
			var radius:int = App.randomInt(MIN_RADIUS, MAX_RADIUS);
			var tmpCirclePoint:Point = new Point(tmpPoint.x + Math.random() * SHLEIF_DELAY_X - SHLEIF_DELAY_X / 2, tmpPoint.y + Math.random() * SHLEIF_DELAY_X - SHLEIF_DELAY_X / 2);
			
			tmpKryzhochek.graphics.beginFill(tmpColor);
			tmpKryzhochek.graphics.drawCircle(tmpCirclePoint.x, tmpCirclePoint.y, radius);
			tmpKryzhochek.graphics.endFill();
			tmpKryzhochek.addEventListener(Event.ENTER_FRAME, onUpdateKryzhochek, false, 0, true);
			tmpKryzhochek.alpha = 0.7;
			_layer.addChild(tmpKryzhochek);
			
			if (Point.distance(tmpPoint, _currentPosition) > 1000)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdateFlyingBullet, false);
				Destroy();
			}
		}
		
		private function onUpdateKryzhochek(e:Event):void 
		{
			var tmpSprite:Sprite = (e.currentTarget as Sprite);
			tmpSprite.alpha -= 0.05;
			if (tmpSprite.alpha <= 0)
			{
				_layer.removeChild(tmpSprite);
				tmpSprite.removeEventListener(Event.ENTER_FRAME, onUpdateKryzhochek, false);
			}
		}
		
		private function searchForBodies():Boolean 
		{
			var curPoint:Point = new Point(this.x, this.y);
			var sharksArray:Array = SharkGenerator.sharksArray;
			var length:int = sharksArray.length;
			var tmpShark:Shark;
			for (var i:int = 0; i < length; i++)
			{
				tmpShark = sharksArray[i];
				var distance:int = Point.distance(curPoint, new Point(tmpShark.x, tmpShark.y));
				if (distance < DISTANCE_TO_KILL)
				{
					tmpShark.Destroy();
					
					var a:PopupMessage = App.pools.getPoolObject(PopupMessage.NAME);
					var c:int = App.POINTS_FOR_SHARK + App.MULTI_FOR_SHARKS * _hero.killedSharks;
					var string:String = "+" + c.toString();
					a.Init(tmpShark.x, tmpShark.y, PopupMessage.TYPE_INCREASED_SCORE, string);
					_universe.score += c;
					_hero.killedSharks++;
					
					removeEventListener(Event.ENTER_FRAME, onUpdateFlyingBullet, false);
					App.soundManager.playSound("sharkDeathSnd");
					_flyingBullet.gotoAndStop("bang");
					_flyingBullet.bangMovie.gotoAndPlay(1);
					_flyingBullet.bangMovie.addEventListener("bang", onBanged, false, 0, true);
					return true;
				}
			}
			
			var bodiesArray:Array = BodyGenerator.bodiesArray;
			length = bodiesArray.length;
			var tmpBody:Body;
			for (i = 0; i < length; i++)
			{
				tmpBody = bodiesArray[i];
				if (!tmpBody.isDead && !tmpBody.movedToSavingState)
				{
					distance = Point.distance(curPoint, new Point(tmpBody.x, tmpBody.y));
					if (distance < DISTANCE_TO_KILL)
					{
						tmpBody.aplyRocket();
						removeEventListener(Event.ENTER_FRAME, onUpdateFlyingBullet, false);
						_flyingBullet.gotoAndStop("bang");
						_flyingBullet.bangMovie.gotoAndPlay(1);
						_flyingBullet.bangMovie.addEventListener("bang", onBanged, false, 0, true);
						return true;
					}
				}
			}
			return false;
		}
		
		private function onBanged(e:Event):void 
		{
			_flyingBullet.bangMovie.removeEventListener("bang", onBanged, false);
			Destroy();
		}
		
		public function Destroy():void 
		{
			x = -500;
			y = -500;
			if (_flyingBullet.currentFrameLabel == "bang")
			{
				_flyingBullet.bangMovie.removeEventListener("bang", onBanged, false);
			}
			removeChild(_flyingBullet);
			if (_layer.contains(this))
			{
				_layer.removeChild(this);
			}
			_flyingBullet.gotoAndStop("standart");
			_currentPosition = null;
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateFlyingBullet, false);
			_universe.removeEventListener(Destroying.DESTROY, onDestroying, false);
			App.pools.returnPoolObject(NAME, this);
		}
		

	}

}