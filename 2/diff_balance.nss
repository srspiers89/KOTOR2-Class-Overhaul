// diff_balance.nss

#include "k_inc_gensupport"

void Diff_Balance();
int ToHitCalc(object oCreature);
int DC_Calc(object oCreature);

void Diff_Balance()
{
    int nDamage, nDamageType, nWeaponType, i, nMaxHp, nToHit, nAttackBonus, nDefBonus, nSaveBonus, nDC, nPartySize;
    int nHenchBonus, nAvgAC, nAvgVP;
    object oPC1, oPC2, oPC3;
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, OBJECT_SELF);

    if (!GetLocalBoolean(OBJECT_SELF, 122))
    {
        SetLocalNumber(OBJECT_SELF, 13, GetAC(OBJECT_SELF)); // set local number 13 to Original AC
        SetLocalNumber(OBJECT_SELF, 14, GetFortitudeSavingThrow(OBJECT_SELF)); // set local number 14 to Original fort save
        SetLocalNumber(OBJECT_SELF, 15, GetReflexSavingThrow(OBJECT_SELF)); // set local number 15 to Original reflex save
        SetLocalNumber(OBJECT_SELF, 16, GetWillSavingThrow(OBJECT_SELF)); // set local number 16 to Original will save
    }

    oPC1 = GetPartyMemberByIndex(0);
    oPC2 = GetPartyMemberByIndex(1);
    oPC3 = GetPartyMemberByIndex(2);

    int nLevel = GetHitDice(GetFirstPC());
    nPartySize = GN_GetActivePartyMemberCount();

    // Creature defenses are based on the highest attack and force power dc of party members
    // Creature offenses are based on the average of the party's defenses

    // Find highest attack bonus in party and force power save dc
    if (GetIsObjectValid(oPC1) && !GetIsDead(oPC1))
    {
        nToHit = ToHitCalc(oPC1);
        nDC = DC_Calc(oPC1);
        nAvgAC = GetAC(oPC1);
        nAvgVP = GetMaxHitPoints(oPC1);
    }

    if (GetIsObjectValid(oPC2) && !GetIsDead(oPC2))
    {
        nHenchBonus = ToHitCalc(oPC2);

        if (nHenchBonus > nToHit)
            nToHit = nHenchBonus;

        nHenchBonus = DC_Calc(oPC2);

        if (nHenchBonus > nDC)
            nDC = nHenchBonus;

        nAvgAC += GetAC(oPC2);

        nAvgVP += GetMaxHitPoints(oPC2);
    }

    if (GetIsObjectValid(oPC3) && !GetIsDead(oPC3))
    {
        nHenchBonus = ToHitCalc(oPC3);

        if (nHenchBonus > nToHit)
            nToHit = nHenchBonus;

        nHenchBonus = DC_Calc(oPC3);

        if (nHenchBonus > nDC)
            nDC = nHenchBonus;

        nAvgAC += GetAC(oPC3);

        nAvgVP += GetMaxHitPoints(oPC3);
    }

    nAvgAC /= nPartySize;
    nAttackBonus = nAvgAC - 6 - ToHitCalc(OBJECT_SELF); // -6 = 75% chance to hit

    if (nAttackBonus > 0)
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackIncrease(nAttackBonus), OBJECT_SELF, 3.0);

    // to hit + 11 = 50% chance to get hit
    nDefBonus = (nToHit + 11) - GetLocalNumber(OBJECT_SELF, 13);

    if (nDefBonus > 0)
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectACIncrease(nPartySize, AC_NATURAL_BONUS), OBJECT_SELF, 3.0);

    // Save DC - 11 = 50% chance to succeed
    nSaveBonus = nDC - 11 - GetLocalNumber(OBJECT_SELF, 14);
    if (nSaveBonus > 0)
       // ModifyFortitudeSavingThrowBase(OBJECT_SELF, nSaveBonus);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSavingThrowIncrease(SAVING_THROW_FORT, nSaveBonus), OBJECT_SELF, 3.0);

    nSaveBonus = nDC - 11 - GetLocalNumber(OBJECT_SELF, 15);
    if (nSaveBonus > 0)
        // ModifyReflexSavingThrowBase(OBJECT_SELF, nSaveBonus);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSavingThrowIncrease(SAVING_THROW_REFLEX, nSaveBonus), OBJECT_SELF, 3.0);

    nSaveBonus = nDC - 11 - GetLocalNumber(OBJECT_SELF, 16);
    if (nSaveBonus > 0)
        // ModifyWillSavingThrowBase(OBJECT_SELF, nSaveBonus);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSavingThrowIncrease(SAVING_THROW_WILL, nSaveBonus), OBJECT_SELF, 3.0);

    // # of attacks

    // VP
    if (nLevel > 15)
        nMaxHp = 12 * 15 + (nLevel - 15) * 49;
    else
        nMaxHp = 12 * nLevel;

    if (!GetLocalBoolean(OBJECT_SELF, 122))
        SetMaxHitPoints(OBJECT_SELF, nMaxHp);

    // Damage
    nAvgVP /= nPartySize;
    nDamage = nAvgVP * 1 / 10;
    nDamage = nDamage * nPartySize / 3;

    // Subtract Strength bonus or not
    if (!GetWeaponRanged(oWeapon))
        nDamage -= GetAbilityModifier(ABILITY_STRENGTH, OBJECT_SELF);

    /* // Get damage type
    nWeaponType = GetBaseItemType(oWeapon);

    if(nWeaponType == BASE_ITEM_BLASTER_PISTOL ||
        nWeaponType == BASE_ITEM_HEAVY_BLASTER ||
        nWeaponType == BASE_ITEM_HOLD_OUT_BLASTER ||
        nWeaponType == BASE_ITEM_BOWCASTER ||
        nWeaponType == BASE_ITEM_BLASTER_CARBINE ||
        nWeaponType == BASE_ITEM_REPEATING_BLASTER ||
        nWeaponType == BASE_ITEM_HEAVY_REPEATING_BLASTER ||
        nWeaponType == BASE_ITEM_BLASTER_RIFLE ||
        nWeaponType == BASE_ITEM_LIGHTSABER ||
        nWeaponType == BASE_ITEM_DOUBLE_BLADED_LIGHTSABER ||
        nWeaponType == BASE_ITEM_SHORT_LIGHTSABER
    )
        nDamageType = 4096;

    else if(nWeaponType == BASE_ITEM_ION_BLASTER ||
            nWeaponType == BASE_ITEM_ION_RIFLE
    )
            nDamageType = 2048;

    else if(nWeaponType == BASE_ITEM_DISRUPTER_PISTOL ||
            nWeaponType == BASE_ITEM_DISRUPTER_RIFLE
    )
            nDamageType = 8;

    else if(nWeaponType == BASE_ITEM_SONIC_PISTOL ||
            nWeaponType == BASE_ITEM_SONIC_RIFLE
    )
            nDamageType = 1024;
    else
            nDamageType = DAMAGE_TYPE_BLUDGEONING; */

    i = (nDamage / 5);
    // i = 25 / 5;

    for(i; i > 0; i--)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageIncrease(5, DAMAGE_TYPE_UNIVERSAL), OBJECT_SELF, 3.0);
    }

    effect eDamage = EffectDamageIncrease(nDamage % 5, DAMAGE_TYPE_UNIVERSAL);

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDamage, OBJECT_SELF, 3.0);

    // Flag that the creature has been buffed
    SetLocalBoolean(OBJECT_SELF, 122, TRUE);

    // Loop script
    DelayCommand(3.0, Diff_Balance());
}

int ToHitCalc(object oCreature)
{
    object oOffhand, oItem;
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, oCreature);
    string sItem;

    int   nToHit, nDex, nStr, i, nType;
    // float fBAB1, fBAB2;

    // For Overhaul Mod
    // Calculate BAB from classes
    int nClass1 = GetClassByPosition(1, oCreature);
    int nLevel1 = GetLevelByClass(nClass1, oCreature);
    //fBAB1 = GetBAB(nClass1);

    int nClass2 = GetClassByPosition(2, oCreature);
    int nLevel2 = GetLevelByClass(nClass2, oCreature);
    // fBAB2 = GetBAB(nClass2);

    // nToHit = FloatToInt((fBAB1 * nLevel1) + (fBAB2 * nLevel2));

    // nToHit = GetHitDice(oCreature);
    nToHit = nLevel1 + nLevel2;


    // Add ability modifier bonus
    nDex = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    nStr = GetAbilityModifier(ABILITY_STRENGTH, oCreature);

    if (GetWeaponRanged(oWeapon)) // ranged weapon add dex
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
    nType = GetBaseItemType(oWeapon);

    if (GetIsObjectValid(oWeapon))
    {
        if (GetWeaponRanged(oWeapon))
        {
            if (nType == BASE_ITEM_BLASTER_PISTOL ||
                nType == BASE_ITEM_HEAVY_BLASTER ||
                nType == BASE_ITEM_HOLD_OUT_BLASTER ||
                nType == BASE_ITEM_ION_BLASTER ||
                nType == BASE_ITEM_DISRUPTER_PISTOL ||
                nType == BASE_ITEM_SONIC_PISTOL)
            {
                if (GetFeatAcquired(FEAT_WEAPON_FOCUS_BLASTER, oCreature))
                    nToHit += 1;
            }
            else if (GetFeatAcquired(FEAT_WEAPON_FOCUS_BLASTER_RIFLE, oCreature))
                nToHit += 1;
        }
        else
        {
            if(nType == BASE_ITEM_DOUBLE_BLADED_LIGHTSABER ||
               nType == BASE_ITEM_SHORT_LIGHTSABER ||
               nType == BASE_ITEM_LIGHTSABER)
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

    if (nToHit > 0)
        return nToHit;
    else
        return 0;
}

int DC_Calc(object oCreature)
{
    int nDC = 0, i = 0;

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
