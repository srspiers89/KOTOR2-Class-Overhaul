// levelup.nss

#include "k_inc_hb"

void LevelUp();
int ToHitCalc(object oCreature);
int PC_DC_Calc();

void LevelUp()
{
    object oPC = GetFirstPC();

    int PC_Level = GetHitDice(oPC);
    int MonsterLevel = GetHitDice(OBJECT_SELF);

    int PC_ToHit = ToHitCalc(oPC);
    int PC_AC = GetAC(oPC);

    int lvlDiff = PC_Level - MonsterLevel;

    int att_bonus;
    int bab_bonus = lvlDiff;
    int fort_bonus, ref_bonus, will_bonus;
    int class_att;
    int vp_bonus, fp_bonus;
    int ac_bonus = 0;
    int nDamage;

    int fort_high = FALSE;
    int ref_high  = FALSE;
    int will_high = FALSE;
    int bab_high  = FALSE;
    int bab_med   = FALSE;
    int bab_low   = FALSE;

    int hitdie, forcedie = 0;

    int nAttacks = 0;

    int nAB = ToHitCalc(OBJECT_SELF);

    // Determine stats to buff base on class_att
    int nClass = GetClassByPosition(1, OBJECT_SELF);

    switch (nClass)
    {
        case CLASS_TYPE_SOLDIER:
        {
            class_att  = ABILITY_STRENGTH;
            fort_high = TRUE;
            bab_high  = TRUE;
            hitdie    = 10;
            ac_bonus  = 9;
        }

        case CLASS_TYPE_SCOUT:
        {
            class_att  = ABILITY_DEXTERITY;
            fort_high = TRUE;
            ref_high  = TRUE;
            will_high = TRUE;
            bab_med   = TRUE;
            hitdie    = 8;
            ac_bonus  = 7;
        }

        case CLASS_TYPE_SCOUNDREL:
        {
            class_att  = ABILITY_DEXTERITY;
            ref_high  = TRUE;
            bab_med   = TRUE;
            hitdie    = 6;
            ac_bonus  = 5;
        }

        case CLASS_TYPE_JEDIGUARDIAN:
        {
            class_att  = ABILITY_STRENGTH;
            fort_high = TRUE;
            ref_high  = TRUE;
            bab_high  = TRUE;
            hitdie    = 10;
            forcedie  = 4;
            ac_bonus  = 8;
        }

        case CLASS_TYPE_JEDICONSULAR:
        {
            class_att  = ABILITY_WISDOM;
            fort_high = TRUE;
            will_high = TRUE;
            bab_low   = TRUE;
            hitdie    = 6;
            forcedie  = 8;
            ac_bonus  = 4;
        }

        case CLASS_TYPE_JEDISENTINEL:
        {
            class_att  = ABILITY_DEXTERITY;
            fort_high = TRUE;
            ref_high  = TRUE;
            bab_med   = TRUE;
            hitdie    = 8;
            forcedie  = 6;
            ac_bonus  = 6;
        }

        case CLASS_TYPE_COMBATDROID:
        {
            class_att  = ABILITY_DEXTERITY;
            fort_high = TRUE;
            bab_high  = TRUE;
            hitdie    = 12;
            ac_bonus  = 9;
        }

        case CLASS_TYPE_EXPERTDROID:
        {
            class_att  = ABILITY_DEXTERITY;
            ref_high  = TRUE;
            bab_med   = TRUE;
            hitdie    = 8;
            ac_bonus  = 7;
        }

        case CLASS_TYPE_MINION:
        {
            class_att  = ABILITY_DEXTERITY;
            fort_high = TRUE;
            ref_high  = TRUE;
            will_high = TRUE;
            bab_high  = TRUE;
            hitdie    = 10;
            ac_bonus  = 9;
        }

        case CLASS_TYPE_TECHSPECIALIST:
        {
            class_att  = ABILITY_DEXTERITY;
            ref_high  = TRUE;
            will_high = TRUE;
            bab_med   = TRUE;
            hitdie    = 6;
            ac_bonus  = 7;
        }

        case CLASS_TYPE_JEDIWEAPONMASTER:
        {
            class_att  = ABILITY_STRENGTH;
            fort_high = TRUE;
            bab_high  = TRUE;
            hitdie    = 10;
            forcedie  = 6;
            ac_bonus  = 9;
        }

        case CLASS_TYPE_JEDIMASTER:
        {
            class_att  = ABILITY_WISDOM;
            will_high = TRUE;
            bab_low   = TRUE;
            hitdie    = 6;
            forcedie  = 10;
            ac_bonus  = 5;
        }

        case CLASS_TYPE_JEDIWATCHMAN:
        {
            class_att  = ABILITY_STRENGTH;
            fort_high = TRUE;
            ref_high  = TRUE;
            will_high = TRUE;
            bab_med   = TRUE;
            hitdie    = 8;
            forcedie  = 8;
            ac_bonus  = 7;
        }

        case CLASS_TYPE_SITHMARAUDER:
        {
            class_att  = ABILITY_STRENGTH;
            fort_high = TRUE;
            bab_high  = TRUE;
            hitdie    = 10;
            forcedie  = 6;
            ac_bonus  = 9;
        }

        case CLASS_TYPE_SITHLORD:
        {
            class_att  = ABILITY_WISDOM;
            will_high = TRUE;
            bab_low   = TRUE;
            hitdie    = 6;
            forcedie  = 10;
            ac_bonus  = 5;
        }

        case CLASS_TYPE_SITHASSASSIN:
        {
            class_att  = ABILITY_DEXTERITY;
            ref_high  = TRUE;
            bab_med   = TRUE;
            hitdie    = 8;
            forcedie  = 8;
            ac_bonus  = 7;
        }
    }

    // Determine attribute bonus
    att_bonus = (PC_Level / 4) - (MonsterLevel / 4);

    // Calculate BAB bonus and extra attacks
    if (bab_high == TRUE)
        nAttacks = (PC_Level + 4) / 5 - 1;

    if (bab_med == TRUE)
    {
        bab_bonus = (PC_Level * 3 / 4) - (MonsterLevel * 3 / 4);
        nAttacks = ((PC_Level * 3 / 4) + 4) / 5 - 1;
    }

    if (bab_low == TRUE)
    {
        bab_bonus = (PC_Level / 2) - (MonsterLevel / 2);
        nAttacks = ((PC_Level / 2) + 4) / 5 - 1;
    }

    bab_bonus = PC_AC - 11;

    // Calculate saving throw bonus
    if (fort_high == TRUE)
        fort_bonus = (PC_Level / 2 + 2) - (MonsterLevel / 2 + 2);
    else
        fort_bonus = (PC_Level / 3) - (MonsterLevel / 3);

    if (ref_high == TRUE)
        ref_bonus = (PC_Level / 2 + 2) - (MonsterLevel / 2 + 2);
    else
        ref_bonus = (PC_Level / 3) - (MonsterLevel / 3);

    if (will_high == TRUE)
        will_bonus = (PC_Level / 2 + 2) - (MonsterLevel / 2 + 2);
    else
        will_bonus = (PC_Level / 3) - (MonsterLevel / 3);

    // Calculate Defense bonuses
    if (GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_BODY, OBJECT_SELF))) // Check if armor equipped
        ac_bonus = 0;

    // add enhancement bonus based on level
    //ac_bonus = ac_bonus + (PC_Level / 4);

    ac_bonus = (PC_ToHit + 11) - GetAC(OBJECT_SELF);
    //ac_bonus = GetPartyMemberCount();

    // Calculate vp and fp bonus
    vp_bonus = hitdie * lvlDiff;
    fp_bonus = forcedie * lvlDiff;

    // Calculate Damage Bonus
    effect eLink1;
    int i;
    nDamage = GetMaxHitPoints(oPC) * 4 / 10;
    nDamage = nDamage * GetPartyMemberCount() / 3;
    i = (nDamage / 5) - 1;
    eLink1 = EffectDamageIncrease(5);

    for(i; i > 0; i--)
    {
        eLink1 = EffectLinkEffects(eLink1, EffectDamageIncrease(5));
    }

    eLink1 = EffectLinkEffects(eLink1, EffectDamageIncrease(nDamage % 5));

    // Apply attribute bonuses
    if (att_bonus > 0)
        AdjustCreatureAttributes(OBJECT_SELF,class_att ,att_bonus);

    // Apply vp bonus
    if (vp_bonus > 0)
        SetMaxHitPoints(OBJECT_SELF, GetMaxHitPoints(OBJECT_SELF) + vp_bonus);

    // Apply fp bonus
    if (fp_bonus > 0)
        AddBonusForcePoints(OBJECT_SELF, fp_bonus);

    // Apply saving throw bonuses
    if (fort_bonus > 0)
        ModifyFortitudeSavingThrowBase(OBJECT_SELF, fort_bonus);
    if (ref_bonus > 0)
        ModifyFortitudeSavingThrowBase(OBJECT_SELF, ref_bonus);
    if (will_bonus > 0)
        ModifyFortitudeSavingThrowBase(OBJECT_SELF, fort_bonus);

    // Apply bab bonus
    if (bab_bonus > 0)
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectAttackIncrease(bab_bonus), OBJECT_SELF);

    // Apply extra attacks
    if (nAttacks > 0)
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectModifyAttacks(nAttacks), OBJECT_SELF);

    // Apply Defense Bonus
    if (ac_bonus > 0)
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectACIncrease(ac_bonus, AC_NATURAL_BONUS), OBJECT_SELF);

    // Apply Damage Bonus
    // effect eDamage = EffectDamageIncrease(20);

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink1, OBJECT_SELF);

    //  Flag that the creature has been buffed
    SetLocalBoolean(OBJECT_SELF, 122, TRUE);

}

int ToHitCalc(object oCreature)
{
    object oOffhand, oItem;
    string sItem;

    int   nToHit, nDex, nStr, i, nType;
    float fBAB1, fBAB2;

    // Calculate BAB from classes
    int nClass1 = GetClassByPosition(1, oCreature);
    int nLevel1 = GetLevelByClass(nClass1, oCreature);
    fBAB1 = GetBAB(nClass1);

    int nClass2 = GetClassByPosition(2, oCreature);
    int nLevel2 = GetLevelByClass(nClass2, oCreature);
    fBAB2 = GetBAB(nClass2);

    nToHit = FloatToInt((fBAB1 * nLevel1) + (fBAB2 * nLevel2));

    // Add ability modifier bonus
    nDex = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    nStr = GetAbilityModifier(ABILITY_STRENGTH, oCreature);

    if (GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, oCreature))) // ranged weapon add dex
        nToHit = nToHit + nDex;
    else if (GetFeatAcquired(FEAT_FINESSE_MELEE_WEAPONS, oCreature) || // if finesse add greater of str and dex
             GetFeatAcquired(FEAT_FINESSE_LIGHTSABERS, oCreature))
    {
        if (nStr > nDex)
            nToHit = nToHit + nStr;
        else
            nToHit = nToHit + nDex;
    }
    else
        nToHit = nToHit + nStr;

    // Check for feat bonuses
    if (GetFeatAcquired(FEAT_WEAPON_FOCUS_BLASTER, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_BLASTER_RIFLE, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_GRENADE, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_HEAVY_WEAPONS, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_LIGHTSABER, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_MELEE_WEAPONS, oCreature) ||
        GetFeatAcquired(FEAT_WEAPON_FOCUS_SIMPLE_WEAPONS, oCreature)
       )
        nToHit = nToHit + 1;

    if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_1, oCreature))
        nToHit = nToHit + 1;
    if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_2, oCreature))
        nToHit = nToHit + 1;
    if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_LIGHTSABER_3, oCreature))
        nToHit = nToHit + 1;

    if (GetFeatAcquired(FEAT_TARGETING_1, oCreature) && GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, oCreature)))
    {
        nToHit = nToHit + 1;
        i = FEAT_TARGETING_2;

        while (i <=  FEAT_TARGETING_10)
        {
            if (GetFeatAcquired(i, oCreature))
                nToHit = nToHit + 1;

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
            nToHit = nToHit + 2;

        if (GetFeatAcquired(FEAT_SUPERIOR_WEAPON_FOCUS_TWO_WEAPON_1))
            nToHit = nToHit - 1;
        else if (GetFeatAcquired(85)) // Master Two-Weapon Fighting
            nToHit = nToHit - 2;
        else if (GetFeatAcquired(9)) // Improved Two-Weapon Fighting
            nToHit = nToHit - 4;
        else
            nToHit = nToHit - 6;
    }

    // Check Lightsaber forms
    if (IsFormActive(oCreature, FORM_SABER_I_SHII_CHO))
        nToHit = nToHit + 1;
    if (IsFormActive(oCreature, FORM_SABER_V_SHIEN))
        nToHit = nToHit + 2;
    if (IsFormActive(oCreature, FORM_SABER_VI_NIMAN))
        nToHit = nToHit + 1;

    // Force Power Effects
    if (GetHasSpellEffect(FORCE_POWER_MASTER_BATTLE_MEDITATION_PC, oCreature))
        nToHit = nToHit + 4;
    else if (GetHasSpellEffect(FORCE_POWER_IMPROVED_BATTLE_MEDITATION_PC, oCreature) ||
             GetHasSpellEffect(FORCE_POWER_BATTLE_MEDITATION_PC, oCreature)
    )
        nToHit = nToHit + 2;

    if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_V, oCreature))
        nToHit = nToHit + 5;
    else if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_IV, oCreature))
        nToHit = nToHit + 4;
    else if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_III, oCreature))
        nToHit = nToHit + 3;
    else if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_II, oCreature))
        nToHit = nToHit + 2;
    else if (GetHasSpellEffect(FORCE_POWER_INSPIRE_FOLLOWERS_I, oCreature))
        nToHit = nToHit + 1;

    if (GetHasSpellEffect(77, oCreature)) // Echani Battle Stim
        nToHit = nToHit + 3;
    else if (GetHasSpellEffect(76, oCreature)) // Hyper-Battle Stim
        nToHit = nToHit + 2;
    else if (GetHasSpellEffect(75, oCreature)) // Battle Stim
        nToHit = nToHit + 1;

    // Get bonuses from items
    oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oCreature);
    if (GetIsObjectValid(oItem))
    {
        sItem = GetTag(oItem);
        if (sItem == "a_helmet_19" ||
            sItem == "a_helmet_08"
        )
            nToHit = nToHit + 1;
            if (sItem == "a_helmet_24")
                nToHit = nToHit + 2;
        if (sItem == "a_helmet_16")
            nToHit = nToHit + 3;
    }

    oItem = GetItemInSlot(INVENTORY_SLOT_IMPLANT, oCreature);
    if (GetIsObjectValid(oItem))
    {
        sItem = GetTag(oItem);
        if (sItem == "e_imp3_04")
            nToHit = nToHit + 1;
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
            nToHit = nToHit + 1;

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
            nToHit = nToHit + 2;

        if (sItem == "w_blaste_19" ||
            sItem == "w_brifle_21"
        )
            nToHit = nToHit + 3;

        if (sItem == "w_brifle_23")
            nToHit = nToHit + 4;
    }

    // Add bonus based on level to account for items
    if (IsObjectPartyMember(oCreature))
        nToHit = nToHit + (GetHitDice(oCreature) / 5);

    return nToHit;
}

int PC_DC_Calc()
{
    int nDC = 0, i = 0;
    object oPC;

    // Get highest spell dc in party
    for (i; i > 2; i++)
    {
        oPC = GetPartyMemberByIndex(i);

        if (nDC < (5 + GetHitDice(oPC) + GetAbilityModifier(ABILITY_WISDOM, oPC) + GetAbilityModifier(ABILITY_CHARISMA, oPC)))
            nDC = 5 + GetHitDice(oPC) + GetAbilityModifier(ABILITY_WISDOM, oPC) + GetAbilityModifier(ABILITY_CHARISMA, oPC);
    }

    return nDC;
}
