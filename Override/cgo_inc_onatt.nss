// cgo_inc_onatt.nss
// include file for onattacked event
#include "cp_inc_debug"

void Enemy_OnAttacked();
void Hen_OnAttacked();
void DoTheEffect(object oTarget, effect eEffect);

void  Enemy_OnAttacked()
{
    object oAttacker = GetLastAttacker();
    object oCreator;
    object oSelf = OBJECT_SELF;

    effect eDamage;
    effect eCheck = GetFirstEffect(oAttacker);

    while (GetIsEffectValid(eCheck))
    {
        if (GetEffectSpellId(eCheck) == 283) // Floating Weapons
        {
            oCreator = GetEffectCreator(eCheck);
            CP_DebugMsg(GetName(oCreator));

            AssignCommand(oCreator, DoTheEffect(oSelf, EffectDamage(d3(GetHitDice(OBJECT_SELF)), DAMAGE_TYPE_BLASTER)));
        }

        eCheck = GetNextEffect(oAttacker);
    }
}

void Hen_OnAttacked()
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
            // eDamage = EffectDamage(d6(GetHitDice(oCreator)), DAMAGE_TYPE_LIGHT_SIDE);

            // AssignCommand(oCreator, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oAttacker));
            AssignCommand(oCreator, DoTheEffect(oAttacker, EffectDamage(d6(GetHitDice(oCreator)), DAMAGE_TYPE_LIGHT_SIDE)));
        }

        eCheck = GetNextEffect(oAttacker);
    }
}

void DoTheEffect(object oTarget, effect eEffect)
{
    effect eApply = eEffect;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eApply, oTarget);
}
