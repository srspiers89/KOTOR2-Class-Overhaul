// fp_ambush.nss

void main()
{
    object oEnemy = GetSpellTargetObject();

    location lLoc = Location(GetPosition(oEnemy) - AngleToVector(GetFacing(oEnemy)) * 3.0, GetFacing(oEnemy));

    object oAttacker = GetFirstAttacker(OBJECT_SELF);

    /*
    while(GetIsObjectValid(oAttacker))
    {
        //AssignCommand(oAttacker, ClearAllActions());
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDroidStun(), oAttacker, 3.0);
        oAttacker = GetNextAttacker(OBJECT_SELF);
    }
    */

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectInvisibility(INVISIBILITY_TYPE_NORMAL), OBJECT_SELF, 3.0);
    ClearAllActions();
    JumpToLocation(lLoc);
    //DelayCommand(0.2, AssignCommand(OBJECT_SELF, ActionAttack(oEnemy)));

    AssignCommand(oEnemy, ClearAllActions());
    AssignCommand(oEnemy, FaceObjectAwayFromObject(oEnemy, OBJECT_SELF));
    //AssignCommand(oEnemy, ActionWait(3.0));
}
