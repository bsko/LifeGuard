package data.structures 
{
	/**
	 * ...
	 * @author GG.Gurov samoh inc
	 */
	public class DLinkedNode
	{
		public var next:DLinkedNode = null;
		public var prev:DLinkedNode = null;
		public var data:*;
		
		public function DLinkedNode(data:*) {
			this.data = data;
		}
		public function toString():String {
			return "[DLinkedNode, data=" + data + "]";
		}
		
	}

}