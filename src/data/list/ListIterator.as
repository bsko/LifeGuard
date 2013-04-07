package data.list
{
	import adobe.utils.CustomActions;
	import flash.net.FileReferenceList;
	import system.data.structures.DLinkedNode;
	/**
	 * ...
	 * @author GG.Gurov
	 */
	public class ListIterator
	{
		private var _list:List;
		internal var node:DLinkedNode;
		
		//constructors and destructors
		public function ListIterator(list:List, node:DLinkedNode = null) {
			_list = list;
			if (node) {
				node = node;
			} else {
				goToHead();
			}
		}
		public function clone():ListIterator {
			return _list.getIterator(this);
		}
		public function destructor():void {
			_list.deleteIterator();
			_list = null;
			node = null;
		}
		//actions with data structura
		public function pasteDataAfter(data:*):void {
			_list.pasteDataAfter(this, data);
		}
		public function pasteDataBefore(data:*):void {
			_list.pasteDataBefore(this, data);
		}
		public function pasteListAfter(pasteList:List):void {
			_list.pasteListAfter(this, pasteList);
		}
		public function pasteListBefore(pasteList:List):void {
			_list.pasteListBefore(this, pasteList);
		}
		public function pasteBlockAfter(pasteData:Array):List {
			return _list.pasteBlockAfter(this, pasteData);
		}
		public function pasteBlockBefore(pasteData:Array):List {
			return _list.pasteBlockBefore(this, pasteData);
		}
		public function cut(cutNodes:uint = uint.MAX_VALUE):List {
			return _list.cut(this, cutNodes);
		}
		public function copy(copyNodes:uint = uint.MAX_VALUE):List {
			return _list.copy(this, copyNodes);
		}
		//navigation
		public function goToTail():void {
			node = _list.tail;
		}
		public function goToHead():void {
			node = _list.head;
		}
		public function goTo(indexNode:uint):Boolean {
			if(_list.size > 0) {
				var currentIndexNode:uint = 0;
				var tempNode:DLinkedNode = _list.head;
				node = _list.head;
				
				while ((indexNode - currentIndexNode) > 0) {
					if(node.next) {
						node = node.next;
						currentIndexNode++;
					} else {
						node = tempNode;
						return false;
					}
				}
				return true;
			}
			return false;
		}
		public function next(step:uint = 1):Boolean {
			if (_list.size > 1) {
				var newNodePointer:DLinkedNode = node;
				while (step) {
					step--;
					if (node.next) {
						newNodePointer = newNodePointer.next;
					} else {
						return false;
					}
				}
				node = newNodePointer;
				return true;
			} 
			return false;
		}
		public function prev(step:uint = 1):Boolean {
			if(_list.size > 1) {
				var newNodePointer:DLinkedNode = node;
				while (step) {
					step--;
					if (node.prev) {
						newNodePointer = newNodePointer.prev;
					} else {
						return false;
					}
				}
				node = newNodePointer;
				return true;
			} 
			return false;
		}
		public function isEnd():Boolean {
			return Boolean(node.next);
		}
		public function ibBegin():Boolean {
			return Boolean(node.prev);
		}
		//search
		public function nodeOf(searchData:*):Boolean {
			if(_list.size > 0) {
				while (true) {
					if (node.data === searchData) {
						return true;
					}
					if(node.next) {
						node = node.next;
					} else {
						return false;
					}
				}
			}
			return false;
		}
		public function lastNodeOf(searchData:*):Boolean {
			if(_list.size > 0) {
				while (true) {
					if (node.data === searchData) {
						return true;
					}
					if(node.prev) {
						node = node.prev;
					} else {
						return false;
					}
				}
			}
			return false;
		}
		//getters and setters
		public function get data():* {
			return node.data;
		}
		public function set data(data:*):void {
			node.data = data;
		}
		public function get list():List {
			return _list;
		}
		public function toString():String {
			return ("[ListIterator, list=" + _list + " dataPointer=" + ((node)?node.data : null) + "]");
		}
	}

}