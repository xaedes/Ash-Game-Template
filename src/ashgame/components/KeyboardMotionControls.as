package ashgame.components {
	
	public class KeyboardMotionControls {
		// keycodes
		public var left:uint = 0;
		public var right:uint = 0;
		public var up:uint = 0;
		public var down:uint = 0;
		
		public var accelerationRate:Number = 0;
		
		public function KeyboardMotionControls(left:uint, right:uint, up:uint, down:uint, accelerationRate:Number) {
			this.left = left;
			this.right = right;
			this.up = up;
			this.down = down;
			this.accelerationRate = accelerationRate;
		}
	}
}
