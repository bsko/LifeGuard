package Box2DBodies 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Events.Destroying;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class SensorToWalk extends Sprite
	{
		public static const NAME:String = "SensorToWalk";
		private var _point:Point;
		private var _body:b2Body;
		private var _clip:MovieClip;
		
		private var _bDynamic:Boolean;
		private var _bAngle:Number;
		private var _bDensity:Number;
		private var _bFriction:Number;
		private var _bRestitution:Number;
		private var _sensor:Boolean;
		private var _ud:String;
		private var _rotation:Number;
		private var _universe:Universe;
		
		public function SensorToWalk() 
		{
			
		}
		
		public function Init(movie:MovieClip, point:Point, isDynamic:Boolean = false, bDensity:Number = 1, bFriction:Number = 0, bRestitution:Number = 0, sensor:Boolean = true, ud:String = null):void
		{
			_universe = App.universe;
			_clip = movie;
			_point = point;
			_bDynamic = isDynamic;
			_bAngle = _clip.rotation * App.DEG_TO_RAD;
			_bDensity = bDensity;
			_bFriction = bFriction;
			_bRestitution = bRestitution;
			_sensor = sensor;
			_ud = ud;
			_rotation = _clip.rotation;
			_clip.rotation = 0;
			_body = MakeBody();
			_body.SetUserData(this);
			_clip.alpha = 0;
			_universe.addEventListener(Destroying.DESTROY, onDestroy, false, 0, true);
			updateLook();
			_clip.rotation = _rotation;
		}
		
		private function updateLook():void 
		{
			
		}
		
		private function onDestroy(e:Destroying):void 
		{
			App.pools.returnPoolObject(NAME, this);
			App.world.DestroyBody(_body);
			_universe.removeEventListener(Destroying.DESTROY, onDestroy, false);
		}
		
		private function MakeBody():b2Body
		{
			var px:Number = _point.x/ App.WORLD_SCALE;
			var py:Number = _point.y/ App.WORLD_SCALE;
			var w:Number = _clip.width/ App.WORLD_SCALE;
			var h:Number = _clip.height/ App.WORLD_SCALE;
			var myBody:b2BodyDef = new b2BodyDef();
			if (_bDynamic) {
				myBody.type = b2Body.b2_dynamicBody;
			}
			myBody.position.Set(px , py );
			var myBox:b2PolygonShape = new b2PolygonShape();
			myBox.SetAsBox(w / 2 , h / 2);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBox;
			myFixture.density = _bDensity;
			myFixture.friction = _bFriction;
			myFixture.restitution =  _bRestitution;
			myFixture.isSensor = _sensor;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			worldBody.SetAngle(_bAngle);
			worldBody.SetUserData(_ud);
			return worldBody;
		}
	}

}