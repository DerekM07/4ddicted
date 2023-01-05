module Addicted

@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "ProcessStatusEffects " + ToString(actionEffects));
    wrappedMethod(actionEffects, gameInstance);
}

@wrapMethod(RestedEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let system = GameInstance.GetTimeSystem(scriptInterface.GetGame());
    LogChannel(n"DEBUG", "OnEnter " + ToString(system.GetGameTimeStamp()));
    wrappedMethod(stateContext, scriptInterface);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID())) \(ToString(evt.staticData.StatusEffectType().Type()))");
    return wrappedMethod(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    if evt.IsAddictive() {
        LogChannel(n"DEBUG","RED:Addicted:OnStatusEffectRemoved (IsAddictive)");
    }
    return wrappedMethod(evt);
}

// Game.GetPlayer():JustSomeSound(CName.new('vfx_fullscreen_memory_boost_activate'))
// Game.GetPlayer():JustSomeSound(CName.new('quickhack_sonic_shock'))
// Game.GetPlayer():JustSomeSound(CName.new('quickhack_request_backup'))
// Game.GetPlayer():JustSomeSound(CName.new('quickhack_synapse_burnout'))
@addMethod(PlayerPuppet)
public func JustSomeSound(sound: CName) -> Void {
    // e.g. n"vfx_fullscreen_memory_boost_activate"
    GameObject.PlaySoundEvent(this, sound);
}

// Game.GetPlayer():JustSomeVisual(CName.new('reflex_buster'))
// Game.GetPlayer():JustSomeVisual(CName.new('splinter_buff'))
// Game.GetPlayer():JustSomeVisual(CName.new('mask_explode'))
// Game.GetPlayer():JustSomeVisual(CName.new('status_blinded'))
// Game.GetPlayer():JustSomeVisual(CName.new('status_bleeding'))
// Game.GetPlayer():JustSomeVisual(CName.new('hacks_overheat_lvl2'))
// gamedataStatusEffectFX_Record
@addMethod(PlayerPuppet)
public func JustSomeVisual(visual: CName) -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, visual);
}

// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.Overload'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.PlayerPoisoned'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.PlayerExhausted'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.QuickHackBlind'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.HeartAttack')) // lethal!
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.BorgStun'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.Stun'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.DrillingShakeNormal'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.AutoLocomotion'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.DrillingShakeMedium'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.WithdrawalCrisis'))
@addMethod(PlayerPuppet)
public func JustSomeEffect(effect: TweakDBID) -> Void {
    StatusEffectHelper.ApplyStatusEffect(this, effect);
}

// Game.GetPlayer():ClearEffect(TweakDBID.new('BaseStatusEffect.DrillingShakeMedium'))
@addMethod(PlayerPuppet)
public func ClearEffect(effect: TweakDBID) -> Void {
    StatusEffectHelper.RemoveStatusEffect(this, effect);
}

// Game.GetPlayer():JustADopeFiend()
// Game.GetPlayer():SlowStun()
@addMethod(PlayerPuppet)
public func JustADopeFiend() -> Void {
    // doesn't work for some reason (but works if manually planned, see addiction system)
    // StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.BreathingHeavy");
    // let breath = new ApplyNewStatusEffectEvent();
    // breath.effectID = t"BaseStatusEffect.BreathingNormal";
    // let stun = new ApplyNewStatusEffectEvent();
    // stun.effectID = t"BaseStatusEffect.BorgStun";
    // let shake = new ApplyNewStatusEffectEvent();
    // shake.effectID = t"BaseStatusEffect.DrillingShakeMedium";
    // let system = GameInstance.GetDelaySystem(this.GetGame());
    // system.DelayEvent(this, stun, 3.0, true);
    // system.DelayEvent(this, stun, 6.0, true);
    // system.DelayEvent(this, breath, 12.0, true);
}