package data.tree 
{
	import flash.system.System.data.list.List;
	/**
	 * ...
	 * @author GG.Gurov
	 */
	public class TreeNode
	{
		internal var _parent:TreeNode;
		internal var _children:List;
		
		public function TreeNode(parent:TreeNode = null) {
			_children = new List();
			
			if (parent != null) {
				_parent = parent;
				_parent.children.append(this);
			}
		}
		public function deconstruct():void {
			while (_children.head) {
				var node:TreeNode = children.head.data;
				children.removeHead();
				node.clear();
			}
		}
		//geters/setters methods
		public function get parent():TreeNode {
			return _parent;
		}
		public function get children():DLinkedList {
			return _children;
		}
		//statistic
		public function get size():int
		{
			var currSize:int = 1;
			var tempDListNode:DListNode = children.head;
			while (tempDListNode)
			{
				currSize += TreeNode(tempDListNode.data).size;
				tempDListNode = tempDListNode.next;
			}
			return currSize;
		}
		public function get depth():int
		{
			if (parent == null) return 0;
			
			var tempTreeNode:TreeNode = this;
			var currDepth:int = 0;
			while (tempTreeNode.parent)
			{
				currDepth++;
				tempTreeNode = tempTreeNode.parent;
			}
			return currDepth;
		}
		public function get numChildren():int
		{
			return children.size;
		}
		public function get numSiblings():int
		{
			if (parent == null) {
				return 0;		
			} else {
				return parent.children.size;
			}
		}
		//boolean tests
		public function isRoot():Boolean {
			return parent == null;
		}
		public function isLeaf():Boolean {
			return children.size == 0;
		}
		public function hasChildren():Boolean {
			return children.size > 0;
		}
		public function hasSiblings():Boolean {
			if (parent == null) {
				return  false; 
			} else {
				return parent.children.size > 1;
			}
		}
		
	}

}