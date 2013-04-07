package Box2DBodies 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Events.Destroying;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class Ball extends Sprite
	{
		public static const NAME:String = "Ball";
		private var _b_movie:MovieClip = new ball_movie();
		private var _b_body:b2Body;
		private var _b_point:Point;
		
		private var _clip:MovieClip;
		
		private var _bDynamic:Boolean;
		private var _bAngle:Number;
		private var _bDensity:Number;
		private var _bFriction:Number;
		private var _bRestitution:Number;
		private var _sensor:Boolean;
		private var _ud:String;
		private var _rotation:Number;
		
		private var _isVelocited:Boolean;
		private var _x_velocity:Number;
		private var _y_velocity:Number;
		private var _develocity_vec:b2Vec2;
		private var _universe:Universe;
		
		public function Ball() 
		{
			_b_movie.gotoAndStop(int(Math.random() * 3) + 1);
			addChild(_b_movie);
		}
		
		public function Init(movie:MovieClip, point:Point, isDynamic:Boolean = true, bDensity:Number = 0.1, bFriction:Number = 0, bRestitution:Number = 1, sensor:Boolean = false, ud:String = null):void
		{
			_isVelocited = false;
			_universe = App.universe;
			_clip = movie;
			_b_point = point;
			
			_bDynamic = isDynamic;
			_bAngle = _clip.rotation * App.DEG_TO_RAD;
			_bDensity = bDensity;
			_bFriction = bFriction;
			_bRestitution = bRestitution;
			_sensor = sensor;
			_ud = ud;
			_rotation = _clip.rotation;
			
			_b_body = MakeBody();
			_b_body.SetUserData(this);
			_clip.alpha = 0;
			_universe.addEventListener(Destroying.DESTROY, onDestroy, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateLook, false, 0, true);
		}
		
		private function onDestroy(e:Destroying):void 
		{
			if (_isVelocited)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdateDevelocity, false);
			}
			App.world.DestroyBody(_b_body);
			_universe.removeEventListener(Destroying.DESTROY, onDestroy, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateLook, false);
			App.pools.returnPoolObject(NAME, this);
		}
		
		public function IsVelocited():void 
		{
			_isVelocited = true;
			addEventListener(Event.ENTER_FRAME, onUpdateDevelocity, false, 0, true);
		}
		
		private function onUpdateDevelocity(e:Event):void 
		{
			var vec:b2Vec2 = _b_body.GetLinearVelocity();
			_x_velocity = vec.x * 0.9;
			_y_velocity = vec.y * 0.9;
			_develocity_vec = new b2Vec2(_x_velocity, _y_velocity);
			_b_body.SetLinearVelocity(_develocity_vec);
			if ((Math.abs(vec.x) < 0.05) && (Math.abs(vec.y) < 0.05))
			{
				_b_body.SetLinearVelocity(new b2Vec2(0, 0));
				removeEventListener(Event.ENTER_FRAME, onUpdateDevelocity, false);
			}
		}
		
		private function onUpdateLook(e:Event):void 
		{
			this.x = _b_body.GetPosition().x * App.WORLD_SCALE;
			this.y = _b_body.GetPosition().y * App.WORLD_SCALE;
		}
		
		private function MakeBody():b2Body
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(_b_point.x/App.WORLD_SCALE, _b_point.y/App.WORLD_SCALE);
			if (_bDynamic) {
				myBody.type = b2Body.b2_dynamicBody;
			}
			var myBall:b2CircleShape = new b2CircleShape(_clip.width/2/App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			myFixture.density = _bDensity;
			myFixture.friction = _bFriction;
			myFixture.restitution =  _bRestitution;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			return worldBody;
		}
		
		public function get b_body():b2Body { return _b_body; }
		
		public function set b_body(value:b2Body):void 
		{
			_b_body = value;
		}
	}

}