// d_elite_torch.nss

void main()
{
    object oTarget;
    int nDC, nDamage, nLevel;
    float fDuration;
    effect eBeam, eDam;

    oTarget = GetSpellTargetObject();
    nLevel = GetHitDice(GetFirstPC());

    nDC = GetFortitudeSavingThrow(oTarget) + 11;
    nDamage = d10(nLevel);

    eBeam = EffectBeam(2053, OBJECT_SELF, BODY_NODE_HAND); //Flame Thrower
    effect eVFX = EffectVisualEffect(1039);
    effect eBump = EffectVisualEffect(2062);

    effect eHorror = EffectFrightened();
    eHorror = SetEffectIcon(eHorror, 57);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFX, oTarget);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oTarget, 1.0);

    if (FortitudeSave(oTarget, nDC) == FALSE)
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHorror, oTarget, 6.0);

    DelayCommand(0.33, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBump, oTarget, 1.5));

    nDC = GetReflexSavingThrow(oTarget) + 11;

    if(ReflexSave(oTarget, nDC, SAVING_THROW_TYPE_FIRE))
    {
        // DJS-OEI 11/20/2003
        // If the target has the Evasion feat, the damage on a successful
        // Reflex save is 0. Otherwise, it's half the original damage.
        if( GetHasFeat( FEAT_EVASION, oTarget ) ) {
            nDamage = 0;
        }
        else {
            nDamage /= 2;
        }
    }
    eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
}
