package Rounds 
{
	import Bodies.Body;
	import Bodies.BodyGenerator;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class FlyingRound extends Sprite
	{
		public static const NAME:String = "FlyingRound";
		public static const DISTANCE_TO_SAVE:int = 30;
		public static const WAITING_TIME:int = 3000;
		public static const DELAY_COUNTS:int = 60
		public static const TIMER_DELAY:int = WAITING_TIME / DELAY_COUNTS;
		
		private var _flyingRound:MovieClip = new Kryg_movie();
		private var _hero:Hero;
		private var _destination:Point = new Point();
		private var _currentPosition:Point;
		private var _distance:Number;
		private var _layer:Sprite;
		private var _step:Number;
		private var _speed:Number = 10;
		private var _waitingTimer:Timer = new Timer(TIMER_DELAY);
		private var _waitCounter:int = 0;
		private var _isFlying:Boolean;
		private var _isSearchingAndWaiting:Boolean;
		private var _isAdded:Boolean;
		
		public function Init(_hero:Hero, destinationPt:Point, layer:Sprite):void
		{
			_isSearchingAndWaiting = false;
			_isFlying = true;
			_layer = layer;
			addChild(_flyingRound);
			_layer.addChild(this);
			_currentPosition = new Point(_hero.x, _hero.y);
			var delay:int = Point.distance(_currentPosition, destinationPt) / 10;
			_destination.x = destinationPt.x + (Math.random() * delay * 2) - delay;
			_destination.y = destinationPt.y + (Math.random() * delay * 2) - delay;
			_distance = Point.distance(_currentPosition, _destination);
			_step = 1 / (_distance / _speed);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateFlyingRound, false, 0, true);
			App.universe.addEventListener(Destroying.DESTROY, onDestroy, false, 0, true);
		}
		
		private function onDestroy(e:Destroying):void 
		{
			Destroy();
		}
		
		private function onUnpauseEvent(e:PauseEvent):void 
		{
			addEventListener(Event.ENTER_FRAME, onUpdateFlyingRound, false, 0, true);
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, onUpdateFlyingRound, false);
		}
		
		private function onUpdateFlyingRound(e:Event):void 
		{
			_step += 1 / (_distance / _speed);
			var tmpPoint:Point = Point.interpolate(_destination, _currentPosition, _step);
			var scale:Number = 1.25 - Math.abs(_step - 0.5)/2;
			this.x = tmpPoint.x;
			this.y = tmpPoint.y;
			_flyingRound.scaleX = _flyingRound.scaleY = scale;
			_flyingRound.rotation += 15;
			if (_step >= 1)
			{
				_flyingRound.scaleX = _flyingRound.scaleY = 1;
				removeEventListener(Event.ENTER_FRAME, onUpdateFlyingRound, false);
				_isFlying = false;
				addEventListener(Event.ENTER_FRAME, searchForBodies, false, 0, true);
				_waitingTimer.start();
				_waitingTimer.addEventListener(TimerEvent.TIMER, onStopSearching, false, 0, true);
			}
		}
		
		private function onStopSearching(e:TimerEvent):void 
		{
			_waitCounter++;
			if (_waitCounter <= DELAY_COUNTS)
			{
				_flyingRound.alpha -= 1 / DELAY_COUNTS;
				//_flyingRound.scaleX -=  1 / DELAY_COUNTS;
				//_flyingRound.scaleY -= 1 / DELAY_COUNTS;
			}
			else
			{
				Destroy();
			}
		}
		
		private function searchForBodies(e:Event):void 
		{
			_isSearchingAndWaiting = true;
			var bodiesArray:Array = BodyGenerator.bodiesArray;
			var length:int = bodiesArray.length;
			var tmpBody:Body;
			for (var i:int = 0; i < length; i++)
			{
				tmpBody = bodiesArray[i];
				var distance:int = Point.distance(_destination, new Point(tmpBody.x, tmpBody.y));
				if (distance < DISTANCE_TO_SAVE)
				{
					if (!tmpBody.isDead)
					{
						tmpBody.takeARound();
						Destroy();
						return;
					}
				}
			}
		}
		
		public function Destroy():void
		{
			x = -500;
			y = -500;
			_flyingRound.alpha = 1;
			_waitCounter = 0;
			if (_isFlying)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdateFlyingRound, false);
				_isFlying = false;
			}
			if (_isSearchingAndWaiting)
			{
				_waitingTimer.reset();
				_waitingTimer.removeEventListener(TimerEvent.TIMER, onStopSearching, false);
				removeEventListener(Event.ENTER_FRAME, searchForBodies, false);
				_isSearchingAndWaiting = false;
			}
			removeChild(_flyingRound);
			_layer.removeChild(this);
			App.pools.returnPoolObject(NAME, this);
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onUnpauseEvent, false);
			App.universe.removeEventListener(Destroying.DESTROY, onDestroy, false);
		}
		
	}

}