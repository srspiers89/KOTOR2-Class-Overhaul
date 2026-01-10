// k_inc_dmg.nss
//
// Include file for my feats and force powers that use the ondamage event

void OnDamage();

void OnDamage()
{
    /*int i;
    // Aura of Triumph heals party +5 whenever you deal damage
    //if GetHasFeat(GetLastDamager())
    for (i = 0; i < 3; i++)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(5), GetPartyMemberByIndex(i));
    }*/

    // Drain Life check
    // GetTotalDamageDealt returns 2x damage dealt for some reason so we divide by 4 to get half
    int nDamage = GetTotalDamageDealt() / 4;
    effect eHeal = EffectHeal(nDamage);
    effect eCheck = GetFirstEffect(OBJECT_SELF);

    while (GetIsEffectValid(eCheck))
    {
        if (GetEffectSpellId(eCheck) == FORCE_POWER_DRAIN_LIFE)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, GetEffectCreator(eCheck));
        }
        eCheck = GetNextEffect(OBJECT_SELF);
    }
}
