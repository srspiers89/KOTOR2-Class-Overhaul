// Force Empathy Power
//
// The target will take  d8 damage per level of caster every time they attack. Doesn't work on droids.
//
// Gives the target an Immunity to an unused force power because we don't need the power to actually do anything.
// We just check if the attacker is affected by this force power in the OnAttacked event and then apply the damage.

#include "k_inc_force"

void main()
{
    object oTarget = GetSpellTargetObject();
    effect eLink1, eLink2;
    effect eInvalid;

    SWFP_HARMFUL = TRUE;
    SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;
    SWFP_PRIVATE_SAVE_VERSUS_TYPE = SAVING_THROW_TYPE_FORCE_POWER;

    eLink1 = EffectSpellImmunity(202); // XXX_FORCE_POWER_MEDITATION
    eLink2 = EffectVisualEffect(VFX_PRO_AFFLICT);
    eLink1 = SetEffectIcon(eLink1, 116);

    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

    //Make Immunity Checks
    int nResist = Sp_BlockingChecks(oTarget, eLink1, eLink2, eInvalid);
    if(nResist == 0)
    {
        int nSaves = Sp_MySavingThrows(oTarget);
        if(nSaves == 0)
        {
            // Remove any lower level or equal versions of this power.
            // Sp_RemoveRelatedPowers( oTarget, FORCE_POWER_SLOW );

            // Do not apply the effects of this power if a more powerful
            // version is already attached to the target.
            // if( !Sp_BetterRelatedPowerExists( oTarget, FORCE_POWER_SLOW ) ) {
            //if (!GetHasSpellEffect(284, oTarget))
                float fDuration = Sp_CalcDuration( 30.0 );
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, fDuration);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink2, oTarget, 1.0);
            // }
        }
    }
}
