package ashgame.components {
	import ashgame.graphics.EnergyStorageView;
	
	public class EnergyStorage {
		public var maxEnergy:Number;
		public var energy:Number;
		
		public function EnergyStorage(maxEnergy:Number = 0, energy:Number = 0) {
			this.maxEnergy = maxEnergy;
			this.energy = energy;
		}
	}
}
