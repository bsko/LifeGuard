package  Box2DBodies
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author _47_
	 */
	public class ReverseActor extends MovieClip
	{
		
		protected var _clip:MovieClip;
		protected var _body:b2Body;
		
		public function InitBody(clip:MovieClip, body:b2Body):void
		{
			_clip = clip;
			_body = body;
		}
		
		public function updateMyBody(e:Event = null):void
		{
			var point:Point = new Point(0, 0);
			var pos:b2Vec2 = new b2Vec2(0, 0);
			pos.x = _clip.localToGlobal(point).x / App.WORLD_SCALE;
			pos.y = _clip.localToGlobal(point).y / App.WORLD_SCALE;
			_body.SetPosition(pos);
			//_body.SetAngle(_clip.parent.rotation * App.DEG_TO_RAD);
		}
		
		public function get clip():MovieClip { return _clip; }
		
		public function get body():b2Body { return _body; }
		
	}

}