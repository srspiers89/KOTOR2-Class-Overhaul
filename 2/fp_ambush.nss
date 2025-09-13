// fp_ambush.nss
// Teleport behind target and attack

void main()
{
    object oEnemy = GetSpellTargetObject();

    location lLoc = Location(GetPosition(oEnemy) - AngleToVector(GetFacing(oEnemy)) * 2.0, GetFacing(oEnemy));

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectInvisibility(INVISIBILITY_TYPE_NORMAL), OBJECT_SELF, 3.0);
    //DelayCommand(1.5, ClearAllActions());
    //DelayCommand(1.6, JumpToLocation(lLoc));
    ClearAllActions();
    DelayCommand(0.15, ActionAttack(oEnemy));
    DelayCommand(0.25, JumpToLocation(lLoc));
    //DelayCommand(1.0, ActionAttack(oEnemy));

    // object oAttacker = GetFirstAttacker(OBJECT_SELF);

    //while(GetIsObjectValid(oAttacker))
    //{
        //if (oAttacker == oEnemy)
        if (GetAttackTarget(oEnemy) == OBJECT_SELF)
        {
            AssignCommand(oEnemy, ClearAllActions());
            AssignCommand(oEnemy, FaceObjectAwayFromObject(oEnemy, OBJECT_SELF));
            DelayCommand(0.1, AssignCommand(oEnemy,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE,1.0,5.0)));
            DelayCommand(0.2,SetCommandable(FALSE,oEnemy));
            DelayCommand(4.8,SetCommandable(TRUE,oEnemy));
            //break;
        }
        //oAttacker = GetNextAttacker(OBJECT_SELF);
    //}
}
