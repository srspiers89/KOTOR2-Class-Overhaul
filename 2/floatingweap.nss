// Floating Weapons Universal Power
#include "floatingweap_inc"

void main()
{
    int nFPCost = GetSpellForcePointCost();

    location lLoc = Location(GetPosition(OBJECT_SELF) + AngleToVector(GetFacing(OBJECT_SELF)) * 3.0, GetFacing(OBJECT_SELF) - 180.0);
    CreateObject(OBJECT_TYPE_CREATURE, "c_lightsaber", lLoc);

    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
    DelayCommand(3.0, ReqCheck(nFPCost, OBJECT_SELF));
}
