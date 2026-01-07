// k_inc_hb.nss
//
// Include file for my feats and force powers that use the onheartbeat event

#include "k_inc_gensupport"

void OnHeartbeat();
void Resolve();
void Fury();
float GetBAB(int nClass);
void AgainstTheOdds();

void OnHeartbeat()
{
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

    SetLocalBoolean(OBJECT_SELF, 122, TRUE);
    DelayCommand(3.05, OnHeartbeat());
}

void Fury()
{
    // effect eStrAdj;
    effect eDamage;
    // int nStrength = 6;
    // float nVPThreshold = IntToFloat(GetCurrentHitPoints(OBJECT_SELF)) / IntToFloat(GetMaxHitPoints(OBJECT_SELF));

    /*
    if (nVPThreshold <= 0.75 && nVPThreshold > 0.5)
        nStrength = 4;
    else if (nVPThreshold <= 0.5 && nVPThreshold > 0.25)
        nStrength = 6;
    else if (nVPThreshold <= 0.25 && nVPThreshold > 0.01)
        nStrength = 8;
    else if (nVPThreshold <= 0.01)
        nStrength = 10;
    */

    eDamage = EffectDamage((GetMaxHitPoints(OBJECT_SELF) / 5));

    if (GetHasSpellEffect(FORCE_POWER_MASTER_FURY))
    {
        /* nStrength = nStrength + 4;
        if ((nStrength - 12) > 0)
        {
            eStrAdj = EffectAbilityIncrease(ABILITY_STRENGTH, (nStrength - 12));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStrAdj, OBJECT_SELF, 3.0);
        }


        eStrAdj = EffectAbilityIncrease(ABILITY_STRENGTH, nStrength);

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStrAdj, OBJECT_SELF, 3.0); */
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, OBJECT_SELF);
        ExecuteScript("k_hen_damage01", OBJECT_SELF);
    }

    else if (GetHasSpellEffect(FORCE_POWER_IMPROVED_FURY))
    {
        // eStrAdj = EffectAbilityIncrease(ABILITY_STRENGTH, (nStrength + 2));;
        // ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStrAdj, OBJECT_SELF, 3.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, OBJECT_SELF);
        ExecuteScript("k_hen_damage01", OBJECT_SELF);
    }

    else if (GetHasSpellEffect(FORCE_POWER_FURY))
    {
        // eStrAdj = EffectAbilityIncrease(ABILITY_STRENGTH, nStrength);
        // ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStrAdj, OBJECT_SELF, 3.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, OBJECT_SELF);
        ExecuteScript("k_hen_damage01", OBJECT_SELF);
    }
    else if (GetMinOneHP(OBJECT_SELF))
    {
        if (!GetIsConversationActive())
            SetMinOneHP(OBJECT_SELF, 0);
    }
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
