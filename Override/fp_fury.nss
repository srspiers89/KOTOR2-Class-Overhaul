// Fury Force Power
//
// Adds 2 extra attacks, bonus damage the lower your hp is, bonus damage if companions are knocked out, min 1 hp if companions are still alive,
// deals damage to you every round

#include "k_inc_force"

void main()
{
    effect eLink1;
    effect eInvalid;
    SWFP_HARMFUL = FALSE;

    int nExtraAttacks = 0;
    int nDefenseModifier;
    int nSaveModifier;
    int nStrengthModifier;
    float fDuration;
    int nIcon;

    if (GetSpellId() == FORCE_POWER_FURY)
    {
        nDefenseModifier = 2;
        nSaveModifier = 1;
        nStrengthModifier = 2;
        fDuration = 30.0;
        nIcon = 82;
    }
    else if(GetSpellId() == FORCE_POWER_IMPROVED_FURY)
    {
        nExtraAttacks = 1;
        nDefenseModifier = 4;
        nSaveModifier = 2;
        nStrengthModifier = 4;
        fDuration = 45.0;
        nIcon = 83;
    }
    else if(GetSpellId() == FORCE_POWER_MASTER_FURY)
    {
        nExtraAttacks = 2;
        nDefenseModifier = 6;
        nSaveModifier = 3;
        nStrengthModifier = 6;
        fDuration = 60.0;
        nIcon = 84;

        if (!GetMinOneHP(OBJECT_SELF))
            SetMinOneHP(OBJECT_SELF, 1);
    }

    // Remove any lower level or equal versions of this power.
    Sp_RemoveRelatedPowers( OBJECT_SELF, GetSpellId() );

    // Do not apply the effects of this power if a more powerful
    // version is already attached to the target.
    if( !Sp_BetterRelatedPowerExists( OBJECT_SELF, GetSpellId() ) ) {

        eLink1 = EffectFury();
        eLink1 = EffectLinkEffects(eLink1, EffectSavingThrowIncrease( SAVING_THROW_FORT, nSaveModifier ) );
        eLink1 = EffectLinkEffects(eLink1, EffectSavingThrowIncrease( SAVING_THROW_WILL, nSaveModifier ) );
        eLink1 = EffectLinkEffects(eLink1, EffectACDecrease( nDefenseModifier ) );
        eLink1 = EffectLinkEffects(eLink1, EffectAbilityIncrease(ABILITY_STRENGTH, nStrengthModifier));

        if( nExtraAttacks > 0 ) {
            eLink1 = EffectLinkEffects(eLink1, EffectModifyAttacks( nExtraAttacks ) );
        }

        eLink1 = EffectLinkEffects(eLink1, EffectImmunity( IMMUNITY_TYPE_PARALYSIS ) );
        eLink1 = EffectLinkEffects(eLink1, EffectImmunity( IMMUNITY_TYPE_FEAR ) );
        eLink1 = EffectLinkEffects(eLink1, EffectImmunity( IMMUNITY_TYPE_STUN ) );
        eLink1 = EffectLinkEffects(eLink1, EffectImmunity( IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE ) );
        eLink1 = SetEffectIcon(eLink1, nIcon);

        Sp_ApplyEffects(FALSE, OBJECT_SELF, 0.0, 1, eLink1, fDuration, eInvalid, 0.0);
        // Sp_ApplyEffects(FALSE, OBJECT_SELF, 0.0, 1, eLink2, fDuration, eInvalid, 0.0);
    }
}
