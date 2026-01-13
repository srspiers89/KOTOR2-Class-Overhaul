//:: k_sup_healing
/*
    Script for the 3 healing
    kits and the remove poison
    kit
*/
//:: Created By: Preston Watamaniuk
//:: Copyright (c) 2002 Bioware Corp.

#include "k_inc_debug"
#include "k_inc_force"

void main()
{
    int nItem = GetSpellId();
    int nSkill = GetSkillRank(SKILL_TREAT_INJURY);
    int nHeal;

    object oTarget = GetSpellTarget();

    effect eHeal;
    effect eTemp;
    int bHeal = TRUE;
    if(nItem == 64)
    {
        nHeal = GetMaxHitPoints(oTarget) * (30 + nSkill) / 100;
    }
    else if(nItem == 65)
    {
        nHeal = GetMaxHitPoints(oTarget) * (40 + nSkill) / 100;
    }
    else if(nItem == 66)
    {
        nHeal = GetMaxHitPoints(oTarget) * (50 + nSkill) / 100;
    }
    else if(nItem == 67)
    {
        Sp_RemoveSpecificEffect(EFFECT_TYPE_POISON, OBJECT_SELF);
        bHeal = FALSE;
    }
    else if(nItem == 84)
    {
        nSkill = GetSkillRank(SKILL_REPAIR);
        nHeal = GetMaxHitPoints(oTarget) * (30 + nSkill) / 100;
    }
    else if(nItem == 127)
    {
        nSkill = GetSkillRank(SKILL_REPAIR);
        nHeal = GetMaxHitPoints(oTarget) * (40 + nSkill) / 100;
    }
    else if(nItem == 128)
    {
        nSkill = GetSkillRank(SKILL_REPAIR);
        nHeal = GetMaxHitPoints(oTarget) * (50 + nSkill) / 100;
    }
    else if(nItem == 129)//Recovery Stim
    {
        bHeal = FALSE;
        nHeal = GetMaxHitPoints(oTarget) * (10 + nSkill) / 100;
        effect eVis =  EffectVisualEffect(VFX_IMP_CURE);
        int nCnt = 0;
        object oParty;

        oParty = GetPartyMemberByIndex(nCnt);
        while(nCnt < 3)
        {
            if(GetIsObjectValid(oParty))
            {
                if(GetIsDead(oParty))
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oParty);
                }
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oParty);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHeal), oParty);
            }
            nCnt++;
            oParty = GetPartyMemberByIndex(nCnt);
        }
    }
    if(bHeal == TRUE)
    {
        eHeal = EffectHeal(nHeal);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);

        if(GetTag(OBJECT_SELF) == "HK47")
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1048), OBJECT_SELF);
    }
}
