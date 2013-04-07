package pool
{
	//base
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.getTimer;
	import data.structures.*;
	//custom
	import data.structures.QueueNode;
	/**
	 * ...
	 * @author GG.Gurov samoh inc
	 */
	public class Pool
	{
		private static const LIMIT_TIME:int = 30000;
		private static const COEEF_INIT_SIZE:Number = 1.2;
		
		private var _factory:ObjectPoolFactory;
		
		private var _initSize:int = 0;
		private var _currSize:int = 0;
		private var _usageCount:int = 0;
		
		private var _grow:Boolean;
		private var _lastGrowTime:int;
		private var _head:QueueNode;
		private var _tail:QueueNode;
		
		private var _emptyNode:QueueNode;
		private var _allocNode:QueueNode;
		
		private var _params:Array;
		private var _initFunc:String;
		
		public function Pool(grow:Boolean = false) {
			_grow = grow;
		}
		//allocate functions
		public function allocateByClassName(className:String, size:uint, applicationDomain:ApplicationDomain = null):void {
			if (!applicationDomain) applicationDomain = ApplicationDomain.currentDomain;
			if (applicationDomain.hasDefinition(className)) {
				allocate(size, applicationDomain.getDefinition(className) as Class);
			} else {
				throw new Error("custom error: Application domain dont contain indicate defination");
			}
		}
		public function allocateByFactory(customFactory:ObjectPoolFactory, size:uint):void {
			_factory = customFactory;
			allocate(size);
		}
		public function allocate(size:uint, instanseDefination:Class = null):void {
			if (_usageCount > 0) {
				throw Error("custom error: Not all objects returned in pool. Probably leak of memory.");
			}
			if (size == 0) {
				throw Error("custom error: Size of pool can not be equal zero");
			}
			if(_head) {
				deconstruct();
			}
			
			if (instanseDefination) {
				_factory = new ObjectPoolFactory(instanseDefination);
			} else {
				if(_factory) {
					throw new Error("custom error: Nothing to instantiate");	
				}
			}
			
			_initSize = size;
			
			shadowAllocate();
		}
		private function shadowAllocate():void {
			var i:int;
			if (!_head) {
				_head = new QueueNode(_factory.create());
				_tail = _head;
				_emptyNode = _head;
				_allocNode = _head;
				_currSize = _initSize;
			} else {
				_currSize = _currSize + _initSize;
				_tail.next = new QueueNode(_factory.create());
				_tail = _tail.next; 
				_allocNode = _tail;
			}
			
			var tempQueueNode:QueueNode;
			for (i = 1; i < _initSize; i++) {
				tempQueueNode = new QueueNode(_factory.create());
				_tail.next = tempQueueNode;
				_tail = tempQueueNode; 
			}
			
			_tail.next = _head;
			_lastGrowTime = getTimer();
		}
		//destructor
		public function deconstruct():void {
			var tempQueueNode:QueueNode;
			
			while (_head) {
				tempQueueNode = _head.next;
				_head.next = null;
				_head.data = null;
				_head = tempQueueNode;
			}
			
			_tail = null;
			_emptyNode = null
			_allocNode = null;
		}
		public function purge(e:Event = null):void{
			_currSize = _usageCount;
			_head = _emptyNode;
			_allocNode = _emptyNode;
			_tail = _head;
			
			var i:int = 1;
			while (i < _usageCount) {
				_tail = _tail.next;
				i++;
			}
			
			var tempHead:QueueNode = _tail.next;
			var tempNext:QueueNode;
			while (tempHead.data) {
				tempNext = tempHead.next;
				tempHead.next = null;
				tempHead.data = null;
				tempHead = tempNext;
			}
			_tail.next = _head;
		}
		//various size geters/seters
		public function get size():int {
			return _currSize;
		}
		public function get initSize():int {
			return _initSize;
		}
		public function get usageSize():int {
			return _usageCount;
		}
		public function get wasteSize():int {
			return _currSize - _usageCount;	
		}
		public function get object():* {
			if (_usageCount == _currSize) {
				trace("Pool: size maximum");
				if (_grow) {
					trace("Pool: grow is available");
					var deltaTime:int = getTimer() -  _lastGrowTime;
					trace("Pool: pass time " + deltaTime);
					if (deltaTime < LIMIT_TIME) {
						trace("Pool: quikly pass time, increase delta size");
						_initSize = Math.floor(_initSize * COEEF_INIT_SIZE);
					}
					shadowAllocate();
					trace("Pool: new size " + _currSize);
					return object;
				}
 				else {
					throw new Error("custom error: Object pool exhausted.");
				}
			}
			else {
				var returnObject:* = _allocNode.data;
				_allocNode.data = null;
				_allocNode = _allocNode.next;
				_usageCount++;
				/*if (returnObject is BlueDino)
				{
					trace("getter", usageSize, _usageCount, _currSize);
				}*/
				return returnObject;
			}
		}
		public function set object(exhaustedObject:*):void {
			if (_usageCount > 0) {
				_usageCount--;
				_emptyNode.data = exhaustedObject;
				_emptyNode = _emptyNode.next;
				/*if (exhaustedObject is BlueDino)
				{
					trace("setter", usageSize, _usageCount, _currSize);
				}*/
			} else if (_usageCount == 0) {
				throw new Error("custom error: All objects returned in pool.");
			}
		}
		public function init(initFunc:String, params:Array):void {
			var i:int = 0;
			var tempNode:QueueNode = _head;
			
			while (i < _currSize) {
				tempNode.data[initFunc](params);
				tempNode = tempNode.next;
				i++;
			}
		}
	}
}

import pool.ObjectPoolFactory;
internal class ObjectPoolFactory
{
	private var _class:Class;
	
	public function ObjectPoolFactory(C:Class)
	{
		_class = C;
	}

	public function create():*
	{
		return new _class();
	}
}