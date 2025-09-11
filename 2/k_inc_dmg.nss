// k_inc_dmg.nss
//
// Include file for my feats and force powers that use the ondamage event

void UndyingFury();
void Counterstrike();

void UndyingFury()
{
    if (GetHasSpellEffect(FORCE_POWER_MASTER_FURY))
    {
        int nCnt = 0;
        object oNPC1 = GetPartyMemberByIndex(0);
        object oNPC2 = GetPartyMemberByIndex(1);
        object oNPC3 = GetPartyMemberByIndex(2);

        int nDamage = GetTotalDamageDealt();

        effect eDamage;
        effect eBeam = EffectBeam(VFX_BEAM_DRAIN_LIFE, OBJECT_SELF, BODY_NODE_HEAD);
        effect eVFX = EffectVisualEffect(VFX_PRO_DRAIN);

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAbilityIncrease(ABILITY_STRENGTH, 2), OBJECT_SELF, 30.0);

        // Determine how many party members are alive
        if(GetIsObjectValid(oNPC1) && GetCurrentHitPoints(oNPC1) > 0)
        {
            nCnt++;
        }
        if(GetIsObjectValid(oNPC2) && GetCurrentHitPoints(oNPC2) > 0)
        {
            nCnt++;
        }
        if(GetIsObjectValid(oNPC3) && GetCurrentHitPoints(oNPC3) > 0)
        {
            nCnt++;
        }

        // If both party members are alive split the damage between them
        if (nCnt == 3)
            nDamage = nDamage / 4;
        else
            nDamage = nDamage / 2;

        eDamage = EffectDamage(nDamage, DAMAGE_TYPE_UNIVERSAL);

        // If all party members are dead remove minonehp effect
        if (nCnt == 1)
        {
            if (GetMinOneHP(OBJECT_SELF))
                SetMinOneHP(OBJECT_SELF, 0);

            // ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), OBJECT_SELF);
        }

       if (GetCurrentHitPoints(OBJECT_SELF) == 1)
       {
           if (GetIsObjectValid(oNPC1) && oNPC1 != OBJECT_SELF)
            {
                DelayCommand(0.3, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFX, oNPC1));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oNPC1);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oNPC1, 1.0);
            }
            if (GetIsObjectValid(oNPC2) && oNPC2 != OBJECT_SELF)
            {
                DelayCommand(0.3, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFX, oNPC2));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oNPC2);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oNPC2, 1.0);
            }
            if (GetIsObjectValid(oNPC3) && oNPC3 != OBJECT_SELF)
            {
                DelayCommand(0.3, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFX, oNPC3));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oNPC3);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oNPC3, 1.0);
            }
        }
    }
}

void Counterstrike()
{
    //if (GetLevelByClass(CLASS_TYPE_JEDIWEAPONMASTER, OBJECT_SELF) > 0)
    //{
    //int nDamage = GetLocalNumber(OBJECT_SELF, 18) + GetTotalDamageDealt();
    //int nDamage = GetTotalDamageDealt();
    int nDamage = 25;

    SetLocalNumber(OBJECT_SELF, 18, nDamage);
    //}
}
