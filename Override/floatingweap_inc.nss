// Include file for Floating Weapon power

void CombatCheck();
void KillFloater(object oFloater);
void ReqCheck(int nFPCost, object oCaster);

void CombatCheck()
{
    object oEnemy = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);

    if (!GetIsInCombat() && !GetIsInCombat(oEnemy) && !HasLineOfSight(GetPosition(OBJECT_SELF), GetPosition(oEnemy)))
        KillFloater(OBJECT_SELF);
}

void KillFloater(object oFloater)
{
    DestroyObject(oFloater);
}

void ReqCheck(int nFPCost, object oCaster)
{
    int i = 0;
    object oFloater = GetObjectByTag("LightsaberFloat", i);

    while (GetIsObjectValid(oFloater))
    {
        // If caster doesn't have enough force points kill LightsaberFloat
        if (GetCurrentForcePoints(oCaster) < nFPCost)
        {
            KillFloater(oFloater);
            i++;
            oFloater = GetObjectByTag("LightsaberFloat", i);
            continue;
        }

        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamageForcePoints(nFPCost), oCaster);

        // Get next Floater
        i++;
        oFloater = GetObjectByTag("LightsaberFloat", i);
    }

    if (GetIsObjectValid(GetObjectByTag("LightsaberFloat")))
    {
        DelayCommand(3.0, ReqCheck(nFPCost, oCaster));
    }
}
