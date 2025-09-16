// Force Taunt Power
//
// Enemies who fail their save are forced to attack the caster for 12 seconds
// Applys an effect which does nothing but in checked for k_inc_generic

#include "k_inc_force"

void main()
{
    SWFP_HARMFUL = TRUE;
    SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;

    float fShapeSize = Sp_CalcRange(12.0);
    int nSaves;

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fShapeSize, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE );

    while (GetIsObjectValid(oTarget))
    {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

        if (GetRacialType(oTarget) != RACIAL_TYPE_DROID && GetIsEnemy(oTarget))
        {
           nSaves = Sp_MySavingThrows(oTarget);
           if (nSaves <= 0)
           {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectMissChance(1), OBJECT_SELF, 30.0);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectMissChance(1), oTarget, 30.0);
           }
        }

        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fShapeSize, GetLocation(oTarget), TRUE, OBJECT_TYPE_CREATURE );
    }
}
