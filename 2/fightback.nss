void main()
{
    if ( GetAttemptedAttackTarget() == OBJECT_INVALID )
    {
        if( !IsObjectPartyMember(OBJECT_SELF) )
            ActionAttack(GetLastAttacker());
    }
}
