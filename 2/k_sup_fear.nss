//:: k_sup_fear
/*
1   SW_PHYCHIC_STATIC         k_sup_static
2   SW_INSANE                 k_sup_insane
3   SW_FEAR                   k_sup_fear
*/
//:: Created By: Preston Watamaniuk
//:: Copyright (c) 2002 Bioware Corp.

#include "k_inc_debug"

void main()
{
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectTemporaryHitpoints(20), OBJECT_SELF, 3.0);
}
