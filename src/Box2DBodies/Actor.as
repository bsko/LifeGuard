package  Box2DBodies
{
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author _47_
	 */
	public class Actor extends MovieClip 
	{
		
		protected var _clip:MovieClip;
		protected var _body:b2Body;
		protected var _parentClip:MovieClip;
		
		public function Init(clip:MovieClip, body:b2Body, parentClip:MovieClip = null):void
		{
			_clip = clip;
			_body = body;
			_parentClip = parentClip;
		}
		
		public function updateMyLook(e:Event = null):void
		{
			if (_body.IsAwake()) {
				if (_parentClip == null)
				{
					_clip.x = _body.GetPosition().x * App.WORLD_SCALE;
					_clip.y = _body.GetPosition().y * App.WORLD_SCALE;
					_clip.rotation = (_body.GetAngle() * App.RAD_TO_DEG) % 360;
				}
				else
				{
					var tmpPoint:Point = _parentClip.localToGlobal(new Point(_body.GetPosition().x * App.WORLD_SCALE, _body.GetPosition().y * App.WORLD_SCALE));
					_clip.x = tmpPoint.x;
					_clip.y = tmpPoint.y;
					_clip.rotation = (_body.GetAngle() * App.RAD_TO_DEG) % 360;
				}
			}
		}
		
		public function get body():b2Body { return _body; }
		
		public function get clip():MovieClip { return _clip; }
		
	}

}