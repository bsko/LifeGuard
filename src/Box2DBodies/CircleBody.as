package Box2DBodies
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author _47_
	 */
	public class CircleBody extends Actor 
	{
		public static const NAME:String = "CircleBody";
		private var _bDynamic:Boolean;
		private var _bDensity:Number;
		private var _bFriction:Number;
		private var _bRestitution:Number;
		
		public function InitBody(sprite:Sprite, isDynamic:Boolean  = false, bDensity:Number = 1, bFriction:Number = 0, bRestitution:Number = 0) :void
		{
			_bDynamic = isDynamic;
			_bDensity = bDensity;
			_bFriction = bFriction;
			_bRestitution = bRestitution;
			Init(MovieClip(sprite), drawCircle(sprite));
		}
		
		private function drawCircle(sprite:Sprite):b2Body
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(sprite.x/App.WORLD_SCALE, sprite.y/App.WORLD_SCALE);
			if (_bDynamic) {
				myBody.type = b2Body.b2_dynamicBody;
			}
			var myBall:b2CircleShape = new b2CircleShape(sprite.width/2/App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			myFixture.density = _bDensity;
			myFixture.friction = _bFriction;
			myFixture.restitution =  _bRestitution;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			return worldBody;
		}	
	}
}