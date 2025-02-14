// k_inc_hb.nss
//
// Include file for my feats and force powers that use the onheartbeat event

void Fury();

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
