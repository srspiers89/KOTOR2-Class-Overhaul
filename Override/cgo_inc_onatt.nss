// cgo_inc_onatt.nss
// include file for onattacked event

void Enemy_OnAttacked();

void  Enemy_OnAttacked()
{
    object oAttacker = GetLastAttacker();
    object oCreator;

    effect eDamage;
    effect eCheck = GetFirstEffect(oAttacker);

    while (GetIsEffectValid(eCheck))
    {
        if (GetEffectSpellId(eCheck) == 284) // Force Empathy
        {
            oCreator = GetEffectCreator(eCheck);
            eDamage = EffectDamage(d6(GetHitDice(oCreator)), DAMAGE_TYPE_LIGHT_SIDE);

            AssignCommand(oCreator, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oAttacker));
        }
        eCheck = GetNextEffect(oAttacker);
    }
}
