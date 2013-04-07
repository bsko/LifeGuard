package data.structures 
{
	/**
	 * ...
	 * @author GG.Gurov samoh inc
	 */
	public class QueueNode
	{
		public var next:QueueNode;
		public var data:*;
		
		public function QueueNode(data:*)
		{
			this.data = data;
			next = null;
		}
		public function insertAfter(node:QueueNode):void
		{
			node.next = next;
			next = node;		
		}
		public function toString():String
		{
			return "[QueueNode, data=" + data + "]";
		}
	}
}