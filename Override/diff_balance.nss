// diff_balance.nss
// To do: add droid items to ToHitCalc

void Diff_Balance();
int ToHitCalc(object oCreature);
int FP_DC_Calc(object oCreature);
int Save_DC_Calc(object oCreature);

void Diff_Balance()
{
    int nCheck = 0;

    effect eEffect = GetFirstEffect(OBJECT_SELF);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect) == EFFECT_TYPE_CONCEALMENT)
        {
            RemoveEffect(OBJECT_SELF, eEffect);
            //nCheck = 1;
        }
        eEffect = GetNextEffect(OBJECT_SELF);
    }

    if (nCheck == 0)
    {
        int nDamage, nWeaponType, i, nMaxHp, nAttackBonus, nDefBonus, nSaveBonus, nPartySize = 0;
        int nToHit = 0, nFP_DC = 0, nSaveDC = 0, nHenchBonus, nAvgAC = 0, nAvgVP = 0, nLevelDiff;
        object oPC1, oPC2, oPC3;
        object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, OBJECT_SELF);

        if (!GetLocalBoolean(OBJECT_SELF, 122))
        {
            SetLocalNumber(OBJECT_SELF, 13, GetAC(OBJECT_SELF)); // set local number 13 to Original AC
            SetLocalNumber(OBJECT_SELF, 14, GetFortitudeSavingThrow(OBJECT_SELF)); // set local number 14 to Original fort save
            SetLocalNumber(OBJECT_SELF, 15, GetReflexSavingThrow(OBJECT_SELF)); // set local number 15 to Original reflex save
            SetLocalNumber(OBJECT_SELF, 16, GetWillSavingThrow(OBJECT_SELF)); // set local number 16 to Original will save
            SetLocalNumber(OBJECT_SELF, 17, ToHitCalc(OBJECT_SELF)); // set local number 17 to Original attack bonus

            // Flag that the creature has been buffed
            SetLocalBoolean(OBJECT_SELF, 122, TRUE);
        }

        oPC1 = GetPartyMemberByIndex(0);
        oPC2 = GetPartyMemberByIndex(1);
        oPC3 = GetPartyMemberByIndex(2);

        if(GetIsObjectValid(oPC1) && GetCurrentHitPoints(oPC1) > 0)
            nPartySize++;
        if(GetIsObjectValid(oPC2) && GetCurrentHitPoints(oPC2) > 0)
            nPartySize++;
        if(GetIsObjectValid(oPC3) && GetCurrentHitPoints(oPC3) > 0)
            nPartySize++;

        int nPC_Level = GetHitDice(GetFirstPC());
        int nCreatureLevel = GetLevelByClass(GetClassByPosition(1, OBJECT_SELF), OBJECT_SELF);

        // Creature defenses are based on the highest attack and force power dc of party members
        // Creature offenses are based on the average of the party's defenses

        // Find highest attack bonus in party and force power save dc
        if (GetIsObjectValid(oPC1) && !GetIsDead(oPC1))
        {
            /*
            nHenchBonus = ToHitCalc(oPC1);

            if (nHenchBonus > nToHit)
                nToHit = nHenchBonus;

            nHenchBonus = Save_DC_Calc(oPC1);

            if (nHenchBonus > nSaveDC)
                nSaveDC = nHenchBonus;

            nHenchBonus = FP_DC_Calc(oPC1);

            if (nHenchBonus > nFP_DC)
                nFP_DC = nHenchBonus;
            */

            nAvgAC += GetAC(oPC1);

            nAvgVP += GetMaxHitPoints(oPC1);
        }

        if (GetIsObjectValid(oPC2) && !GetIsDead(oPC2))
        {
            /* nHenchBonus = ToHitCalc(oPC2);

            if (nHenchBonus > nToHit)
                nToHit = nHenchBonus;

            nHenchBonus = Save_DC_Calc(oPC2);

            if (nHenchBonus > nSaveDC)
                nSaveDC = nHenchBonus;

            nHenchBonus = FP_DC_Calc(oPC2);

            if (nHenchBonus > nFP_DC)
                nFP_DC = nHenchBonus; */

            nAvgAC += GetAC(oPC2);

            nAvgVP += GetMaxHitPoints(oPC2);
        }

        if (GetIsObjectValid(oPC3) && !GetIsDead(oPC3))
        {
            /* nHenchBonus = ToHitCalc(oPC3);

            if (nHenchBonus > nToHit)
                nToHit = nHenchBonus;

            nHenchBonus = Save_DC_Calc(oPC3);

            if (nHenchBonus > nSaveDC)
                nSaveDC = nHenchBonus;

            nHenchBonus = FP_DC_Calc(oPC3);

            if (nHenchBonus > nFP_DC)
                nFP_DC = nHenchBonus; */

            nAvgAC += GetAC(oPC3);

            nAvgVP += GetMaxHitPoints(oPC3);
        }

        nAvgAC /= nPartySize;

        eEffect = EffectMissChance(1);

        int a, b;
        a = nAvgAC - 6 - GetLocalNumber(OBJECT_SELF, 17); // -6 = 75% chance to hit

        b = 18 - 6 - abs(GetLocalNumber(OBJECT_SELF, 17)); // -6 = 75% chance to hit assuming baseline 18 def

        nAttackBonus = (a < b) ? a : b;
        //nAttackBonus = 15;

        if (nAttackBonus > 0)
            eEffect = EffectLinkEffects(eEffect, EffectAttackIncrease(nAttackBonus));

        // to hit + 11 = 50% chance to get hit
        // nDefBonus = (nToHit + 11) - GetLocalNumber(OBJECT_SELF, 13);

        // player level + 11 = 50% hit chance for high bab chars as baseline
        nDefBonus = (nPC_Level + 11) - GetLocalNumber(OBJECT_SELF, 13);

        if (nDefBonus > 0)
            eEffect = EffectLinkEffects(eEffect, EffectACIncrease(nDefBonus, AC_NATURAL_BONUS));

        // Save DC - 11 = 50% chance to succeed
        // We give enemies a 50% save chance against force powers assuming a baseline of +4 to save dcs
        nSaveDC = nPC_Level + 5 + 4;

        nSaveBonus = nSaveDC - 11 - GetLocalNumber(OBJECT_SELF, 14);
        if (nSaveBonus > 0)
            eEffect = EffectLinkEffects(eEffect, EffectSavingThrowIncrease(SAVING_THROW_FORT, nSaveBonus));

        nSaveBonus = nSaveDC - 11 - GetLocalNumber(OBJECT_SELF, 15);
        if (nSaveBonus > 0)
            eEffect = EffectLinkEffects(eEffect, EffectSavingThrowIncrease(SAVING_THROW_REFLEX, nSaveBonus));

        nSaveBonus = nSaveDC - 11 - GetLocalNumber(OBJECT_SELF, 16);
        if (nSaveBonus > 0)
            eEffect = EffectLinkEffects(eEffect, EffectSavingThrowIncrease(SAVING_THROW_WILL, nSaveBonus));

        /* Apply force power save bonus
        nSaveBonus = nFP_DC - 11 - GetLocalNumber(OBJECT_SELF, 14) - (nPC_Level);
        if (nSaveBonus > 0)
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSavingThrowIncrease(SAVING_THROW_FORT, nSaveBonus, SAVING_THROW_TYPE_FORCE_POWER), OBJECT_SELF, 3.0);

        nSaveBonus = nFP_DC - 11 - GetLocalNumber(OBJECT_SELF, 15) - (nPC_Level);
        if (nSaveBonus > 0)
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSavingThrowIncrease(SAVING_THROW_REFLEX, nSaveBonus, SAVING_THROW_TYPE_FORCE_POWER), OBJECT_SELF, 3.0);

        nSaveBonus = nFP_DC - 11 - GetLocalNumber(OBJECT_SELF, 16) - (nPC_Level);
        if (nSaveBonus > 0)
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSavingThrowIncrease(SAVING_THROW_WILL, nSaveBonus, SAVING_THROW_TYPE_FORCE_POWER), OBJECT_SELF, 3.0); */

        // # of attacks

        // VP
        nLevelDiff = nPC_Level - nCreatureLevel;

        // if (nLevelDiff >= 15)
        //    nMaxHp = 12 * 15 + (nLevelDiff - 15) * 49;
        //else
        nMaxHp = 12 * nLevelDiff;

        if (!GetLocalBoolean(OBJECT_SELF, 122) && GetMaxHitPoints() < nMaxHp)
            SetMaxHitPoints(OBJECT_SELF, nMaxHp);

        // Bonus damage = to a % of the average hp of party
        nAvgVP /= nPartySize;
        nDamage = nAvgVP * 14 / 100;
        // nDamage = nDamage * nPartySize / 3;

        // Subtract Strength bonus or not
        if (!GetWeaponRanged(oWeapon) && (GetAbilityModifier(ABILITY_STRENGTH, OBJECT_SELF) > 0))
            nDamage -= GetAbilityModifier(ABILITY_STRENGTH, OBJECT_SELF);

        // Get base damage of weapon and subtract it
        nWeaponType = GetBaseItemType(oWeapon);

        if(nWeaponType == BASE_ITEM_HOLD_OUT_BLASTER ||
            nWeaponType == BASE_ITEM_SONIC_PISTOL
        )
            nDamage -= d4();

            else if(nWeaponType == BASE_ITEM_QUARTER_STAFF ||
                nWeaponType == BASE_ITEM_SHORT_SWORD ||
                nWeaponType == BASE_ITEM_ION_BLASTER ||
                nWeaponType == BASE_ITEM_DISRUPTER_PISTOL
            )
                nDamage -= d6();

                else if(nWeaponType == BASE_ITEM_BLASTER_PISTOL ||
                    nWeaponType == BASE_ITEM_GHAFFI_STICK
                )
                    nDamage -= d8();

                    else if(nWeaponType == BASE_ITEM_VIBRO_BLADE ||
                        nWeaponType == BASE_ITEM_HEAVY_BLASTER ||
                        nWeaponType == BASE_ITEM_ION_RIFLE ||
                        nWeaponType == BASE_ITEM_BOWCASTER ||
                        nWeaponType == BASE_ITEM_DISRUPTER_RIFLE ||
                        nWeaponType == BASE_ITEM_SONIC_RIFLE ||
                        nWeaponType == BASE_ITEM_WOOKIE_WARBLADE
                    )
                        nDamage -= d10();

                        else if(nWeaponType == BASE_ITEM_GAMMOREAN_BATTLEAXE ||
                            nWeaponType == BASE_ITEM_LONG_SWORD ||
                            nWeaponType == BASE_ITEM_BLASTER_CARBINE ||
                            nWeaponType == BASE_ITEM_BLASTER_RIFLE
                        )
                            nDamage -= d12();

                            else if(nWeaponType == BASE_ITEM_VIBRO_SWORD ||
                                nWeaponType == BASE_ITEM_DOUBLE_BLADED_SWORD ||
                                nWeaponType == BASE_ITEM_REPEATING_BLASTER ||
                                nWeaponType == BASE_ITEM_FORCE_PIKE
                            )
                                nDamage -= d6(2);

                                else if(nWeaponType == BASE_ITEM_SHORT_LIGHTSABER ||
                                    nWeaponType == BASE_ITEM_VIBRO_DOUBLE_BLADE ||
                                    nWeaponType == BASE_ITEM_HEAVY_REPEATING_BLASTER
                                )
                                    nDamage -= d8(2);

                                    else if(nWeaponType == BASE_ITEM_LIGHTSABER)
                                        nDamage -= d10(2);

        else if(nWeaponType == BASE_ITEM_DOUBLE_BLADED_LIGHTSABER)
            nDamage -= d12(2);

        if (nDamage < 0)
            nDamage = 0;

        i = (nDamage / 5);
        // i = 25 / 5;

        for(i; i > 0; i--)
        {
            eEffect = EffectLinkEffects(eEffect, EffectDamageIncrease(5, DAMAGE_TYPE_UNIVERSAL));
        }

        if (nDamage > 0)
        {
            effect eDamage = EffectDamageIncrease(nDamage % 5, DAMAGE_TYPE_UNIVERSAL);
            eEffect = EffectLinkEffects(eEffect, eDamage);
        }

        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, OBJECT_SELF));

        // Loop script
        //DelayCommand(3.05, Diff_Balance());
    }
}

int ToHitCalc(object oCreature)
{
    object oOffhand, oItem;
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, oCreature);
    string sItem;

    int   nToHit, nDex, nStr, i, nType1, nType2;
    // float fBAB1, fBAB2;

    // For Overhaul Mod
    // Calculate BAB from classes
    int nClass = GetClassByPosition(1, oCreature);
    int nLevel = GetLevelByClass(nClass, oCreature);
    //fBAB1 = GetBAB(nClass1);

    nClass = GetClassByPosition(2, oCreature);
    nLevel += GetLevelByClass(nClass, oCreature);
    // fBAB2 = GetBAB(nClass2);

    // nToHit = FloatToInt((fBAB1 * nLevel1) + (fBAB2 * nLevel2));

    // nToHit = GetHitDice(oCreature); // doesn't work for some reason??'
    nToHit = nLevel;


    // Add ability modifier bonus
    nDex = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    nStr = GetAbilityModifier(ABILITY_STRENGTH, oCreature);

    if (GetWeaponRanged(oWeapon)) // && nDex > 0) // ranged weapon add dex
        nToHit += nDex;
    else if (GetFeatAcquired(FEAT_FINESSE_MELEE_WEAPONS, oCreature) || // if finesse add greater of str and dex
             GetFeatAcquired(FEAT_FINESSE_LIGHTSABERS, oCreature))
    {
        if (nStr > nDex && nStr > 0)
            nToHit += nStr;
        else if (nDex > 0)
            nToHit += nDex;
    }
    else if (nStr > 0)
        nToHit += nStr;

    // Check for feat bonuses
    nType1 = GetBaseItemType(oWeapon);

    if (GetIsObjectValid(oWeapon))
    {
        if (GetWeaponRanged(oWeapon))
        {
            if (nType1 == BASE_ITEM_BLASTER_PISTOL ||
                nType1 == BASE_ITEM_HEAVY_BLASTER ||
                nType1 == BASE_ITEM_HOLD_OUT_BLASTER ||
                nType1 == BASE_ITEM_ION_BLASTER ||
                nType1 == BASE_ITEM_DISRUPTER_PISTOL ||
                nType1 == BASE_ITEM_SONIC_PISTOL)
            {
                if (GetFeatAcquired(FEAT_WEAPON_FOCUS_BLASTER, oCreature))
                    nToHit += 1;
            }
            else if (GetFeatAcquired(FEAT_WEAPON_FOCUS_BLASTER_RIFLE, oCreature))
                nToHit += 1;
        }
        else
        {
            if(nType1 == BASE_ITEM_DOUBLE_BLADED_LIGHTSABER ||
               nType1 == BASE_ITEM_SHORT_LIGHTSABER ||
               nType1 == BASE_ITEM_LIGHTSABER)
            {
                if (GetFeatAcquired(FEAT_WEAPON_FOCUS_LIGHTSABER, oCreature))
                    nToHit += 1;
                if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_1, oCreature))
                    nToHit += 1;
                if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_2, oCreature))
                    nToHit += 1;
                if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_3, oCreature))
                    nToHit += 1;

                // Check Lightsaber forms
                if (IsFormActive(oCreature, FORM_SABER_I_SHII_CHO))
                    nToHit += 1;
                if (IsFormActive(oCreature, FORM_SABER_V_SHIEN))
                    nToHit += 2;
                if (IsFormActive(oCreature, FORM_SABER_VI_NIMAN))
                    nToHit += 1;
            }
            else if (GetFeatAcquired(FEAT_WEAPON_FOCUS_MELEE_WEAPONS, oCreature))
                nToHit += 1;
        }
    }

    if (GetFeatAcquired(FEAT_TARGETING_1, oCreature) && GetWeaponRanged(oWeapon))
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
    nType2 = GetBaseItemType(oOffhand);

    if (GetIsObjectValid(oOffhand) ||
        nType1 == BASE_ITEM_DOUBLE_BLADED_SWORD ||
        nType1 == BASE_ITEM_VIBRO_DOUBLE_BLADE ||
        nType1 == BASE_ITEM_DOUBLE_BLADED_LIGHTSABER ||
        nType1 == BASE_ITEM_GHAFFI_STICK ||
        nType1 == BASE_ITEM_WOOKIE_WARBLADE ||
        nType1 == BASE_ITEM_QUARTER_STAFF ||
        nType1 == BASE_ITEM_FORCE_PIKE)
    {
        if (nType2 == BASE_ITEM_SHORT_SWORD ||
            nType2 == BASE_ITEM_VIBRO_BLADE ||
            nType1 == BASE_ITEM_QUARTER_STAFF ||
            nType1 == BASE_ITEM_DOUBLE_BLADED_SWORD ||
            nType1 == BASE_ITEM_VIBRO_DOUBLE_BLADE ||
            nType1 == BASE_ITEM_DOUBLE_BLADED_LIGHTSABER ||
            nType2 == BASE_ITEM_SHORT_LIGHTSABER ||
            nType2 == BASE_ITEM_BLASTER_PISTOL ||
            nType2 == BASE_ITEM_HEAVY_BLASTER ||
            nType2 == BASE_ITEM_HOLD_OUT_BLASTER ||
            nType2 == BASE_ITEM_ION_BLASTER ||
            nType2 == BASE_ITEM_DISRUPTER_PISTOL ||
            nType2 == BASE_ITEM_SONIC_PISTOL ||
            nType1 == BASE_ITEM_GHAFFI_STICK ||
            nType1 == BASE_ITEM_WOOKIE_WARBLADE ||
            nType1 == BASE_ITEM_FORCE_PIKE)
        {
            if (!IsObjectPartyMember(oCreature) || GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_2, oCreature)
                || GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_3, oCreature))
                nToHit += 2;
            else if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_TWO_WEAPON_1, oCreature))
                nToHit += 1;
        }

        if (!IsObjectPartyMember(oCreature))
        {
            if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_TWO_WEAPON_1, oCreature))
                nToHit -= 1;
            else if (GetFeatAcquired(85, oCreature)) // Master Two-Weapon Fighting
                nToHit -= 2;
            else if (GetFeatAcquired(9, oCreature)) // Improved Two-Weapon Fighting
                nToHit -= 4;
            else
                nToHit -= 6;
        }
    }

    // Force Power Effects
    if (IsObjectPartyMember(oCreature))
    {
        if (GetHasSpellEffect(FORCE_POWER_MASTER_BATTLE_MEDITATION_PC, oCreature))
            nToHit += 4;
        else if (GetHasSpellEffect(FORCE_POWER_IMPROVED_BATTLE_MEDITATION_PC, oCreature) ||
            GetHasSpellEffect(FORCE_POWER_BATTLE_MEDITATION_PC, oCreature)
        )
            nToHit += 2;
    }

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

    //if (nToHit > 0)
        return nToHit;
    //else
    //    return 0;
}

int FP_DC_Calc(object oCreature)
{
    int nDC;

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

int Save_DC_Calc(object oCreature)
{
    int nDC;

    nDC = GetHitDice(oCreature) + 3 + GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature);

    return nDC;
}
