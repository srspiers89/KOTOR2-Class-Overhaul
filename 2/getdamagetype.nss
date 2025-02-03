// getdamagetype.nss

void main()
{
    SetLocalNumber(OBJECT_SELF, 25, GetDamageDealtByType(GetRunScriptVar()));
    SetLocalNumber(OBJECT_SELF, 26, GetTotalDamageDealt());
}
