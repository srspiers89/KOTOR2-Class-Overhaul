// diff_balance.nss

void Diff_Balance();
int ToHitCalc(object oCreature);
int DC_Calc(object oCreature);

void Diff_Balance()
{
    int nDamage, nDamageType, nWeapon, i, nMaxHp, nToHit, nAttackBonus, nDefBonus, nSaveBonus, nDC, nPartySize;
    int nHenchBonus;
    object oPC;
    effect eLink1;

    oPC = GetFirstPC();

    int nLevel = GetHitDice(oPC);
    nPartySize = GetPartyMemberCount();

    // Attack Bonus
    nAttackBonus = GetAC(oPC) - 11 - ToHitCalc(OBJECT_SELF);

    if (nAttackBonus > 0)
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectAttackIncrease(nAttackBonus), OBJECT_SELF);

    // Defense
    // Find highest attack bonus in party
    nToHit = ToHitCalc(GetPartyMemberByIndex(0));

    if (nPartySize > 1)
    {
        nHenchBonus = ToHitCalc(GetPartyMemberByIndex(1));

        if (nHenchBonus > nToHit)
            nToHit = nHenchBonus;
    }

    if (nPartySize > 2)
    {
        nHenchBonus = ToHitCalc(GetPartyMemberByIndex(2));

        if (nHenchBonus > nToHit)
            nToHit = nHenchBonus;
    }

    // to hit + 11 = 50% chance to hit
    nDefBonus = (nToHit + 11) - GetAC(OBJECT_SELF);

    if (nDefBonus > 0)
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectACIncrease(nDefBonus, AC_NATURAL_BONUS), OBJECT_SELF);

    // Saves
    // Find highest force power save dc
    nDC = DC_Calc(GetPartyMemberByIndex(0));

    if (nPartySize > 1)
    {
        nHenchBonus = DC_Calc(GetPartyMemberByIndex(1));

        if (nHenchBonus > nDC)
            nDC = nHenchBonus;
    }

    if (nPartySize > 2)
    {
        nHenchBonus = DC_Calc(GetPartyMemberByIndex(2));

        if (nHenchBonus > nDC)
            nDC = nHenchBonus;
    }

    nSaveBonus = nDC - 11 - GetFortitudeSavingThrow(OBJECT_SELF);
    if (nSaveBonus > 0)
        ModifyFortitudeSavingThrowBase(OBJECT_SELF, nSaveBonus);

    nSaveBonus = nDC - 11 - GetReflexSavingThrow(OBJECT_SELF);
    if (nSaveBonus > 0)
        ModifyReflexSavingThrowBase(OBJECT_SELF, nSaveBonus);

    nSaveBonus = nDC - 11 - GetWillSavingThrow(OBJECT_SELF);
    if (nSaveBonus > 0)
        ModifyWillSavingThrowBase(OBJECT_SELF, nSaveBonus);

    // # of attacks

    // VP
    if (nLevel > 15)
        nMaxHp = 12 * 15 + (nLevel - 15) * 49;
    else
        nMaxHp = 12 * nLevel;

    SetMaxHitPoints(OBJECT_SELF, nMaxHp);

    // Damage
    nDamage = GetMaxHitPoints(oPC) * 2 / 10;
    nDamage *= GetPartyMemberCount() / 3;

    // Get damage type
    nWeapon = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, OBJECT_SELF));

    if(nWeapon == BASE_ITEM_BLASTER_PISTOL ||
        nWeapon == BASE_ITEM_HEAVY_BLASTER ||
        nWeapon == BASE_ITEM_HOLD_OUT_BLASTER ||
        nWeapon == BASE_ITEM_BOWCASTER ||
        nWeapon == BASE_ITEM_BLASTER_CARBINE ||
        nWeapon == BASE_ITEM_REPEATING_BLASTER ||
        nWeapon == BASE_ITEM_HEAVY_REPEATING_BLASTER ||
        nWeapon == BASE_ITEM_BLASTER_RIFLE ||
        nWeapon == BASE_ITEM_LIGHTSABER ||
        nWeapon == BASE_ITEM_DOUBLE_BLADED_LIGHTSABER ||
        nWeapon == BASE_ITEM_SHORT_LIGHTSABER
    )
        nDamageType = 4096;

    else if(nWeapon == BASE_ITEM_ION_BLASTER ||
            nWeapon == BASE_ITEM_ION_RIFLE
    )
            nDamageType = 2048;

    else if(nWeapon == BASE_ITEM_DISRUPTER_PISTOL ||
            nWeapon == BASE_ITEM_DISRUPTER_RIFLE
    )
            nDamageType = 8;

    else if(nWeapon == BASE_ITEM_SONIC_PISTOL ||
            nWeapon == BASE_ITEM_SONIC_RIFLE
    )
            nDamageType = 1024;
    else
            nDamageType = DAMAGE_TYPE_BLUDGEONING;

    i = (nDamage / 5); //- 1;
    //eLink1 = EffectDamageIncrease(5, nDamageType);

    for(i; i > 0; i--)
    {
        // eLink1 = EffectLinkEffects(eLink1, EffectDamageIncrease(5, nDamageType));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(5, nDamageType), OBJECT_SELF);
    }

    // eLink1 = EffectLinkEffects(eLink1, EffectDamageIncrease(nDamage % 5, nDamageType));
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamage % 5, nDamageType), OBJECT_SELF);

    // ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink1, OBJECT_SELF);

    //  Flag that the creature has been buffed
    SetLocalBoolean(OBJECT_SELF, 122, TRUE);
}

int ToHitCalc(object oCreature)
{
    object oOffhand, oItem;
    string sItem;

    int   nToHit, nDex, nStr, i, nType;
    float fBAB1, fBAB2;

    /* For Overhaul Mod
    // Calculate BAB from classes
    int nClass1 = GetClassByPosition(1, oCreature);
    int nLevel1 = GetLevelByClass(nClass1, oCreature);
    fBAB1 = GetBAB(nClass1);

    int nClass2 = GetClassByPosition(2, oCreature);
    int nLevel2 = GetLevelByClass(nClass2, oCreature);
    fBAB2 = GetBAB(nClass2);

    nToHit = FloatToInt((fBAB1 * nLevel1) + (fBAB2 * nLevel2));
    */
    nToHit = GetHitDice(oCreature);

    // Add ability modifier bonus
    nDex = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    nStr = GetAbilityModifier(ABILITY_STRENGTH, oCreature);

    if (GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, oCreature))) // ranged weapon add dex
        nToHit += nDex;
    else if (GetFeatAcquired(FEAT_FINESSE_MELEE_WEAPONS, oCreature) || // if finesse add greater of str and dex
        GetFeatAcquired(FEAT_FINESSE_LIGHTSABERS, oCreature))
    {
        if (nStr > nDex)
            nToHit += nStr;
        else
            nToHit += nDex;
    }
    else
        nToHit += nStr;

    // Check for feat bonuses
    if (GetFeatAcquired(FEAT_WEAPON_FOCUS_BLASTER, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_BLASTER_RIFLE, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_GRENADE, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_HEAVY_WEAPONS, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_LIGHTSABER, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_MELEE_WEAPONS, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_SIMPLE_WEAPONS, oCreature)
    )
        nToHit += 1;

        if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_1, oCreature))
            nToHit += 1;
    if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_2, oCreature))
        nToHit += 1;
    if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_3, oCreature))
        nToHit += 1;

    if (GetFeatAcquired(FEAT_TARGETING_1, oCreature) && GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, oCreature)))
    {
        nToHit += 1;
        i = FEAT_TARGETING_2;

        while (i <=  FEAT_TARGETING_10)
        {
            if (GetFeatAcquired(i, oCreature))
                nToHit += 1;

            i++;
        }
    }

    // Two-weapon fighting Calculation
    oOffhand = GetItemInSlot(INVENTORY_SLOT_LEFTWEAPON, oCreature);
    nType = GetBaseItemType(oOffhand);

    if (GetIsObjectValid(oOffhand))
    {
        if (nType == BASE_ITEM_SHORT_SWORD ||
            nType == BASE_ITEM_VIBRO_BLADE ||
            nType == BASE_ITEM_DOUBLE_BLADED_SWORD ||
            nType == BASE_ITEM_VIBRO_DOUBLE_BLADE ||
            nType == BASE_ITEM_DOUBLE_BLADED_LIGHTSABER ||
            nType == BASE_ITEM_SHORT_LIGHTSABER ||
            nType == BASE_ITEM_BLASTER_PISTOL ||
            nType == BASE_ITEM_HEAVY_BLASTER ||
            nType == BASE_ITEM_HOLD_OUT_BLASTER ||
            nType == BASE_ITEM_ION_BLASTER ||
            nType == BASE_ITEM_DISRUPTER_PISTOL ||
            nType == BASE_ITEM_SONIC_PISTOL ||
            nType == BASE_ITEM_GHAFFI_STICK ||
            nType == BASE_ITEM_WOOKIE_WARBLADE ||
            nType == BASE_ITEM_FORCE_PIKE
        )
            nToHit += 2;

        if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_TWO_WEAPON_1, oCreature))
                nToHit -= 1;
        else if (GetFeatAcquired(85, oCreature)) // Master Two-Weapon Fighting
            nToHit -= 2;
        else if (GetFeatAcquired(9, oCreature)) // Improved Two-Weapon Fighting
            nToHit -= 4;
        else
            nToHit -= 6;
    }

    // Check Lightsaber forms
    if (IsFormActive(oCreature, FORM_SABER_I_SHII_CHO))
        nToHit += 1;
    if (IsFormActive(oCreature, FORM_SABER_V_SHIEN))
        nToHit += 2;
    if (IsFormActive(oCreature, FORM_SABER_VI_NIMAN))
        nToHit += 1;

    // Force Power Effects
    if (GetHasSpellEffect(FORCE_POWER_MASTER_BATTLE_MEDITATION_PC, oCreature))
        nToHit += 4;
    else if (GetHasSpellEffect(FORCE_POWER_IMPROVED_BATTLE_MEDITATION_PC, oCreature) ||
        GetHasSpellEffect(FORCE_POWER_BATTLE_MEDITATION_PC, oCreature)
    )
        nToHit += 2;

        if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_V, oCreature))
            nToHit += 5;
    else if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_IV, oCreature))
        nToHit += 4;
    else if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_III, oCreature))
        nToHit += 3;
    else if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_II, oCreature))
        nToHit += 2;
    else if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_I, oCreature))
        nToHit += 1;

    if (GetHasSpellEffect(77, oCreature)) // Echani Battle Stim
        nToHit += 3;
    else if (GetHasSpellEffect(76, oCreature)) // Hyper-Battle Stim
        nToHit += 2;
    else if (GetHasSpellEffect(75, oCreature)) // Battle Stim
        nToHit += 1;

    // Get bonuses from items
    oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oCreature);
    if (GetIsObjectValid(oItem))
    {
        sItem = GetTag(oItem);
        if (sItem == "a_helmet_19" ||
            sItem == "a_helmet_08"
        )
            nToHit += 1;
            if (sItem == "a_helmet_24")
                nToHit += 2;
        if (sItem == "a_helmet_16")
            nToHit += 3;
    }

    oItem = GetItemInSlot(INVENTORY_SLOT_IMPLANT, oCreature);
    if (GetIsObjectValid(oItem))
    {
        sItem = GetTag(oItem);
        if (sItem == "e_imp3_04")
            nToHit += 1;
    }

    oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, oCreature);
    if (GetIsObjectValid(oItem))
    {
        sItem = GetTag(oItem);

        if(sItem == "w_blaste_10" ||
            sItem == "w_blaste_11" ||
            sItem == "w_blaste_14" ||
            sItem == "w_blaste_29" ||
            sItem == "w_blaste_17" ||
            sItem == "w_blaste_x05" ||
            sItem == "w_blaste_12" ||
            sItem == "w_blaste_16" ||
            sItem == "w_blaste_08" ||
            sItem == "w_blaste_25" ||
            sItem == "w_brifle_12" ||
            sItem == "w_brifle_15" ||
            sItem == "w_brifle_26" ||
            sItem == "w_brifle_30" ||
            sItem == "w_melee_30" ||
            sItem == "w_melee_29" ||
            sItem == "w_melee_18" ||
            sItem == "w_melee_x12" ||
            sItem == "w_melee_11" ||
            sItem == "w_melee_17" ||
            sItem == "w_melee_24" ||
            sItem == "w_melee_12" ||
            sItem == "w_melee_27" ||
            sItem == "w_melee_13" ||
            sItem == "w_melee_x02"
        )
            nToHit += 1;

            if (sItem == "w_blaste_21" ||
                sItem == "w_blaste_30" ||
                sItem == "w_blaste_28" ||
                sItem == "w_blaste_20" ||
                sItem == "w_blaste_26" ||
                sItem == "w_blaste_22" ||
                sItem == "w_blaste_24" ||
                sItem == "w_brifle_19" ||
                sItem == "w_brifle_29" ||
                sItem == "w_brifle_20" ||
                sItem == "w_melee_21" ||
                sItem == "w_melee_19" ||
                sItem == "w_melee_22" ||
                sItem == "w_melee_20" ||
                sItem == "w_sls_x02"
            )
                nToHit += 2;

                if (sItem == "w_blaste_19" ||
                    sItem == "w_brifle_21"
                )
                    nToHit += 3;

                    if (sItem == "w_brifle_23")
                        nToHit += 4;
    }

    // Add bonus based on level to account for items
    if (IsObjectPartyMember(oCreature))
        nToHit += (GetHitDice(oCreature) / 4);

    return nToHit;
}

int DC_Calc(object oCreature)
{
    int nDC = 0, i = 0;

    /*
    // Get highest spell dc in party
    for (i; i > 2; i++)
    {
        oCreature = GetPartyMemberByIndex(i);

        if (nDC < (5 + GetHitDice(oCreature) + GetAbilityModifier(ABILITY_WISDOM, oCreature) + GetAbilityModifier(ABILITY_CHARISMA, oCreature)))
            nDC = 5 + GetHitDice(oCreature) + GetAbilityModifier(ABILITY_WISDOM, oCreature) + GetAbilityModifier(ABILITY_CHARISMA, oCreature);
    } */

    nDC = 5 + GetHitDice(oCreature) + GetAbilityModifier(ABILITY_WISDOM, oCreature) + GetAbilityModifier(ABILITY_CHARISMA, oCreature);

    // Check for force focus feats
    if (GetFeatAcquired(FEAT_FORCE_FOCUS_MASTERY, oCreature))
        nDC += 4;
    else if (GetFeatAcquired(FEAT_FORCE_FOCUS_ADVANCED, oCreature))
        nDC += 3;
    else if (GetFeatAcquired(88, oCreature)) // Force Focus
        nDC += 2;

    // Check for Force Forms modifying dc
    if (IsFormActive(oCreature, FORM_FORCE_IV_MASTERY))
        nDC += 2;

    return nDC;
}
