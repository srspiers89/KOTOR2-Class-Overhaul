// Heartbeart script for Floating Weapons

#include "k_inc_generic"
#include "floatingweap_inc"

void main()
{
    object oEnemy = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);

    // Follow the party leader if not fighting and not already following.
    if (!GN_GetSpawnInCondition(SW_FLAG_AI_OFF)
        && !GetIsInCombat(OBJECT_SELF)
        && (GetCurrentAction(OBJECT_SELF) != ACTION_MOVETOPOINT)
        && (GetCurrentAction(OBJECT_SELF) != ACTION_FOLLOW)
        && !GetIsObjectValid(oEnemy)
        && !GetIsConversationActive()
        && !GN_GetSpawnInCondition(SW_FLAG_SPECTATOR_STATE)
        && GetCommandable())
    {
        object oSummon = GetPartyMemberByIndex(0);
        if (GetIsObjectValid(oSummon))
        {
            ClearAllActions();
            ActionMoveToObject(oSummon, TRUE);
        }
    }
    //if (GetCurrentAction(OBJECT_SELF) == ACTION_FOLLOW && GetIsObjectValid(oEnemy))
    //    ClearAllActions();

    if (GN_GetSpawnInCondition(SW_FLAG_EVENT_ON_HEARTBEAT))
        SignalEvent(OBJECT_SELF, EventUserDefined(1001));

    //DelayCommand(3.0, CombatCheck());
}
