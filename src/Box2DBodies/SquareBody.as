package Box2DBodies
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.engine.GroupElement;
	/**
	 * ...
	 * @author _47_
	 */
	public class SquareBody extends Actor 
	{
		public static const NAME:String = "SquareBody";
		private var _bDynamic:Boolean;
		private var _bAngle:Number;
		private var _bDensity:Number;
		private var _bFriction:Number;
		private var _bRestitution:Number;
		private var _sensor:Boolean;
		private var _ud:String;
		private var _rotation:Number;
		
		public function InitBody(sprite:MovieClip, parentMovie:MovieClip = null, isDynamic:Boolean = false, bDensity:Number = 1, bFriction:Number = 0, bRestitution:Number = 0, sensor:Boolean = false, ud:String = null):void
		{
			_bDynamic = isDynamic;
			_bAngle = sprite.rotation * App.DEG_TO_RAD;
			_bDensity = bDensity;
			_bFriction = bFriction;
			_bRestitution = bRestitution;
			_sensor = sensor;
			_ud = ud;
			_rotation = sprite.rotation;
			sprite.rotation = 0;
			Init(sprite, drawBody(sprite), parentMovie);
			sprite.rotation = _rotation;
		}
		
		private function drawBody(sprite:Sprite):b2Body
		{
			var px:Number = sprite.x/ App.WORLD_SCALE;
			var py:Number = sprite.y/ App.WORLD_SCALE;
			var w:Number = sprite.width/ App.WORLD_SCALE;
			var h:Number = sprite.height/ App.WORLD_SCALE;
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