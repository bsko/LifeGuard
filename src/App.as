package  
{
	import Bonuses.Bonus;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2World;
	import Box2DBodies.Ball;
	import Box2DBodies.BlackRect;
	import Box2DBodies.CircleBody;
	import Box2DBodies.ContactListener;
	import Box2DBodies.SensorToSwim;
	import Box2DBodies.SensorToWalk;
	import Box2DBodies.SquareBody;
	import flash.display.Stage;
	import flash.geom.Point;
	import Interface.*;
	import pool.*;
	import data.*;
	import Rockets.Rocket;
	import Rounds.FlyingRound;
	import Rounds.ROund;
	import Waves.*;
	import Bodies.*;
	import shark.*;
	/**
	 * ...
	 * @author 
	 */
	public class App 
	{
		public static const STAGE_WIDTH:int = 640;
		public static const STAGE_HEIGHT:int = 480;
		public static const STAGE_HALF_WIDTH:int = STAGE_WIDTH / 2;
		public static const STAGE_HALF_HEIGHT:int = STAGE_HEIGHT / 2;
		public static const STAGE_WIDTH_TO_HEIGHT:Number = STAGE_HEIGHT / STAGE_WIDTH;
		
		public static const DIFFICULTY_TO_START_ROUNDS:int = 1;
		public static const DIFFICULTY_TO_START_SHARKS:int = 3;
		public static const DIFFICULTY_TO_START_ROCKETS:int = 4;
		public static const DIFFICULTY_TO_START_BONUSES:int = 5;
		
		public static const DEG_TO_RAD:Number = Math.PI / 180;
		public static const RAD_TO_DEG:Number = 180 / Math.PI;
		public static const MAX_DEATHS_COUNT:int = 5;
		
		public static const MULTI_FOR_SHARKS:int = 25;
		public static const POINTS_FOR_SHARK:int = 75;
		public static const POINTS_FOR_GIRL:int = 100;
		public static const POINTS_FOR_MAN:int = 60;
		// экземпляры базовых классов
		public static var universe:Universe;
		public static var mainInterface:MainInterface;
		public static var gameInterface:GameInterface;
		public static var stage:Stage;
		public static var pools:PoolManager;
		public static var rootMC:Main;
		public static var soundManager:SoundsManager;
		
		public static var isSoundOn:Boolean = true;
		public static var isMusicOn:Boolean = true;
		public static var colorsArray:Array = [];
		
		public static var world:b2World = new b2World(new b2Vec2(0, 0), true);
		static public var WORLD_SCALE:int = 30;
		public static var world_step:Number = 1 / WORLD_SCALE;
		public static var contact_listener:b2ContactListener = new ContactListener();
		
		public static function InitCheTo():void 
		{
			world.SetContactListener(contact_listener);
		}
		
		public static function InitPool():void 
		{
			pools = new PoolManager();
			pools.addPool(Wave.NAME, Wave, 300);
			pools.addPool(Body.NAME, Body, 25);
			pools.addPool(Buyok.NAME, Buyok, 40);
			pools.addPool(Shark.NAME, Shark, 25);
			pools.addPool(Bonus.NAME, Bonus, 25);
			pools.addPool(ROund.NAME, ROund, 25);
			pools.addPool(Rocket.NAME, Rocket, 25);
			pools.addPool(FlyingRound.NAME, FlyingRound, 10);
			pools.addPool(FlyingBullet.NAME, FlyingBullet, 10);
			pools.addPool(Ball.NAME, Ball, 20);
			pools.addPool(BlackRect.NAME, BlackRect, 40);
			pools.addPool(SensorToSwim.NAME, SensorToSwim, 20);
			pools.addPool(SensorToWalk.NAME, SensorToWalk, 20);
			pools.addPool(BonusBar.NAME, BonusBar, 10);
			pools.addPool(PopupMessage.NAME, PopupMessage, 5);
		}
		
		public static function InitColorsArray():void 
		{
			colorsArray.length = 0;
			colorsArray.push(0xF57900);
			colorsArray.push(0xEDD400);
			colorsArray.push(0xFCE94F);
			colorsArray.push(0xC4A000);
			colorsArray.push(0xFCAF3E);
			colorsArray.push(0xF57900);
			colorsArray.push(0x73D216);
			colorsArray.push(0x4E9A06);
			colorsArray.push(0x729FCF);
			colorsArray.push(0x204A87);
			colorsArray.push(0x0063E2);
			colorsArray.push(0x103AC1);
		}
		
		public static function InitGenerator():void 
		{
			universe.waveGenerator = new WaveGenreator();
		}
		
		public static function randomInt(a:int, b:int):int 
		{
			if (a > b) { 
				throw(Error("invalid variables"));
			}
			if (a == b) {
				return a;
			}
			return int((Math.random() * (b - a)  + a));
		}
		
		public static function angleFinding(currentPoint:Point, nextPoint:Point):Number 
		{
			var angle:Number;
			angle = (Math.atan((nextPoint.x - currentPoint.x) / (nextPoint.y - currentPoint.y)) * 180 / Math.PI);
			angle = 360 - angle;
			if (nextPoint.y >= currentPoint.y) { angle += 180; } 
			return angle;
		}
	}

}