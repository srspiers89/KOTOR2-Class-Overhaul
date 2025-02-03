// MultiTarget

void main()
{
    object oTarget;
    int nDamage = 0;
    int nDamageType = 1;

    effect eLink1; // = EffectDamage(0, DAMAGE_TYPE_UNIVERSAL);
    effect eDamage; // = EffectDamage(GetLocalNumber(OBJECT_SELF, 25), GetRunScriptVar());

    if(GetIsObjectValid(GetAttackTarget(OBJECT_SELF)))
        oTarget = GetAttackTarget(OBJECT_SELF);
    else
        oTarget = GetLastHostileTarget(OBJECT_SELF);

    //ExecuteScript("getdamagetype", oTarget, 4);
    //eDamage = EffectDamage(GetLocalNumber(oTarget, 25), 4);
    //eLink1 = EffectLinkEffects(eLink1, eDamage);

    ExecuteScript("getdamagetype", oTarget, 128);
    if(!(GetLocalNumber(oTarget, 25) > GetLocalNumber(oTarget, 26)))
        eDamage = EffectDamage(GetLocalNumber(oTarget, 25), 128);
    else
        eDamage = EffectDamage(GetLocalNumber(oTarget, 26), 128);
    //eLink1 = EffectLinkEffects(eLink1, eDamage);

    /*
    while (nDamageType < 4096)
    {
        ExecuteScript("getdamagetype", oTarget, nDamageType);

        if(GetLocalNumber(oTarget, 25) != -1)
        {
            eDamage = EffectDamage(GetLocalNumber(oTarget, 25), nDamageType);
            eLink1 = EffectLinkEffects(eLink1, eDamage);
        }

        nDamageType = nDamageType * 2;
        if(nDamageType == 4)
            nDamageType = nDamageType * 2;
    }
    */

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, GetLocation(oTarget), FALSE, OBJECT_TYPE_CREATURE);

    while(GetIsObjectValid(oTarget))
    {
        if(GetIsEnemy(oTarget) && oTarget != GetAttackTarget(OBJECT_SELF) && oTarget != GetLastHostileTarget(OBJECT_SELF)) // Only richochet once
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
            break;
        }
        else
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 10.0, GetLocation(oTarget), FALSE, OBJECT_TYPE_CREATURE);
    }

}
