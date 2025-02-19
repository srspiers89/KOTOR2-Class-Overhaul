// k_inc_elite.nss
//
// Elite Enemies Mod

void SpawnElite();

void SpawnElite()
{
    //object oEnemy = GetEnteringObject();
    object oEnemy = OBJECT_SELF;
    location lLoc = Location(GetPosition(oEnemy) + AngleToVector(GetFacing(oEnemy)) * 3.0, GetFacing(oEnemy) - 180.0);

    string sResRef;

    // Get appearance of enemy
    int nAppearance = GetAppearanceType(oEnemy);

    // Change name of elite
    //string sOldName = GetName(oEnemy);
    //string sNewName; // = "Elite " + sOldName;

    // SetCustomToken(4242, GetName(oEnemy));

    switch (nAppearance)
    {
        // mining droids mark I
        case 460:
        case 583:
        case 584:
        {sResRef = "elite_mine_droid";}
        break;

        // mining droids mark II
        case 461:
        case 581:
        case 582:
        {sResRef = "elite_mk2_droid";}
        break;

        // cannoks
        case 512:
        {sResRef = "elite_cannok";}
        break;

        // drexl
        case 516:
        case 517:
        case 518:
        {sResRef = "elite_drexl";}
        break;

        // laigrek
        case 553:
        {sResRef = "elite_laigrek";}
        break;

        // gand
        case 569:
        {sResRef = "elite_gand";}

        // zakkeg
        case 605:
        {sResRef = "elite_zakkeg";}
        break;

        // malachor beasts
        case 633:
        case 634:
        {sResRef = "elite_malachor";}

        // hssiss
        case 662:
        {sResRef = "elite_hssiss";}
        break;

        // mandalorians
        case 35:
        case 351:
        case 352:
        {sResRef = "elite_mandalorian";}
        break;

        // sith assassins
        case 459:
        case 528:
        case 534:
        {sResRef = "elite_sithass";}
        break;
    }

    if (GetTag(oEnemy) != sResRef && d100() > 50) //&& GetIsEnemy(oEnemy))
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(2008), CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc));
}
