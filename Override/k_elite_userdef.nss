//:: k_def_userdef01
/*
    Default User Defined Events Script
*/
//:: Created By: Preston Watamaniuk
//:: Copyright (c) 2002 Bioware Corp.

#include "k_inc_generic"
#include "k_inc_debug"
#include "k_inc_utility"
#include "k_inc_force"
void main()
{
    int nUser = GetUserDefinedEventNumber();

    if(nUser == 1001) //HEARTBEAT
    {

    }
    else if(nUser == 1002) // PERCEIVE
    {

    }
    else if(nUser == 1003) // END OF COMBAT
    {

    }
    else if(nUser == 1004) // ON DIALOGUE
    {

    }
    else if(nUser == 1005) // ATTACKED
    {

    }
    else if(nUser == 1006) // DAMAGED
    {
        if ((GetCurrentHitPoints(OBJECT_SELF) <= (GetMaxHitPoints(OBJECT_SELF) / 2)) && !GetLocalBoolean(OBJECT_SELF, 121))
        {
            // ActionCastSpellAtLocation(FORCE_POWER_FORCE_WAVE, GetLocation(OBJECT_SELF), 0, TRUE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);

            object oUse = GetFirstObjectInShape(SHAPE_SPHERE, 15.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE );

            DelayCommand(0.0, PlaySound("v_pro_scream"));
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_FORCE_WAVE), GetLocation(OBJECT_SELF));

            while(GetIsObjectValid(oUse))
            {
                if(GetIsEnemy(oUse))
                {
                    SignalEvent(oUse, EventSpellCastAt(OBJECT_SELF, FORCE_POWER_FORCE_WAVE, TRUE));

                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FORCE_PUSH), oUse);

                    if(SP_CheckForcePushViability(oUse, FALSE))
                    {
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectForcePushed(), oUse, 0.2);
                    }
                }

                oUse = GetNextObjectInShape(SHAPE_SPHERE, 15.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE );
            }

            SetLocalBoolean(OBJECT_SELF, 121, TRUE);
        }
    }
    else if(nUser == 1007) // DEATH
    {

    }
    else if(nUser == 1008) // DISTURBED
    {

    }
    else if(nUser == 1009) // BLOCKED
    {

    }
    else if(nUser == 1010) // SPELL CAST AT
    {

    }
    else if(nUser == 1011) //DIALOGUE END
    {
    
    }
    else if(nUser == HOSTILE_RETREAT)
    {
        UT_ReturnToBase();
    }
}

