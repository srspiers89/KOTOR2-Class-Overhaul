// k_inc_attacked.nss
//
// Include file for my feats and force powers that use the on_attacked event

void CGO_Attacked();

void CGO_Attacked()
{
    object oAttacker = GetLastAttacker();
    int nResult;

    if (GetLevelByClass(CLASS_TYPE_JEDIWEAPONMASTER, oAttacker) > 0)
    {
        nResult = GetLastAttackResult(oAttacker);

        if (nResult > 0 && nResult < 4)
            SetLocalBoolean(oAttacker, 123, TRUE);
    }
}
