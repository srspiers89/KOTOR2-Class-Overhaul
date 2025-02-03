
//:: Script Name
/*
    Desc
*/
//:: Created By:
//:: Copyright (c) 2002 Bioware Corp.
#include "k_inc_generic"

void main()
{
    if( !IsObjectPartyMember(OBJECT_SELF) )
        GN_DetermineCombatRound();
}
