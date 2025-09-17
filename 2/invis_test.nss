// Invisibility Test

void main()
{
    object oTarget = GetSpellTargetObject();
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectInvisibility(INVISIBILITY_TYPE_NORMAL), OBJECT_SELF, 60.0);

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageShield(100, 5, 4096), OBJECT_SELF, 60.0);

    //CutsceneAttack(oTarget, 115, ATTACK_RESULT_CRITICAL_HIT, 10);

    //ActionUseFeat(101, oTarget);

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectRegenerate(10, 6.0), OBJECT_SELF, 60.0);
}
