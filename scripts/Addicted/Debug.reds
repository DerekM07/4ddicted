import Addicted.Threshold
import Addicted.System.AddictedSystem

// use like: Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("BaseStatusEffect.FirstAidWhiffV0"), 40);
@addMethod(PlayerPuppet)
public func DebugSwitchThreshold(id: TweakDBID, threshold: Int32) -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame()) as AddictedSystem;
  system.DebugSwitchThreshold(id, IntEnum(threshold));
}

// use like: Game.GetPlayer():DebugThresholds();
@addMethod(PlayerPuppet)
public func DebugThresholds() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame()) as AddictedSystem;
  system.DebugThresholds();
}

// use like: Game.GetPlayer():DebugClear();
@addMethod(PlayerPuppet)
public func DebugClear() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame()) as AddictedSystem;
  system.DebugClear();
}