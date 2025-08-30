// Force Jinx force power
//
// Make an enemy attack itself lol jk doesn't work'

#include "k_inc_force"

void main()
{
    object oTarget = GetSpellTargetObject();

    SWFP_HARMFUL = TRUE;
    SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;

    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

    //int nSaves = Sp_MySavingThrows(oTarget);
    //if(nSaves == 0)
    AssignCommand(oTarget, ClearAllActions());
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAssuredHit(), oTarget, 3.0);
    AssignCommand(oTarget, ActionAttack(oTarget, TRUE));
}
