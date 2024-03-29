package ashgame {
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.fsm.EntityState;
	import ash.fsm.EntityStateMachine;
	import flash.display.DisplayObject;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import ashgame.components.AlphaTween;
	import ashgame.components.Anchor;
	import ashgame.components.Attractable;
	import ashgame.components.Attracting;
	import ashgame.components.Attractor;
	import ashgame.components.AttractorController;
	import ashgame.components.Audio;
	import ashgame.components.AutoResizingRectView;
	import ashgame.components.Breakable;
	import ashgame.components.CanBeContainedInMembranChains;
	import ashgame.components.Circle;
	import ashgame.components.CircleCircleCollision;
	import ashgame.components.Collision;
	import ashgame.components.Display;
	import ashgame.components.DistanceConstraint;
	import ashgame.components.EnergyCollecting;
	import ashgame.components.EnergyParticle;
	import ashgame.components.EnergyProducer;
	import ashgame.components.EnergyStorage;
	import ashgame.components.EnergyStorageEmitter;
	import ashgame.components.EnergyStorageWarning;
	import ashgame.components.FitCircleToSize;
	import ashgame.components.FitSizeAroundOtherEntity;
	import ashgame.components.GameState;
	import ashgame.components.Gravity;
	import ashgame.components.HasEnergyStorageView;
	import ashgame.components.Lifetime;
	import ashgame.components.Mass;
	import ashgame.components.Membran;
	import ashgame.components.MembranChain;
	import ashgame.components.MembranChainOrderedEntities;
	import ashgame.components.MembranChainSpatialUpdate;
	import ashgame.components.MembranChainUpdateOrderedEntities;
	import ashgame.components.Motion;
	import ashgame.components.KeyboardMotionControls;
	import ashgame.components.MouseMotionControls;
	import ashgame.components.Mover;
	import ashgame.components.Padding;
	import ashgame.components.Player;
	import ashgame.components.Position;
	import ashgame.components.PositionTween;
	import ashgame.components.Radar;
	import ashgame.components.Redrawing;
	import ashgame.components.RemoveOtherEntitiesOnRemoval;
	import ashgame.components.Size;
	import ashgame.components.SolidCollision;
	import ashgame.components.SpatialHashed;
	import ashgame.components.StateMachine;
	import ashgame.components.Text;
	import ashgame.components.Autosize;
	import ashgame.components.Timer;
	import ashgame.components.UpdateCircleView;
	import ashgame.components.UpdateLabeledCircle;
	import ashgame.components.UpdateTextView;
	import ashgame.easing.Easing;
	import ashgame.graphics.CircleView;
	import ashgame.graphics.ContainerView;
	import ashgame.graphics.EnergyParticleView;
	import ashgame.graphics.EnergyProducerView;
	import ashgame.graphics.LabeledCircleView;
	import ashgame.graphics.LineView;
	import ashgame.graphics.MembranPartView;
	import ashgame.graphics.MoverView;
	import ashgame.graphics.RectView;
	import ashgame.graphics.Redrawable;
	import ashgame.graphics.TextView;
	
	public class EntityCreator {
		private var engine:Engine;
		private var config:GameConfig;
		
		public function EntityCreator(engine:Engine, config:GameConfig) {
			this.engine = engine;
			this.config = config;
		}
		
		public function destroyEntity(entity:Entity):void {
			if (entity.has(RemoveOtherEntitiesOnRemoval)) {
				var removeOtherEntitiesOnRemoval:RemoveOtherEntitiesOnRemoval = RemoveOtherEntitiesOnRemoval(entity.get(RemoveOtherEntitiesOnRemoval));
				while (removeOtherEntitiesOnRemoval.entitiesToRemove.length > 0) {
					var otherEntity:Entity = removeOtherEntitiesOnRemoval.entitiesToRemove.pop();
					engine.removeEntity(otherEntity);
				}
			}
			engine.removeEntity(entity);
		}
		
		public function createGame():Entity {
			var gameEntity:Entity = new Entity("game");
			gameEntity.add(new GameState());
			engine.addEntity(gameEntity);
			return gameEntity;
		}
		
		public function createPlayer():Entity {
			var entity:Entity = new Entity();
			
			var radius:Number = 20;
			var density:Number = 1000;
			
			var pos:Point = new Point(config.width / 2, config.height / 2);
			
			var attractor:Entity = createAttractor(radius * 10, 5);
			attractor.add(new Anchor(entity));
			attractor.add(new AttractorController(Keyboard.SPACE));
			
			var moverView:MoverView = new MoverView(radius);
			with (entity) {
				add(new Player());
				add(new Position(pos.x, pos.y));
				add(new Size(new Point(radius * 2, radius * 2), Size.ALIGN_CENTER_CENTER));
				add(new Circle(radius));
				add(new Display(moverView));
				add(new Mover(0.001));
				//add(new Mover(0.0));
				add(new Motion(0, 0, 0.95));
				add(new EnergyStorage(10, 5));
				add(new HasEnergyStorageView(moverView.energyStorageView));
				add(new KeyboardMotionControls(Keyboard.A, Keyboard.D, Keyboard.W, Keyboard.S, 1000));
				//add(new MouseMotionControls(100));
				add(new EnergyStorageEmitter(0.01, radius + 3, 0, 30, 0, 2, 5));
				add(new Audio());
				add(new EnergyStorageEmitter(0.1, radius + 3, 1, 10, 0, 1, 1));
				add(new Mass(radius * radius * Math.PI * density));
				add(new Collision());
				add(new CircleCircleCollision());
				add(new SolidCollision(0.9));
				add(new EnergyCollecting());
				add(new SpatialHashed());
				add(new EnergyStorageWarning(0.3, 2, 1));
				add(new CanBeContainedInMembranChains());
			}
			
			engine.addEntity(entity);
			return entity;
		}
		
		public function createEnergyParticle(energyAmount:Number = 1):Entity {
			var entity:Entity = new Entity();
			
			var radius:Number = 2;
			var density:Number = 0.1;
			var pos:Point = new Point(Utils.randomRange(0, config.width), Utils.randomRange(0, config.height));
			
			//var view:CircleView = new CircleView(radius, 0xFFF4BA);
			var view:EnergyParticleView = new EnergyParticleView(entity);
			with (entity) {
				add(new Position(pos.x, pos.y));
				add(new Size(new Point(radius * 2, radius * 2), Size.ALIGN_CENTER_CENTER));
				add(new Circle(radius));
				add(new Redrawing(view));
				add(new Display(view));
				add(new Motion(Utils.randomRange(-10, 10), Utils.randomRange(-10, 10), 0.999));
				add(new EnergyStorage(energyAmount, energyAmount));
				add(new Collision());
				add(new CircleCircleCollision());
				add(new EnergyParticle());
				add(new SpatialHashed());
				add(new Mass(radius * radius * Math.PI * density));
				add(new SolidCollision(0.6));
				add(new Timer());
				add(new Lifetime(5));
				add(new Attractable(-1));
				//add(new Gravity(new Point(config.width / 2, 3 * config.height / 4), 5));
				add(new CanBeContainedInMembranChains());
			}
			
			engine.addEntity(entity);
			return entity;
		}
		
		public function createEnergyProducer():Entity {
			var entity:Entity = new Entity();
			
			var radius:Number = 10;
			var density:Number = 1;
			var _maxEnergy:Number = Utils.randomRange(5, 15);
			var pos:Point = new Point(Utils.randomRange(0, config.width), Utils.randomRange(0, config.height));
			
			var energyProducerView:EnergyProducerView = new EnergyProducerView(radius);
			with (entity) {
				add(new Position(pos.x, pos.y));
				add(new Size(new Point(radius * 2, radius * 2), Size.ALIGN_CENTER_CENTER));
				add(new Circle(radius));
				add(new Display(energyProducerView));
				add(new Motion(Utils.randomRange(-50, 50), Utils.randomRange(-50, 50), 0.985));
				add(new EnergyStorage(_maxEnergy, Utils.randomRange(0, _maxEnergy)));
				add(new Collision());
				add(new CircleCircleCollision());
				//add(new EnergyProducer(0.1, 0.03));
				add(new EnergyProducer(0.1, 0.2));
				add(new EnergyStorageEmitter(0.01, radius + 3, 0, 30, 1, 2, 5));
				add(new HasEnergyStorageView(energyProducerView.energyStorageView));
				add(new Mass(radius * radius * Math.PI * density));
				add(new SolidCollision(0.95));
				add(new EnergyCollecting());
				add(new SpatialHashed());
				add(new Attractable(1));
				add(new Gravity(new Point(config.width / 2, 1 * config.height / 4), 3));
				add(new CanBeContainedInMembranChains());
			}
			engine.addEntity(entity);
			return entity;
		}
		
		public function createRadar(radius:Number):Entity {
			var entity:Entity = new Entity();
			engine.addEntity(entity);
			
			var view:CircleView = new CircleView(radius, 0xFFFFFF, 0.1);
			with (entity) {
				add(new Position(0, 0));
				add(new Size(new Point(radius * 2, radius * 2), Size.ALIGN_CENTER_CENTER));
				add(new Circle(radius));
				add(new Display(view));
				add(new Collision());
				add(new CircleCircleCollision());
				add(new SpatialHashed());
			}
			return entity;
		}
		
		public function createMembranPart():Entity {
			var entity:Entity = new Entity();
			
			var radius:Number = 10;
			var radarRadius:Number = 20;
			var density:Number = 2;
			
			var pos:Point = new Point(Utils.randomRange(0, config.width), Utils.randomRange(0, config.height));
			
			var radar:Entity = createRadar(radarRadius);
			radar.add(new Anchor(entity));
			
			var chain:Entity = createMembranChain();
			
			var membranPartView:MembranPartView = new MembranPartView(radius);
			with (entity) {
				add(new Position(pos.x, pos.y));
				add(new Size(new Point(radius * 2, radius * 2), Size.ALIGN_CENTER_CENTER));
				add(new Circle(radius));
				add(new SpatialHashed());
				add(new Mass(radius * radius * Math.PI * density));
				add(new SolidCollision(1));
				add(new Collision());
				add(new CircleCircleCollision());
				add(new Display(membranPartView));
				add(new Motion(Utils.randomRange(-50, 50), Utils.randomRange(-50, 50), 0.95));
				add(new Radar(radar));
				add(new Membran(chain));
				add(new Attractable(1));
				add(new CanBeContainedInMembranChains());
				add(new Audio());
			}
			
			MembranChain(chain.get(MembranChain)).addPart(entity);
			
			engine.addEntity(entity);
			return entity;
		}
		
		public function createMembranChain():Entity {
			var entity:Entity = new Entity();
			//var view:RectView = new RectView(null, 0xFFFFFF, 0.1);
			with (entity) {
				add(new MembranChain());
				add(new Position(0, 0));
				add(new Size(new Point(), Size.ALIGN_TOP_LEFT));
				add(new MembranChainSpatialUpdate());
				add(new Collision());
				add(new SpatialHashed());
				//add(new Display(view));
				//add(new Redrawing(view));
				//add(new AutoResizingRectView(view));
				add(new MembranChainOrderedEntities());
				add(new MembranChainUpdateOrderedEntities());
			}
			engine.addEntity(entity);
			return entity;
		}
		
		public function createConnection(entity1:Entity, entity2:Entity, distance:Number = 10):Entity {
			if (!(entity1.has(Position) && entity2.has(Position))) {
				return null;
			}
			
			var entity:Entity = new Entity();
			
			var pos1:Position = Position(entity1.get(Position));
			var pos2:Position = Position(entity2.get(Position));
			
			var view:LineView = new LineView(pos1.position, pos2.position, 0.5 * 2 * 0.6 * 10, 0x35AAFF);
			with (entity) {
				add(new Position(0, 0));
				add(new Redrawing(view));
				add(new Display(view));
				add(new DistanceConstraint(entity1, entity2, distance, 1, 0.45));
				add(new Breakable(distance * 3));
			}
			
			engine.addEntity(entity);
			return entity;
		}
		
		public function createAttractor(radius:Number, strength:Number):Entity {
			var entity:Entity = createRadar(radius);
			entity.remove(Display);
			entity.remove(Collision);
			var state:EntityState;
			var fsm:EntityStateMachine = new EntityStateMachine(entity);
			
			var view:CircleView = new CircleView(radius, 0xFFFFFF, 0.1);
			state = fsm.createState("active");
			with (state) {
				add(Attracting).withInstance(new Attracting(strength));
				add(Collision).withInstance(new Collision());
				add(Display).withInstance(new Display(view));
				
			}
			state = fsm.createState("inactive");
			with (state) {
				// empty
			}
			
			with (entity) {
				add(new Attractor());
				add(new StateMachine(fsm));
			}
			fsm.changeState("inactive");
			return entity;
		}
		
		public function createText(text:String = "", autosize:Boolean = true):Entity {
			var entity:Entity = new Entity();
			
			var view:TextView = new TextView(text);
			with (entity) {
				add(new Position(0, 0));
				add(new Display(view));
				add(new Text(text));
				add(new UpdateTextView(view));
				add(new Size(new Point(), Size.ALIGN_TOP_CENTER));
				if (autosize) {
					add(new Autosize(view));
				}
			}
			
			engine.addEntity(entity);
			return entity;
		}
		
		public function createFloatingText(text:String = "", lifetime:Number = 2, outfading_length:Number = 60):Entity {
			var entity:Entity = createText(text);
			with (entity) {
				entity.add(new Timer());
				entity.add(new Lifetime(lifetime));
				entity.add(new AlphaTween(0, lifetime, Easing.easeInOutSine));
				entity.add(new PositionTween(new Point(0, -outfading_length), lifetime, Easing.easeInOutSine));
			}
			return entity;
		}
		
		public function createCircle(radius:Number, color:uint = 0xFFFFFF, alpha:Number = 1):Entity {
			var entity:Entity = new Entity();
			var view:CircleView = new CircleView(radius, color, alpha);
			with (entity) {
				add(new Position(0, 0));
				add(new Circle(radius));
				add(new Size(new Point(radius * 2, radius * 2), Size.ALIGN_CENTER_CENTER));
				add(new Display(view));
			}
			engine.addEntity(entity);
			return entity;
		}
		
		public function createTimer():Entity {
			var entity:Entity = new Entity();
			with (entity) {
				add(new Timer());
			}
			engine.addEntity(entity);
			return entity;
		}
		
		public function createContainer(x:Number = 0, y:Number = 0):Entity {
			var entity:Entity = new Entity();
			
			var view:ContainerView = new ContainerView();
			with (entity) {
				add(new Position(x, y));
				add(new Display(view));
			}
			engine.addEntity(entity);
			return entity;
		}
		
		public function createLabeledCircle(text:String, x:Number = 0, y:Number = 0):Entity {
			var entity:Entity = new Entity();
			
			var view:LabeledCircleView = new LabeledCircleView(text);
			
			with (entity) {
				add(new Position(x, y));
				add(new Text(text));
				add(new Circle());
				add(new Padding(10));
				add(new Size(null, Size.ALIGN_CENTER_CENTER));
				add(new Autosize(view));
				
				add(new Display(view));
				add(new UpdateTextView(view.textView));
				add(new UpdateCircleView(view.circleView));
				add(new UpdateLabeledCircle(view));
				add(new Redrawing(view));
				
				add(new Collision());
				add(new CircleCircleCollision());
				add(new SpatialHashed());
			}
			
			engine.addEntity(entity);
			return entity;
		}
	}
}
