//:: float_spawn01

#include "k_inc_generic"

void main()
{

    GN_SetDayNightPresence(AMBIENT_PRESENCE_ALWAYS_PRESENT);
    GN_SetListeningPatterns();
    SetLocalNumber(OBJECT_SELF, 11, 6);// FAK - OEI default turret cooldown

    GN_SetSpawnInCondition(SW_FLAG_BOSS_AI);
    //GN_SetSpawnInCondition(SW_FLAG_EVENT_ON_PERCEPTION);       //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //GN_SetSpawnInCondition(SW_FLAG_EVENT_ON_ATTACKED);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //GN_SetSpawnInCondition(SW_FLAG_EVENT_ON_DAMAGED);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //GN_SetSpawnInCondition(SW_FLAG_EVENT_ON_COMBAT_ROUND_END); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //GN_SetSpawnInCondition(SW_FLAG_EVENT_ON_FORCE_AFFECTED);   //OPTIONAL BEHAVIOR - Fire User Defined Event 1010

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectAssuredHit(), OBJECT_SELF);

    /*int i = GetHitDice(GetPartyMemberByIndex(0));
    for (i; i > 0; i--)
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(14), OBJECT_SELF);
    }*/
}
