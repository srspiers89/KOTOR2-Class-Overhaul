// cgo_hb.nss

void main()
{
    effect eEffect = GetFirstEffect(OBJECT_SELF);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect) == EFFECT_TYPE_CONCEALMENT)
            RemoveEffect(OBJECT_SELF, eEffect);

        eEffect = GetNextEffect(OBJECT_SELF);
    }

    eEffect = EffectMissChance(1);

    int nClass1 = GetClassByPosition(1, OBJECT_SELF);
    int nLevel1 = GetLevelByClass(nClass1, OBJECT_SELF);
    int nClass2 = GetClassByPosition(2, OBJECT_SELF);
    int nLevel2 = GetLevelByClass(nClass2, OBJECT_SELF);

    switch (nClass1)
    {
        case CLASS_TYPE_JEDIGUARDIAN:
        {
            // AgainstTheOdds();
            int nBonus = 0;

            if (GetIsInCombat())
            {
                object oEnemy = GetFirstObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE );

                while (GetIsObjectValid(oEnemy))
                {
                    if (GetAttackTarget(oEnemy) == OBJECT_SELF)
                        nBonus++;

                    oEnemy = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE );
                }
            }
            if (nBonus > 0)
                eEffect = EffectLinkEffects(eEffect, EffectACIncrease(nBonus, AC_SHIELD_ENCHANTMENT_BONUS));

            // CHA bonus to saves
            if (nLevel1 >= 1)
                eEffect = EffectLinkEffects(eEffect, EffectSavingThrowIncrease(SAVING_THROW_ALL, GetAbilityModifier(ABILITY_CHARISMA)));
        }
        break;

        case CLASS_TYPE_JEDISENTINEL:
        {
            if (nLevel1 >= 1)
                eEffect = EffectLinkEffects(eEffect, EffectAttackIncrease(GetAbilityModifier(ABILITY_INTELLIGENCE)));
            if (nLevel1 >= 5)
                eEffect = EffectLinkEffects(eEffect, EffectDamageIncrease(GetAbilityModifier(ABILITY_INTELLIGENCE)));
        }
        break;

        case CLASS_TYPE_JEDICONSULAR:
        {

        }
        break;
    }

    switch (nClass2)
    {

    }

    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, OBJECT_SELF));

    int iReruns = GetRunScriptVar();
    if (iReruns >= 1)
    {
        iReruns -= 1;
        DelayCommand(1.0, ExecuteScript("cgo_hb", OBJECT_SELF, iReruns));
    }
}
