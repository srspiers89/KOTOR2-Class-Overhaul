//:: k_def_userdef01
/*
    Default User Defined Events Script
*/
//:: Created By: Preston Watamaniuk
//:: Copyright (c) 2002 Bioware Corp.

#include "k_inc_generic"
#include "k_inc_debug"
#include "k_inc_utility"
void main()
{
    int nUser = GetUserDefinedEventNumber();

    //object oEnemy = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    object oEnemy = GetAttackTarget();

    switch (nUser)
    {
        case 1001:
        case 1002:
        case 1003:
        case 1004:
        case 1005:
        case 1006:
        case 1007:
        case 1008:
        case 1009:
        case 1010:
        case 1011:
        {
            if (GetIsObjectValid(oEnemy))
            {
                //ClearAllActions();
                //AssignCommand(OBJECT_SELF, CutsceneAttack(oEnemy, 114, ATTACK_RESULT_CRITICAL_HIT, 500));


            }
        }
    }
}

