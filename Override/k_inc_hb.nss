// k_inc_hb.nss
//
// Include file for my feats and force powers that use the onheartbeat event

void OnHeartbeat();
void Resolve();
float GetBAB(int nClass);
void AgainstTheOdds();

void OnHeartbeat()
{
    int nClass1 = GetClassByPosition(1, OBJECT_SELF);
    int nLevel1 = GetLevelByClass(nClass1, OBJECT_SELF);
    int nClass2 = GetClassByPosition(2, OBJECT_SELF);
    int nLevel2 = GetLevelByClass(nClass2, OBJECT_SELF);

    effect eEffect = GetFirstEffect(OBJECT_SELF);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect) == EFFECT_TYPE_CONCEALMENT)
            RemoveEffect(OBJECT_SELF, eEffect);

        eEffect = GetNextEffect(OBJECT_SELF);
    }

    eEffect = EffectMissChance(1);

    switch (nClass1)
    {
        case CLASS_TYPE_JEDIGUARDIAN:
        {
            AgainstTheOdds();

            // CHA bonus to saves
            if (nLevel1 >= 2)
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
    }

    //AgainstTheOdds();

    // Guardian lvl 2 feat CHA to Saves
    // if (GetHasFeat())
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSavingThrowIncrease(SAVING_THROW_ALL, GetAbilityModifier(ABILITY_CHARISMA)), OBJECT_SELF, 3.0);

    // Sentinel lvl 1 feat Int to Attack
    //if (GetHasFeat())
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackIncrease(GetAbilityModifier(ABILITY_INTELLIGENCE)), OBJECT_SELF, 3.0);

    // Sentinel lvl 5 feat Int to Damage
    // if (GetHasFeat())
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageIncrease(GetAbilityModifier(ABILITY_INTELLIGENCE)), OBJECT_SELF, 3.0);

    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, OBJECT_SELF));
}

float GetBAB(int nClass)
{
    float fBAB;

    switch (nClass) {
        case CLASS_TYPE_SOLDIER:            fBAB = 1.0;     break;
        case CLASS_TYPE_SCOUT:              fBAB = 0.75;    break;
        case CLASS_TYPE_SCOUNDREL:          fBAB = 0.75;    break;
        case CLASS_TYPE_JEDIGUARDIAN:       fBAB = 1.0;     break;
        case CLASS_TYPE_JEDICONSULAR:       fBAB = 0.5;     break;
        case CLASS_TYPE_JEDISENTINEL:       fBAB = 0.75;    break;
        case CLASS_TYPE_COMBATDROID:        fBAB = 1.0;     break;
        case CLASS_TYPE_EXPERTDROID:        fBAB = 0.75;    break;
        case CLASS_TYPE_MINION:             fBAB = 1.0;     break;
        case CLASS_TYPE_TECHSPECIALIST:     fBAB = 0.75;    break;
        case CLASS_TYPE_JEDIWEAPONMASTER:   fBAB = 1.0;     break;
        case CLASS_TYPE_JEDIMASTER:         fBAB = 0.5;     break;
        case CLASS_TYPE_JEDIWATCHMAN:       fBAB = 0.75;    break;
        case CLASS_TYPE_SITHMARAUDER:       fBAB = 1.0;     break;
        case CLASS_TYPE_SITHLORD:           fBAB = 0.5;     break;
        case CLASS_TYPE_SITHASSASSIN:       fBAB = 0.75;    break;
    }

    return fBAB;
}

void Resolve()
{
    /*
    int nCheck = 0;
    effect eEffect = GetFirstEffect(OBJECT_SELF);

    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect) == EFFECT_TYPE_TEMPORARY_HITPOINTS)
            nCheck = 1;

        eEffect = GetNextEffect(OBJECT_SELF);
    }

    if (nCheck == 0)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectTemporaryHitpoints(20), OBJECT_SELF, 3.0);
        DelayCommand(3.05, Resolve());
    } */

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectTemporaryHitpoints(20), OBJECT_SELF, 3.0);
    SetLocalBoolean(OBJECT_SELF, 122, TRUE);
    DelayCommand(3.05, Resolve());
}

void AgainstTheOdds()
{
    effect eBonus;
    int nBonus = 0;

    object oEnemy = GetFirstObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE );

    if (GetIsInCombat())
    {
        while (GetIsObjectValid(oEnemy))
        {
            if (GetAttackTarget(oEnemy) == OBJECT_SELF)
                nBonus++;

            oEnemy = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(oEnemy), TRUE, OBJECT_TYPE_CREATURE );
        }
    }

    eBonus = EffectACIncrease(nBonus);
    eBonus = EffectLinkEffects(eBonus, EffectAttackIncrease(nBonus));

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBonus, OBJECT_SELF, 3.0);
}
