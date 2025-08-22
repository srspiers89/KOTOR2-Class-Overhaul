// k_inc_elite.nss
//
// Elite Enemies Mod

void SpawnElite();
string ChooseWeapon(string sBase);
void ChooseClass();

void SpawnElite()
{
    if (d100() > 50) // Chance to spawn elite
    {
        object oEnemy = OBJECT_SELF;

        location lLoc = Location(GetPosition(oEnemy) + AngleToVector(GetFacing(oEnemy)) * 3.0, GetFacing(oEnemy) - 180.0);

        string sResRef;
        object oBaseItem, oBaseItem2;
        object oArmor, oWeapon1, oWeapon2;
        string sBase, sBase2, sRand;
        int nRand;

        // Get appearance of enemy
        int nAppearance = GetAppearanceType(oEnemy);

        // Change name of elite
        string sOldName = GetName(oEnemy);
        string sNewName = "Elite " + sOldName;

        SetCustomToken(4242, sNewName);

        // Get race of creature
        if (GetRacialType(oEnemy) == 5)
            sResRef = "elite_droid";
        else
            sResRef = "elite_meatbag";

        object oElite = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
        // ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_STEALTH_PULSE), oElite);
        ChangeObjectAppearance(oElite, nAppearance); // Change appearance of elite to match

        // Choose Class for Elite


        // Copy equipped items to elite

        // Choose Armor
        if (sResRef == "elite_droid")
        {
            sBase = "d_armor_";

            oArmor = CreateItemOnObject(ChooseWeapon(sBase), oElite, 1, TRUE);
            AssignCommand(oElite, ActionEquipItem(oArmor, INVENTORY_SLOT_BODY, TRUE));
        }
        else
        {
            nRand = d3();

            if (nRand == 1)
                sBase = "a_light_";
            else if (nRand == 2)
                sBase = "a_medium_";
            else if (nRand == 3)
                sBase = "a_heavy_";

            oArmor = CreateItemOnObject(ChooseWeapon(sBase), oElite, 1, TRUE);
            AssignCommand(oElite, ActionEquipItem(oArmor, INVENTORY_SLOT_BODY, TRUE));
        }

        // Choose Weapons
        if (GetSubRace(oEnemy) == 2) // If enemy if creature create creature weapons
        {
            oWeapon1 = CreateItemOnObject("G_W_CRSLASH005", oElite, 1, TRUE);
            AssignCommand(oElite, ActionEquipItem(oWeapon1, INVENTORY_SLOT_CWEAPON_L, TRUE));
        }
        else
        {
            oBaseItem = GetItemInSlot(INVENTORY_SLOT_RIGHTWEAPON, oEnemy); // check enemy weapon

            if (GetIsObjectValid(oBaseItem)){
                if (GetWeaponRanged(oBaseItem)) // If ranged equip same base item type for animation compatability
                {
                    if (GetBaseItemType(oBaseItem) >= 12 && GetBaseItemType(oBaseItem) < 18) // Choose random blaster pistol
                    {
                        sBase = "w_blaste_";

                        oWeapon1 = CreateItemOnObject(ChooseWeapon(sBase), oElite, 1, TRUE);
                        oWeapon2 = CreateItemOnObject(ChooseWeapon(sBase), oElite, 1, TRUE);
                        if (GetIsObjectValid(oWeapon1))
                        {
                            AssignCommand(oElite, ActionEquipItem(oWeapon1, INVENTORY_SLOT_RIGHTWEAPON, TRUE));
                            DelayCommand(0.2, AssignCommand(oElite, ActionEquipItem(oWeapon2, INVENTORY_SLOT_LEFTWEAPON, TRUE)));
                        }


                    }
                    else // Choose random blaster rifle
                    {
                        sBase = "w_brifle_";

                        oWeapon1 = CreateItemOnObject(ChooseWeapon(sBase), oElite, 1, TRUE);
                        if (GetIsObjectValid(oWeapon1))
                            AssignCommand(oElite, ActionEquipItem(oWeapon1, INVENTORY_SLOT_RIGHTWEAPON, TRUE));
                    }
                }
                else
                {
                    // Check if lightsaber
                    if (GetBaseItemType(oBaseItem) >= 8 && GetBaseItemType(oBaseItem) < 11)
                    {
                        // Choose doublesaber or not
                        if (d2() == 1)
                            sBase = "G_W_DBLSBR0";
                        else
                        {
                            sBase = "g_w_lghtsbr";
                            sBase2 = "g_w_shortsbr";
                        }

                        if (sBase == "G_W_DBLSBR0")
                        {
                            oWeapon1 = CreateItemOnObject(ChooseWeapon(sBase), oElite, 1, TRUE);
                            if (GetIsObjectValid(oWeapon1))
                                AssignCommand(oElite, ActionEquipItem(oWeapon1, INVENTORY_SLOT_RIGHTWEAPON, TRUE));
                        }
                        else
                        {
                            // Equip 2 sabers
                            oWeapon1 = CreateItemOnObject(ChooseWeapon(sBase), oElite, 1, TRUE);
                            oWeapon2 = CreateItemOnObject(ChooseWeapon(sBase2), oElite, 1, TRUE);

                            if (GetIsObjectValid(oWeapon1))
                            {
                                AssignCommand(oElite, ActionEquipItem(oWeapon1, INVENTORY_SLOT_RIGHTWEAPON, TRUE));
                                if(GetIsObjectValid(oWeapon2))
                                    DelayCommand(0.2, AssignCommand(oElite, ActionEquipItem(oWeapon2, INVENTORY_SLOT_LEFTWEAPON, TRUE)));
                            }
                        }
                    }
                    else // Melee Weapons
                    {
                        sBase = ChooseWeapon("w_melee_");

                        // Double Weapons
                        if(sBase == "w_melee_04" ||
                            sBase == "w_melee_07" ||
                            sBase == "w_melee_12" ||
                            sBase == "w_melee_14" ||
                            sBase == "w_melee_15" ||
                            sBase == "w_melee_20" ||
                            sBase == "w_melee_23" ||
                            sBase == "w_melee_26" ||
                            sBase == "w_melee_28" ||
                            sBase == "w_melee_30")
                        {
                            oWeapon1 = CreateItemOnObject(sBase, oElite, 1, TRUE);
                            if (GetIsObjectValid(oWeapon1))
                                AssignCommand(oElite, ActionEquipItem(oWeapon1, INVENTORY_SLOT_RIGHTWEAPON, TRUE));
                        }
                        else // one handers
                        {
                            oWeapon1 = CreateItemOnObject(sBase, oElite, 1, TRUE);
                            oWeapon2 = CreateItemOnObject(sBase, oElite, 1, TRUE);

                            if (GetIsObjectValid(oWeapon1))
                            {
                                AssignCommand(oElite, ActionEquipItem(oWeapon1, INVENTORY_SLOT_RIGHTWEAPON, TRUE));
                                if(GetIsObjectValid(oWeapon2))
                                    DelayCommand(0.2, AssignCommand(oElite, ActionEquipItem(oWeapon2, INVENTORY_SLOT_LEFTWEAPON, TRUE)));
                            }
                        }
                    }
                }}
        }
    }
}

string ChooseWeapon(string sBase)
{
    int nRand;

    if (sBase == "w_blaste_" || sBase == "w_brifle_" || sBase == "w_melee_")
        nRand = Random(30) + 1;
    else if (sBase == "G_W_DBLSBR0" || sBase == "g_w_lghtsbr" || sBase == "g_w_shortsbr")
        nRand = Random(11) + 1;
    else if (sBase == "d_armor_" || sBase == "a_light_" || sBase == "a_medium_" || sBase == "a_heavy_")
        nRand = Random(15) + 1;

    if (nRand < 10)
        sBase = sBase + "0" + IntToString(nRand);
    else
        sBase = sBase + IntToString(nRand);

    // CreateItemOnObject(sBase, oElite, 2, TRUE);

    return sBase;
}

void ChooseClass()
{

}
