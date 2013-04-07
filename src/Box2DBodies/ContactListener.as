package Box2DBodies 
{
	import Bodies.Body;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author 
	 */
	public class ContactListener extends b2ContactListener 
	{
		
		private var fixtureA:b2Fixture;
		private var fixtureB:b2Fixture;
		private var bodyA:b2Body;
		private var bodyB:b2Body;
		
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void 
		{
			/*fixtureA = contact.GetFixtureA();
			fixtureB = contact.GetFixtureB();
			bodyA = fixtureA.GetBody();
			bodyB = fixtureB.GetBody();*/
		}
		
		override public function BeginContact(contact:b2Contact):void 
		{
			fixtureA = contact.GetFixtureA();
			fixtureB = contact.GetFixtureB();
			bodyA = fixtureA.GetBody();
			bodyB = fixtureB.GetBody();
			
			if (bodyB.GetUserData() is Ball)
			{
				if ((!(bodyA.GetUserData() is SensorToSwim)) && (!(bodyA.GetUserData() is SensorToWalk)))
				{
					GivaAccelToBall(bodyA, bodyB); 
				}
			}
			else if (bodyA.GetUserData() is Ball)
			{
				if ((!(bodyB.GetUserData() is SensorToSwim)) && (!(bodyB.GetUserData() is SensorToWalk)))
				{
					GivaAccelToBall(bodyB, bodyA); 
				}
			}
			else if (bodyA.GetUserData() is Hero && bodyB.GetUserData() is SensorToSwim)
			{
				CheckIfHeroWalking(bodyA.GetUserData() as Hero);
			}
			else if (bodyB.GetUserData() is Hero && bodyA.GetUserData() is SensorToSwim)
			{
				CheckIfHeroWalking(bodyB.GetUserData() as Hero);
			}
			else if (bodyA.GetUserData() is Hero && bodyB.GetUserData() is SensorToWalk)
			{
				CheckIfHeroSwimming(bodyA.GetUserData() as Hero);
			}
			else if (bodyB.GetUserData() is Hero && bodyA.GetUserData() is SensorToWalk)
			{
				CheckIfHeroSwimming(bodyB.GetUserData() as Hero);
			}
			else if (bodyA.GetUserData() is Body && bodyB.GetUserData() is SensorToWalk)
			{
				SwithcBodyState(bodyA.GetUserData() as Body);
			}
			else if (bodyB.GetUserData() is Body && bodyA.GetUserData() is SensorToWalk)
			{
				SwithcBodyState(bodyB.GetUserData() as Body);
			}
		}
		
		private function SwithcBodyState(body:Body):void 
		{
			if (body.isHaveARound)
			{
				body.bodyMovie.gotoAndStop(Body.LABEL_RUNNING);
				
				
				var bonusScore:int;
				if (body.model == "girl")
				{
					bonusScore = App.POINTS_FOR_GIRL * App.universe.multiplier * (App.universe.saved_bodies_count / 20 + 0.5);
				}
				else if (body.model == "man")
				{
					bonusScore = App.POINTS_FOR_MAN * App.universe.multiplier * (App.universe.saved_bodies_count / 20 + 0.5);
				}
				var string:String = "+" + bonusScore.toString();
				
				var a:PopupMessage = App.pools.getPoolObject(PopupMessage.NAME);
				a.Init(body.x, body.y, PopupMessage.TYPE_INCREASED_SCORE, string);
				
				App.universe.score += bonusScore;
				App.universe.saved_bodies_count++;
			}
		}
		
		private function CheckIfHeroWalking(hero:Hero):void
		{
			if (hero.state != Hero.HERO_IS_ON_WATER)
			{
				hero.state = Hero.HERO_IS_ON_WATER;
				hero.updateState();
			}
		}
		
		private function CheckIfHeroSwimming(hero:Hero):void
		{
			if (hero.state != Hero.HERO_IS_ON_SAND)
			{
				hero.state = Hero.HERO_IS_ON_SAND;
				hero.updateState();
			}
		}
		
		private function GivaAccelToBall(heroBody:b2Body, ballBody:b2Body):void
		{
			var tmpBall:Ball = ballBody.GetUserData() as Ball;
			var vec:b2Vec2 = new b2Vec2((ballBody.GetPosition().x - heroBody.GetPosition().x) * 10, (ballBody.GetPosition().y - heroBody.GetPosition().y) * 10);
			ballBody.SetLinearVelocity(vec);
			tmpBall.IsVelocited();
		}
	}

}