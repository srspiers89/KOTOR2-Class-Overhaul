// implantswitch.nss
//
// Implant Switching Script for Scouts

void SwapImplant(string sImplant);

void main()
{
    string sImplant = GetTag(GetSpellCastItem());
    object oCurHide = GetItemInSlot( INVENTORY_SLOT_CARMOUR, OBJECT_SELF );

    //First see if a hide is already equipped. If so, unequip and destroy it.
    if ( GetIsObjectValid( oCurHide ) )
    {
        DelayCommand( 0.01, ActionUnequipItem( oCurHide ));
        DelayCommand( 0.015, DestroyObject( oCurHide, 0.0f, FALSE, 0.0f, TRUE ));
        DelayCommand( 0.02, SwapImplant( sImplant ));
    }
    else
    {
        DelayCommand( 0.02, SwapImplant( sImplant ));
    }
}

void SwapImplant(string sImplant)
{
    if (sImplant == "")
    {
        object oNewHide = CreateItemOnObject( "G_I_CRHIDE018", GetFirstPC(), 1, TRUE );

        DelayCommand(0.01, ActionEquipItem( oNewHide, INVENTORY_SLOT_CARMOUR ));
    }
}
