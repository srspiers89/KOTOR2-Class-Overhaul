// drain_life_hb.nss

void main()
{
    object oCaster = GetAreaOfEffectCreator();

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 18.0, GetLocation(oCaster), FALSE, OBJECT_TYPE_CREATURE);

    effect eDamage = EffectDamage(50, DAMAGE_TYPE_DARK_SIDE);
    effect eHeal = EffectHeal(50);

    while (GetIsObjectValid(oTarget))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oCaster);

        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 18.0, GetLocation(oCaster), FALSE, OBJECT_TYPE_CREATURE);
    }
}
