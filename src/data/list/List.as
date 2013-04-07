package data.list
{
	import flash.net.FileReferenceList;
	import system.data.structures.DLinkedNode;
	/**
	 * ...
	 * @author GG.Gurov samoh inc
	 */
	public class List
	{
		private var _countIterators:uint = 0;
		internal var _size:uint = 0;
		
		internal var head:DLinkedNode = new HeadNode();
		internal var tail:DLinkedNode = new TailNode();
		
		public function List(formedData:Array = null):void {
			head = new HeadNode();
			tail = new TailNode();
			head.next = tail;
			tail.prev = head;

			if(formedData) {
				_size = formedData.length;
				if (_size > 0) {
					var tempHead:DLinkedNode = new DLinkedNode(formedData[0]);
					var tempTail:DLinkedNode = head;
					
					if (_size > 1) {
						for (var indexData:int = 1; indexData < _size; indexData++) {
							tempTail.next = new DLinkedNode(formedData[indexData]);
							tempTail.next.prev = tempTail;
							tempTail = tempTail.next;
						}
					}
					
					head.next = tempHead;
					tempHead.prev = head;
					tempTail.next = tail;
					tail.prev = tempTail;
				}
			}
		}
		public function clone():List {
			var cloneData:Array = new Array();
			var navigationHead:DLinkedNode = head.next;
			var indexData:uint = 0;
			
			while (!(navigationHead is TailNode)) {
				cloneData[indexData] = navigationHead.data;
				navigationHead = navigationHead.next;
				indexData++;
			}
			return new List(cloneData);
		}
		public function destructor():void {
			if (_countIterators) {
				throw Error("list error. {destructor method} not all iterators returned in List");
			}
			var tempHead:DLinkedNode = head;
			while (head) {
				tempHead = head.next;
				head.prev = null;
				head.next = null;
				head.data = null;
				//возможно здесь стоит вызывать метод у data если data реализует интерфейс IDestructed
				head = tempHead;
			}
			tail = null;
			_size = 0;
		}
		//actions with data structura
		internal function cut(iterator:ListIterator, cutNodes:uint):List {
			var cutList:List;
			if ((cutNodes > 0) && (_size > 0)) {
				var cutListHead:DLinkedNode = iterator.node;
				var cutListTail:DLinkedNode = iterator.node;
				var sizeCutList:uint = 1;
				
				while (!(cutListTail.next is TailNode)  && ((cutNodes - sizeCutList) > 0)) {
					cutListTail = cutListTail.next;
					sizeCutList++;
				}
				if (sizeCutList == _size) {
					head.next = tail;
					tail.prev = head;
					iterator.node = head;
				} else {
					if (cutListHead.prev) {
						cutListHead.prev.next = cutListTail.next;
					} else {
						head = cutListTail.next;
					}
					if (cutListTail.next) {
						cutListTail.next.prev = cutListHead.prev;
					} else {
						tail = cutListHead.prev;
					}
					cutListHead.prev = null;
					cutListTail.next = null;
				}
				cutList = new List();
				cutList.head = cutListHead;
				cutList.tail = cutListTail;
				_size -= sizeCutList;
				cutList._size = sizeCutList;
			}
			return cutList;
		}
		internal function copy(iterator:ListIterator, copyNodes:uint):List {
			var copyList:List;
			if ((copyNodes > 0) && (_size > 0)) {
				var copyNode:DLinkedNode = iterator.node;
				var sizeCopyList:uint = 0;
				var copyData:Array = new Array();
				
				while ((copyNode != null) && ((copyNodes - sizeCopyList) > 0)) {
					copyData[sizeCopyList] = copyNode.data;
					copyNode = copyNode.next;
					sizeCopyList++;
				}
				copyList = new List(copyData);
			}
			return copyList;
		}
		internal function pasteDataAfter(iterator:ListIterator, data:*):void {
			var pasteNode:DLinkedNode = new DLinkedNode(data);
			if (_size > 0) {
				var firstBreakNode:DLinkedNode = iterator.node;
				var secondBreakNode:DLinkedNode = iterator.node.next;
				firstBreakNode.next = pasteNode;
				pasteNode.prev = firstBreakNode;
				if (secondBreakNode) {
					pasteNode.next = secondBreakNode;
					secondBreakNode.prev = pasteNode;
				} else {
					tail = pasteNode;
				}
			} else {
				iterator.node = pasteNode;
				head = pasteNode;
				tail = pasteNode;
			}
			_size++;
		}
		internal function pasteDataBefore(iterator:ListIterator, data:*):void {
			var pasteNode:DLinkedNode = new DLinkedNode(data);
			if (_size > 0) {
				var firstBreakNode:DLinkedNode = iterator.node.prev;  
				var secondBreakNode:DLinkedNode = iterator.node;
				if (firstBreakNode) {
					firstBreakNode.next = pasteNode;
					pasteNode.prev = firstBreakNode;
				} else {
					head = pasteNode;
				}
				pasteNode.next = secondBreakNode;
				secondBreakNode.prev = pasteNode;
			} else {
				iterator.node = pasteNode;
				head = pasteNode;
				tail = pasteNode;
			}
			_size++;
		}
		internal function pasteListAfter(iterator:ListIterator, pasteList:List):void {
			if (pasteList.size > 0) {
				pasteList = pasteList.clone();
				if (_size > 0) {
					var firstBreakNode:DLinkedNode = iterator.node;
					var secondBreakNode:DLinkedNode = iterator.node.next;
					firstBreakNode.next = pasteList.head;
					pasteList.head.prev = firstBreakNode;	
					if (secondBreakNode) {
						pasteList.tail.next = secondBreakNode;
						secondBreakNode.prev = pasteList.tail;
					} else {
						tail = pasteList.tail;
					}
				} else {
					head = pasteList.head;
					tail = pasteList.tail;
				}
				_size += pasteList.size;
			}
		}
		internal function pasteListBefore(iterator:ListIterator, pasteList:List):void {
			if (pasteList.size > 0) {
				pasteList = pasteList.clone();
				if (_size > 0) {
					var firstBreakNode:DLinkedNode = iterator.node.prev;  
					var secondBreakNode:DLinkedNode = iterator.node;	
					if (firstBreakNode) {
						firstBreakNode.next = pasteList.head;
						pasteList.head.prev = firstBreakNode;
					} else {
						head = pasteList.head;
					}
					pasteList.tail.next = secondBreakNode;
					secondBreakNode.prev = pasteList.tail;
				} else {
					head = pasteList.head;
					tail = pasteList.tail;
				}
				_size += pasteList.size;
			}
		}
		public function append(appendData:Array):void {
			if(appendData.length > 0) {
				var appendList:List = new List(appendData);
				if (_size > 0) {
					tail.next = appendList.head;
					appendList.head.prev = tail;
				} else {
					head = appendList.head;
				}
				tail = appendList.tail;
				_size += appendList.size;
			}
		}
		public function prepend(prependData:Array):void {
			if (prependData.length > 0) {
				var prependList:List = new List(prependData);
				if (_size > 0) {
					head.prev = prependList.tail;
					prependList.tail.next = head;
				} else {
					tail = prependList.tail;
				}
				head = prependList.head;
				_size += prependList.size;
			}
		}
		internal function pasteBlockAfter(iterator:ListIterator, pasteData:Array):List {
			var pasteList:List = new List(pasteData);
			pasteListAfter(iterator, pasteList);
			return pasteList;
		}
		internal function pasteBlockBefore(iterator:ListIterator, pasteData:Array):List {
			var pasteList:List = new List(pasteData);
			pasteListBefore(iterator, pasteList);
			return pasteList;
		}
		internal function unlink():void {
			
		}
		//system commands
		public function getIterator(copyListIterator:ListIterator = null):ListIterator {
			_countIterators++;
			if (copyListIterator) {
				return new ListIterator(this, copyListIterator.node);
			} else {
				return new ListIterator(this);
			}
		}
		internal function deleteIterator():void {
			_countIterators--;
		}
		//search
		public function contains(data:*):Boolean {
			var tempHead:DLinkedNode = head;
			while (tempHead) {
				if (tempHead.data === data) {
					return true;
				}
				tempHead = tempHead.next;
			}
			return false;
		}
		//getters and setters
		public function get countIterators():int {
			return _countIterators;
		}
		public function get size():uint {
			return _size;
		}
		public function isEmpty():Boolean {
			return _size == 0;
		}
		public function toString():String {
			var array:Array = new Array();
			var tempHead:DLinkedNode = head;
			while (tempHead) {
				array[array.length] = tempHead.data;
				tempHead = tempHead.next;
			}
			return "[List, size=" + _size + " countIterators=" + countIterators + " head=" + ((head)?head.data : null) + " tail=" + ((tail)?tail.data : null) + " data=" + array + "]";
		}
		//static methods
		static public function concat(...lists):List {
			var countLists:uint = lists.length;
			var allData:Array = new Array();
			var indexAllData:uint = 0;
			var indexList:uint = 0;
			
			if(countLists > 0) {
				for (indexList = 0; indexList < countLists; indexList++) {
					var tempHead:DLinkedNode = lists[indexList].head;
					while(tempHead) {
						allData[indexAllData] = tempHead.data;
						tempHead = tempHead.next;
						indexAllData++;
					}
				}
			}
			return new List(allData);
		}
	}

}