// Floating Weapons Universal Power
#include "floatingweap_inc"
#include "cp_inc_debug"

void main()
{
    int nFPCost = GetSpellForcePointCost();

    location lLoc = Location(GetPosition(OBJECT_SELF) + AngleToVector(GetFacing(OBJECT_SELF)) * 3.0, GetFacing(OBJECT_SELF) - 180.0);
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, "floatsaber", lLoc);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectSpellImmunity(2), oCreature);
    CP_ListEffects(oCreature);

    effect eCheck = GetFirstEffect(oCreature);
    object oCreator = GetEffectCreator(eCheck);
    CP_DebugMsg(GetName(oCreator));

    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
    DelayCommand(3.0, ReqCheck(nFPCost, OBJECT_SELF));
}
