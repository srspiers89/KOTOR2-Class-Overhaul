// k_inc_elite.nss
//
// Elite Enemies Mod

void SpawnElite(object oSeen);

void SpawnElite(object oSeen)
{
    location lLoc = Location(GetPosition(oSeen) + AngleToVector(GetFacing(oSeen)) * 3.0, GetFacing(oSeen) - 180.0);

    if (GetIsEnemy(oSeen))
        CreateObject(OBJECT_TYPE_CREATURE, "LightsaberFloat", lLoc);
}
