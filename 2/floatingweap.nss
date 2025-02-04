// Floating Weapons Universal Power

void ReqCheck(int nFPCost, object oCaster = OBJECT_SELF);
void KillFloater();

void main()
{
    int nFPCost = GetSpellForcePointCost();

    location lLoc = Location(GetPosition(OBJECT_SELF) + AngleToVector(GetFacing(OBJECT_SELF)) * 3.0, GetFacing(OBJECT_SELF) - 180.0);
    object oFloater = CreateObject(OBJECT_TYPE_CREATURE, "c_lightsaber", lLoc);

    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
    DelayCommand(3.0, ReqCheck(nFPCost));
}

void ReqCheck(int nFPCost, object oCaster)
{
    if (GetIsObjectValid(GetObjectByTag("LightsaberFloat")))
    {
        // If combat is over kill LightsaberFloat
        if (!GetIsInCombat(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCaster)))
        {
            DelayCommand(6.0, KillFloater());
            return;
        }

        // If caster doesn't have enough force points kill LightsaberFloat
        if (GetCurrentForcePoints(oCaster) < nFPCost)
        {
            KillFloater();
            return;
        }
        else
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamageForcePoints(nFPCost), oCaster);

        DelayCommand(3.0, ReqCheck(nFPCost, oCaster));
    }
}

void KillFloater()
{
    DestroyObject(GetObjectByTag("LightsaberFloat"));
}
