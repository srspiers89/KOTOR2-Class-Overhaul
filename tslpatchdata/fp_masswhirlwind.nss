// Mass Force Whirlwind
// AOE Version of Force Whirlwind

#include "k_inc_force"

void main ()
{
    SWFP_HARMFUL = TRUE;
    SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_REFLEX;
    effect eInvalid;

    float fRange = Sp_CalcRange( 15.0 );
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRange, GetLocation(GetSpellTargetObject()));

    // DJS-OEI 3/25/2004
    SWFP_DAMAGE = Sp_CalcDamage( oTarget, 0, 0, GetHitDice(OBJECT_SELF)/3 );
    SWFP_DAMAGE_TYPE = DAMAGE_TYPE_BLUDGEONING;
    effect eDamage = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);

    while(GetIsObjectValid(oTarget))
    {
        if(SP_CheckForcePushViability(oTarget, TRUE) && GetIsEnemy(oTarget))
        {
            effect eLink1 = EffectWhirlWind();
            eLink1 = EffectLinkEffects(eLink1, EffectVisualEffect(VFX_IMP_FORCE_WHIRLWIND));
            eLink1 = EffectLinkEffects(eLink1, EffectVisualEffect(VFX_DUR_FORCE_WHIRLWIND));
            eLink1 = SetEffectIcon(eLink1, 14);

            int nResist = Sp_BlockingChecks(oTarget, eLink1, eDamage, eInvalid);
            int nSaves;
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));
            if(nResist == 0)
            {
                nSaves =Sp_MySavingThrows(oTarget);
                if(nSaves == 0)
                {
                    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, 9.0);
                    //RWT-OEI 09/27/04 - QA says they fall too soon. Upping this to 12 to
                    //see if that fixes it. FMP#6266
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, 12.0);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDamage, oTarget);
                    int nIdx = 1;
                    float fDelay;
                    SP_InterativeDamage(eDamage, 13, oTarget);
                }
            }
            if(nResist > 0 || nSaves > 0)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
            }
        }

        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oTarget));
    }
}

