// Invisibility Test

#include "cp_inc_debug"

void main()
{
    object oTarget = GetSpellTargetObject();
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectInvisibility(INVISIBILITY_TYPE_NORMAL), OBJECT_SELF, 60.0);

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageShield(100, 5, 4096), OBJECT_SELF, 60.0);

    CutsceneAttack(oTarget, 115, ATTACK_RESULT_CRITICAL_HIT, 100);

    //ActionUseFeat(101, oTarget);

    // ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceJump(oTarget), OBJECT_SELF);

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(2002), OBJECT_SELF, 30.0);

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(2061, OBJECT_SELF, BODY_NODE_CHEST), OBJECT_SELF, 30.0);

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageImmunityDecrease(DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_BLASTER, 50), OBJECT_SELF, 30.0);

    //effect eDamage = EffectDamage(GetMaxHitPoints(oTarget) / 5, DAMAGE_TYPE_BLUDGEONING);
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
    //CP_ListEffects(oTarget);

    //effect eDrainLife = EffectAreaOfEffect(3, "", "drain_life_hb", "");
    //location lTarget = GetLocation(oTarget);
    //object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF);
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eDrainLife, oTarget);
    //ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eDrainLife, lTarget, 30.0);
}
