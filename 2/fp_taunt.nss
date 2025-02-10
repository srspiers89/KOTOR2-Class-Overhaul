// Force Taunt Power
//
// Enemies who fail their save are forced to attack the caster for 12 seconds

#include "k_inc_force"
#include "k_inc_generic"

void main()
{
    SWFP_HARMFUL = TRUE;
    SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;

    float fShapeSize = Sp_CalcRange(12.0);

    object oCaster = OBJECT_SELF;
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fShapeSize, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE );

    while (GetIsObjectValid(oTarget))
    {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

        if (GetRacialType(oTarget) != RACIAL_TYPE_DROID && GetIsEnemy(oTarget))
        {
           int nSaves = Sp_MySavingThrows(oTarget);
           if (nSaves <= 0)
           {
                AssignCommand(oTarget, ClearAllActions());
                AssignCommand(oTarget, ActionAttack(oCaster));
                AssignCommand(oTarget, ActionAttack(oCaster));
                AssignCommand(oTarget, ActionAttack(oCaster));
                AssignCommand(oTarget, ActionAttack(oCaster));
           }
        }

        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fShapeSize, GetLocation(oTarget), TRUE, OBJECT_TYPE_CREATURE );
    }
}
