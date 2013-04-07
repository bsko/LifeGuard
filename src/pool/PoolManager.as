package pool 
{
	/**
	 * ...
	 * @author GG.Gurov samoh inc
	 */
	public class PoolManager
	{
		private var _size:int;
		private var _pools:Object = {};
		
		public function PoolManager(size:int = 100) {
			_size = size;
		}
		public function addPool(id:String, initClass:Class, sizePool:int = 100):Pool {
			var tmpPool:Pool = new Pool(false);
			tmpPool.allocate(sizePool, initClass);
			_pools[id] = tmpPool;
			return tmpPool;
		}
		
		public function initPool(id:String, initFunc:String, params:Array):void {
			_pools[id].init(initFunc, params);
		}
		public function getPoolObject(id:String):* {
			return _pools[id].object;
		}
		public function returnPoolObject(id:String, obj:*):void {
			_pools[id].object = obj;
		}
		public function getPool(id:String):Pool {
			return _pools[id];
		}
		
	}

}