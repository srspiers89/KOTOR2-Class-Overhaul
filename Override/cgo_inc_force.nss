// cgo_inc_force.nss
// Modified & Custom Force Powers for Complete Gameplay Overhaul
// @target kotor2

#include "cp_inc_debug"

void CGO_RunForcePowers();

// int CGO_CalcDamage(); // Calculates damage for force powers

void CGO_RunForcePowers()
{
    object oTarget = GetSpellTargetObject();
    effect eLink1, eLink2;
    effect eInvalid;

    switch (GetSpellId())
    {
        case 282: // Mass Force Whirlwind -> AOE Whirlwind
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_REFLEX;

            float fRange = Sp_CalcRange( 15.0 );
            object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRange, GetLocation(GetSpellTargetObject()));

            // DJS-OEI 3/25/2004
            SWFP_DAMAGE = Sp_CalcDamage( oTarget, 0, 0, GetHitDice(OBJECT_SELF)/3 );
            SWFP_DAMAGE_TYPE = DAMAGE_TYPE_BLUDGEONING;
            effect eDamage = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);

            while(GetIsObjectValid(oTarget))
            {
                if(SP_CheckForcePushViability(oTarget, TRUE) && GetIsEnemy(oTarget))
                {
                    effect eLink1 = EffectWhirlWind();
                    eLink1 = EffectLinkEffects(eLink1, EffectVisualEffect(VFX_IMP_FORCE_WHIRLWIND));
                    eLink1 = EffectLinkEffects(eLink1, EffectVisualEffect(VFX_DUR_FORCE_WHIRLWIND));
                    eLink1 = SetEffectIcon(eLink1, 14);

                    int nResist = Sp_BlockingChecks(oTarget, eLink1, eDamage, eInvalid);
                    int nSaves;
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));
                    if(nResist == 0)
                    {
                        nSaves =Sp_MySavingThrows(oTarget);
                        if(nSaves == 0)
                        {
                            //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, 9.0);
                            //RWT-OEI 09/27/04 - QA says they fall too soon. Upping this to 12 to
                            //see if that fixes it. FMP#6266
                            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, 12.0);
                            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDamage, oTarget);
                            int nIdx = 1;
                            float fDelay;
                            SP_InterativeDamage(eDamage, 13, oTarget);
                        }
                    }
                    if(nResist > 0 || nSaves > 0)
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                    }
                }

                oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oTarget));
            }

        }
        break;

        case 284: // Force Empathy 284 -> enemies take damage when they attack
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;
            SWFP_PRIVATE_SAVE_VERSUS_TYPE = SAVING_THROW_TYPE_FORCE_POWER;

            eLink1 = EffectSpellImmunity(202); // XXX_FORCE_POWER_MEDITATION
            eLink2 = EffectVisualEffect(VFX_PRO_AFFLICT);
            eLink1 = SetEffectIcon(eLink1, 116);

            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

            //Make Immunity Checks
            int nResist = Sp_BlockingChecks(oTarget, eLink1, eLink2, eInvalid);
            if(nResist == 0)
            {
                int nSaves = Sp_MySavingThrows(oTarget);
                if(nSaves == 0)
                {
                    // Remove any lower level or equal versions of this power.
                    // Sp_RemoveRelatedPowers( oTarget, FORCE_POWER_SLOW );

                    // Do not apply the effects of this power if a more powerful
                    // version is already attached to the target.
                    // if( !Sp_BetterRelatedPowerExists( oTarget, FORCE_POWER_SLOW ) ) {
                    //if (!GetHasSpellEffect(284, oTarget))
                    float fDuration = Sp_CalcDuration( 30.0 );
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, fDuration);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink2, oTarget, 1.0);
                    // }
                }
            }
        }
        break;

        case 285: // Force Taunt -> force enemies to attack you
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;

            float fShapeSize = Sp_CalcRange(12.0);
            int nSaves;

            object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fShapeSize, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE );

            while (GetIsObjectValid(oTarget))
            {
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

                if (GetRacialType(oTarget) != RACIAL_TYPE_DROID && GetIsEnemy(oTarget))
                {
                    nSaves = Sp_MySavingThrows(oTarget);
                    if (nSaves <= 0)
                    {
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSpellImmunity(203), OBJECT_SELF, 30.0);
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSpellImmunity(203), oTarget, 30.0);
                    }
                }

                oTarget = GetNextObjectInShape(SHAPE_SPHERE, fShapeSize, GetLocation(oTarget), TRUE, OBJECT_TYPE_CREATURE );
            }
        }
        break;

        case 901: // Force Ambush -> teleport behind target and attack
        {
            location lLoc = Location(GetPosition(oTarget) - AngleToVector(GetFacing(oTarget)) * 2.0, GetFacing(oTarget));

            //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectInvisibility(INVISIBILITY_TYPE_NORMAL), OBJECT_SELF, 3.0);
            //DelayCommand(1.5, ClearAllActions());
            //DelayCommand(1.6, JumpToLocation(lLoc));
            ClearAllActions();
            DelayCommand(0.15, ActionAttack(oTarget));
            DelayCommand(0.25, JumpToLocation(lLoc));
            //DelayCommand(1.0, ActionAttack(oTarget));

            // object oAttacker = GetFirstAttacker(OBJECT_SELF);

            //while(GetIsObjectValid(oAttacker))
            //{
            //if (oAttacker == oTarget)
            if (GetAttackTarget(oTarget) == OBJECT_SELF)
            {
                AssignCommand(oTarget, ClearAllActions());
                AssignCommand(oTarget, FaceObjectAwayFromObject(oTarget, OBJECT_SELF));
                DelayCommand(0.1, AssignCommand(oTarget,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE,1.0,5.0)));
                DelayCommand(0.2,SetCommandable(FALSE,oTarget));
                DelayCommand(4.8,SetCommandable(TRUE,oTarget));
                //break;
            }
            //oAttacker = GetNextAttacker(OBJECT_SELF);
            //}
        }
        break;

        case 283: // Force Regroup -> teleport behind furthest party member and heal
        {
            effect eHeal = EffectRegenerate(GetMaxHitPoints() / 3 / 9, 1.0);
            location lLoc;
            float fDistance = 0.0;
            object oCreature;
            int i;

            for (i = 2; i > 0; i--)
            {
                oCreature = GetPartyMemberByIndex(i);

                if (GetIsObjectValid(oCreature) && oCreature != OBJECT_SELF)
                {
                    if (GetDistanceToObject(oCreature) > fDistance)
                    {
                        fDistance = GetDistanceToObject(oCreature);
                        lLoc = Location(GetPosition(oCreature) - AngleToVector(GetFacing(oCreature)) * 2.0, GetFacing(oCreature));
                    }
                }
            }

            if (fDistance > 0.0)
            {
                ClearAllActions();
                DelayCommand(0.15, JumpToLocation(lLoc));
                DelayCommand(0.16, SetCameraFacing(GetFacingFromLocation(lLoc)));

                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHeal, OBJECT_SELF, 9.0);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectInvisibility(INVISIBILITY_TYPE_NORMAL), OBJECT_SELF, 1.0);
            }
            else
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
        }
        break;

        case FORCE_POWER_FORCE_ENLIGHTENMENT: // Force Buff -> cast all buff powers
        {
            SWFP_HARMFUL = FALSE;
            float fDuration = Sp_CalcDuration(120.0);

            // Remove other versions of power
            Sp_RemoveRelatedPowers( OBJECT_SELF, FORCE_POWER_FORCE_ENLIGHTENMENT );

            // Armor
            if (GetSpellAcquired(FORCE_POWER_FORCE_ARMOR))
            {
                eLink1 = EffectACIncrease(10, AC_ARMOUR_ENCHANTMENT_BONUS);
                eLink1 = SetEffectIcon(eLink1, 7);
                eLink2 = EffectVisualEffect(VFX_PRO_FORCE_ARMOR);
                eLink2 = EffectLinkEffects(eLink2, EffectVisualEffect(VFX_PRO_FORCE_SHIELD));

                Sp_ApplyEffects(FALSE, OBJECT_SELF, 0.0, 1, eLink1, fDuration, eLink2, 3.0);
            }
            else if (GetSpellAcquired(FORCE_POWER_FORCE_SHIELD))
            {
                eLink1 = EffectACIncrease(6, AC_ARMOUR_ENCHANTMENT_BONUS);
                eLink1 = SetEffectIcon(eLink1, 12);
                eLink2 = EffectVisualEffect(VFX_PRO_FORCE_SHIELD);

                Sp_ApplyEffects(FALSE, OBJECT_SELF, 0.0, 1, eLink1, fDuration, eLink2, 3.0);
            }
            else if (GetSpellAcquired(FORCE_POWER_FORCE_AURA))
            {
                eLink1 = EffectACIncrease(4, AC_ARMOUR_ENCHANTMENT_BONUS);
                eLink1 = SetEffectIcon(eLink1, 8);
                eLink2 = EffectVisualEffect(VFX_PRO_FORCE_AURA);

                Sp_ApplyEffects(FALSE, OBJECT_SELF, 0.0, 1, eLink1, fDuration, eLink2, 3.0);
            }

            // Valor
            if (GetSpellAcquired(FORCE_POWER_MIND_MASTERY))
            {
                eLink1 = EffectAbilityIncrease(ABILITY_CONSTITUTION, 5);
                eLink1 = EffectLinkEffects(eLink1, EffectAbilityIncrease(ABILITY_DEXTERITY, 5));
                eLink1 = EffectLinkEffects(eLink1, EffectAbilityIncrease(ABILITY_STRENGTH, 5));
                eLink1 = SetEffectIcon(eLink1, 21);
                eLink2 = EffectVisualEffect(VFX_IMP_MIND_MASTERY);

                Sp_ApplyForcePowerEffects(fDuration, eLink1, OBJECT_SELF);
                Sp_ApplyForcePowerEffects(0.0, eLink2, OBJECT_SELF);
            }
            else if (GetSpellAcquired(FORCE_POWER_KNIGHT_MIND))
            {
                eLink1 = EffectAbilityIncrease(ABILITY_CONSTITUTION, 3);
                eLink1 = EffectLinkEffects(eLink1, EffectAbilityIncrease(ABILITY_DEXTERITY, 3));
                eLink1 = EffectLinkEffects(eLink1, EffectAbilityIncrease(ABILITY_STRENGTH, 3));
                eLink1 = SetEffectIcon(eLink1, 19);
                eLink2 = EffectVisualEffect(1033);

                Sp_ApplyForcePowerEffects(fDuration, eLink1, OBJECT_SELF);
                Sp_ApplyForcePowerEffects(0.0, eLink2, OBJECT_SELF);
            }
            else if (GetSpellAcquired(FORCE_POWER_FORCE_MIND))
            {
                eLink1 = EffectAbilityIncrease(ABILITY_CONSTITUTION, 2);
                eLink1 = EffectLinkEffects(eLink1, EffectAbilityIncrease(ABILITY_DEXTERITY, 2));
                eLink1 = EffectLinkEffects(eLink1, EffectAbilityIncrease(ABILITY_STRENGTH, 2));
                eLink1 = SetEffectIcon(eLink1, 10);
                eLink2 = EffectVisualEffect(VFX_IMP_MIND_FORCE);

                Sp_ApplyForcePowerEffects(fDuration, eLink1, OBJECT_SELF);
                Sp_ApplyForcePowerEffects(0.0, eLink2, OBJECT_SELF);
            }

        }
        break;

        case FORCE_POWER_CURE:
        {
            SWFP_HARMFUL = FALSE;

            // int nMultiplier = 1;
            int nHeal; // = ((GetAbilityModifier(ABILITY_WISDOM) + GetAbilityModifier(ABILITY_CHARISMA)) * nMultiplier);


            effect eVis =  EffectVisualEffect(VFX_IMP_CURE);
            int nCnt = 0;

            object oParty;
            if(IsObjectPartyMember(OBJECT_SELF))
                oParty = GetPartyMemberByIndex(nCnt);
            else
                oParty = OBJECT_SELF;

            while(nCnt < 3)
            {
                if(GetIsObjectValid(oParty) &&
                    GetRacialType(oParty) != RACIAL_TYPE_DROID &&
                    GetDistanceBetween(OBJECT_SELF, oParty) < 15.0)
                {
                    Sp_RemoveRelatedPowers(oParty, FORCE_POWER_CURE);

                    if (!Sp_BetterRelatedPowerExists( oParty, FORCE_POWER_CURE))
                    {
                        nHeal = Sp_CalcDamage(oParty, 0, 0, (GetMaxHitPoints(oParty) * 60 / 100)) / 10;
                        eLink1 = EffectRegenerate(nHeal, 3.0);
                        eLink1 = EffectLinkEffects(eLink1, EffectSpellImmunity(5));
                        eLink1 = SetEffectIcon(eLink1, 117);

                        SignalEvent(oParty, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oParty);
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oParty, 30.0);
                    }
                }
                nCnt++;

                if(IsObjectPartyMember(OBJECT_SELF))
                    oParty = GetPartyMemberByIndex(nCnt);
                else
                    oParty = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, nCnt);
            }
        }
        break;

        case FORCE_POWER_HEAL:
        {
            SWFP_HARMFUL = FALSE;

            // int nMultiplier = 2;
            int nHeal; // = ((GetAbilityModifier(ABILITY_WISDOM) + GetAbilityModifier(ABILITY_CHARISMA)) * nMultiplier);

            effect eVis =  EffectVisualEffect(VFX_IMP_HEAL);
            int nCnt = 0;

            object oParty;
            if(IsObjectPartyMember(OBJECT_SELF))
                oParty = GetPartyMemberByIndex(nCnt);
            else
                oParty = OBJECT_SELF;

            while(nCnt < 3)
            {
                if(GetIsObjectValid(oParty) &&
                    GetRacialType(oParty) != RACIAL_TYPE_DROID &&
                    GetDistanceBetween(OBJECT_SELF, oParty) < 15.0)
                {
                    Sp_RemoveRelatedPowers(oParty, FORCE_POWER_HEAL);

                    if (!Sp_BetterRelatedPowerExists( oParty, FORCE_POWER_HEAL))
                    {
                        nHeal = Sp_CalcDamage(oParty, 0, 0, (GetMaxHitPoints(oParty) * 80 / 100)) / 10;
                        eLink1 = EffectRegenerate(nHeal, 3.0);
                        eLink1 = EffectLinkEffects(eLink1, EffectSpellImmunity(5));
                        eLink1 = SetEffectIcon(eLink1, 118);

                        SignalEvent(oParty, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oParty);
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oParty, 30.0);
                    }
                }
                nCnt++;

                if(IsObjectPartyMember(OBJECT_SELF))
                    oParty = GetPartyMemberByIndex(nCnt);
                else
                    oParty = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, nCnt);
            }
        }
        break;

        case FORCE_POWER_MASTER_HEAL:
        {
            SWFP_HARMFUL = FALSE;

            // int nMultiplier = 3;
            int nHeal; // = ((GetAbilityModifier(ABILITY_WISDOM) + GetAbilityModifier(ABILITY_CHARISMA)) * nMultiplier);

            effect eVis =  EffectVisualEffect(VFX_IMP_HEAL);
            int nCnt = 0;

            object oParty;
            if(IsObjectPartyMember(OBJECT_SELF))
                oParty = GetPartyMemberByIndex(nCnt);
            else
                oParty = OBJECT_SELF;

            while(nCnt < 3)
            {
                if(GetIsObjectValid(oParty) &&
                    GetRacialType(oParty) != RACIAL_TYPE_DROID &&
                    GetDistanceBetween(OBJECT_SELF, oParty) < 15.0)
                {
                    Sp_RemoveRelatedPowers(oParty, FORCE_POWER_MASTER_HEAL);
                    //RemoveEffectByID(oParty, FORCE_POWER_MASTER_HEAL);

                    if (!Sp_BetterRelatedPowerExists( oParty, FORCE_POWER_MASTER_HEAL))
                    {
                        nHeal = Sp_CalcDamage(oParty, 0, 0, GetMaxHitPoints(oParty)) / 10;
                        eLink1 = EffectRegenerate(nHeal, 3.0);
                        eLink1 = EffectLinkEffects(eLink1, EffectSpellImmunity(5));
                        eLink1 = SetEffectIcon(eLink1, 119);

                        SignalEvent(oParty, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oParty);
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oParty, 30.0);
                    }
                }
                nCnt++;

                if(IsObjectPartyMember(OBJECT_SELF))
                    oParty = GetPartyMemberByIndex(nCnt);
                else
                    oParty = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, nCnt);
            }
        }
        break;

        case FORCE_POWER_FORCE_SCREAM:
        case FORCE_POWER_IMPROVED_FORCE_SCREAM:
        case FORCE_POWER_MASTER_FORCE_SCREAM:
        {
            // Force Scream and Improved Force Scream both affect
            // targets in a cone extending from the caster's location.
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;
            SWFP_PRIVATE_SAVE_VERSUS_TYPE = SAVING_THROW_TYPE_SONIC;

            int nDamageRolls = GetHitDice(OBJECT_SELF);
            int nAttributeDamage;
            int nIconID;
            int nShape;
            float fShapeSize;
            int nVFXID;
            location lTargetLoc;
            if( GetSpellId() == FORCE_POWER_FORCE_SCREAM ) {
                nAttributeDamage = 2;
                nIconID = 79;
                nShape = SHAPE_SPELLCONE;
                fShapeSize = Sp_CalcRange( 20.0 );
                nVFXID = 9005;
                lTargetLoc = GetLocation( GetSpellTarget() );
            }
            else if( GetSpellId() == FORCE_POWER_IMPROVED_FORCE_SCREAM ) {
                nAttributeDamage = 4;
                nIconID = 80;
                nShape = SHAPE_SPELLCONE;
                fShapeSize = Sp_CalcRange( 20.0 );
                nVFXID = 9006;
                lTargetLoc = GetLocation( GetSpellTarget() );
            }
            else if( GetSpellId() == FORCE_POWER_MASTER_FORCE_SCREAM ) {
                nAttributeDamage = 6;
                nIconID = 81;
                nShape = SHAPE_SPHERE;
                fShapeSize = Sp_CalcRange( 12.0 );
                nVFXID = 9007;
                lTargetLoc = GetLocation( OBJECT_SELF );
            }

            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( nVFXID ), OBJECT_SELF);

            object oTarget = GetFirstObjectInShape(nShape, fShapeSize, lTargetLoc, TRUE, OBJECT_TYPE_CREATURE );
            while(GetIsObjectValid(oTarget))
            {
                int nTotalDamage = Sp_CalcDamage( oTarget, nDamageRolls, 4 );

                // Create the damage effects.
                eLink1 = EffectDamage( nTotalDamage, DAMAGE_TYPE_SONIC );
                eLink2 = EffectAbilityDecrease(ABILITY_STRENGTH, nAttributeDamage);
                eLink2 = EffectLinkEffects(eLink2, EffectAbilityDecrease(ABILITY_DEXTERITY, nAttributeDamage));
                eLink2 = EffectLinkEffects(eLink2, EffectAbilityDecrease(ABILITY_INTELLIGENCE, nAttributeDamage));
                eLink2 = EffectLinkEffects(eLink2, EffectAbilityDecrease(ABILITY_WISDOM, nAttributeDamage));
                eLink2 = EffectLinkEffects(eLink2, EffectAbilityDecrease(ABILITY_CHARISMA, nAttributeDamage));
                eLink2 = EffectLinkEffects(eLink2, EffectAbilityDecrease(ABILITY_CONSTITUTION, nAttributeDamage));
                eLink2 = EffectLinkEffects(eLink2, EffectVisualEffect(VFX_IMP_STUN)); // Added stun visual effect
                eLink2 = SetEffectIcon(eLink2, nIconID);

                // Check resistances.
                int nResist = Sp_BlockingChecks(oTarget, eLink1, eLink2, eInvalid);
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));
                if( ( GetRacialType(oTarget) != RACIAL_TYPE_DROID ) &&
                    GetIsEnemy(oTarget) )
                {
                    if(nResist == 0)
                    {
                        int nSaves = Sp_MySavingThrows(oTarget);
                        if(nSaves <= 0)
                        {
                            // Apply physical damage effect to the target.
                            ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink1, oTarget);

                            // Remove any lower level or equal versions of this power.
                            Sp_RemoveRelatedPowers( oTarget, GetSpellId() );

                            // Do not apply the effects of this power if a more powerful
                            // version is already attached to the target.
                            if( !Sp_BetterRelatedPowerExists( oTarget, GetSpellId() ) ) {

                                // Apply the attribute damage effect.
                                float fDuration = Sp_CalcDuration( 30.0 );
                                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink2, oTarget, fDuration);
                            }
                        }
                        else {
                            int nApply;
                            // DJS-OEI 11/20/2003
                            // If the target has the Evasion feat, the damage on a successful
                            // save is 0. Otherwise, it's half the original damage.
                            if( GetHasFeat( FEAT_EVASION, oTarget ) ) {
                                nApply = 0;
                            }
                            else {
                                nApply = nTotalDamage/2;
                            }

                            if( nApply > 0 ) {
                                // The target saved, so the attribute damage is ignored.
                                // Rebuild the damage effect with the new damage.
                                eLink1 = EffectDamage( nApply, DAMAGE_TYPE_SONIC );
                                ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink1, oTarget);
                            }
                        }
                    }
                    else
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                    }
                }
                oTarget = GetNextObjectInShape(nShape, fShapeSize, lTargetLoc, TRUE, OBJECT_TYPE_CREATURE );
            }
        }
        break;

        case FORCE_POWER_SHOCK:
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;
            SWFP_PRIVATE_SAVE_VERSUS_TYPE = SAVING_THROW_TYPE_ELECTRICAL;
            int nDice = GetHitDice(OBJECT_SELF);

            SWFP_DAMAGE = Sp_CalcDamage( oTarget, nDice, 6 );
            SP_MyPostString(IntToString(SWFP_DAMAGE),5,5,4.0);
            SWFP_DAMAGE_TYPE = DAMAGE_TYPE_ELECTRICAL;
            SWFP_DAMAGE_VFX = VFX_PRO_LIGHTNING_S;
            effect eDam;

            int nSaves = Sp_MySavingThrows(oTarget);
            int nResist = Sp_BlockingChecks(oTarget, eDam, eInvalid, eInvalid);
            eLink1 = EffectBeam(2066, OBJECT_SELF, BODY_NODE_HAND); //P.W.(May 19, 2003) Changed to Shock beam effect.

            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));
            if(nResist == 0)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_PRO_LIGHTNING_S), oTarget);

                // 20% more damage for each dark side power affecting target
                if (GetHasSpellEffect(FORCE_POWER_WOUND, oTarget) ||
                    GetHasSpellEffect(FORCE_POWER_CHOKE, oTarget) ||
                    GetHasSpellEffect(FORCE_POWER_KILL, oTarget))
                    SWFP_DAMAGE *= 12 / 10;
                if (GetHasSpellEffect(FORCE_POWER_FORCE_SCREAM, oTarget) ||
                    GetHasSpellEffect(FORCE_POWER_IMPROVED_FORCE_SCREAM, oTarget) ||
                    GetHasSpellEffect(FORCE_POWER_MASTER_FORCE_SCREAM, oTarget))
                    SWFP_DAMAGE *= 12 / 10;
                if (GetHasSpellEffect(FORCE_POWER_SLOW, oTarget) ||
                    GetHasSpellEffect(FORCE_POWER_AFFLICTION, oTarget) ||
                    GetHasSpellEffect(FORCE_POWER_PLAGUE, oTarget))
                    SWFP_DAMAGE *= 12 / 10;
                if (GetHasSpellEffect(FORCE_POWER_DRAIN_LIFE, oTarget) ||
                    GetHasSpellEffect(FORCE_POWER_DEATH_FIELD, oTarget))
                    SWFP_DAMAGE *= 12 / 10;

                if(nSaves == 0)
                {
                    eDam = EffectDamage(SWFP_DAMAGE, DAMAGE_TYPE_ELECTRICAL);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
                }
                else
                {
                    SWFP_DAMAGE /= 2;
                    eDam = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
                }

                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, fLightningDuration);
            }
        }
        break;

        case FORCE_POWER_LIGHTNING:
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;
            SWFP_PRIVATE_SAVE_VERSUS_TYPE = SAVING_THROW_TYPE_ELECTRICAL;
            int nDice = GetHitDice(OBJECT_SELF);

            float fRange = Sp_CalcRange( 17.0 );

            SWFP_DAMAGE = Sp_CalcDamage( oTarget, nDice, 6 );
            SWFP_DAMAGE_TYPE = DAMAGE_TYPE_ELECTRICAL;
            SWFP_DAMAGE_VFX = VFX_PRO_LIGHTNING_L; //1036 - With sound
            SWFP_SHAPE = SHAPE_SPELLCYLINDER;

            effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING_DARK_L, OBJECT_SELF, BODY_NODE_HAND);

            effect eDam;
            object oUse = GetFirstObjectInShape(SWFP_SHAPE, fRange, GetLocation(oTarget), FALSE, OBJECT_TYPE_CREATURE );
            effect eBump = EffectVisualEffect(SWFP_DAMAGE_VFX);

            while(GetIsObjectValid(oUse))
            {
                if(GetIsEnemy(oUse))
                {
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

                    int nResist = Sp_BlockingChecks(oUse, eBump, eInvalid, eInvalid);
                    int nSaves;
                    if(nResist == 0)
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eBump, oUse);

                        // 20% more damage for each dark side power affecting target
                        if (GetHasSpellEffect(FORCE_POWER_WOUND, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_CHOKE, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_KILL, oTarget))
                            SWFP_DAMAGE *= 12 / 10;
                        if (GetHasSpellEffect(FORCE_POWER_FORCE_SCREAM, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_IMPROVED_FORCE_SCREAM, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_MASTER_FORCE_SCREAM, oTarget))
                            SWFP_DAMAGE *= 12 / 10;
                        if (GetHasSpellEffect(FORCE_POWER_SLOW, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_AFFLICTION, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_PLAGUE, oTarget))
                            SWFP_DAMAGE *= 12 / 10;
                        if (GetHasSpellEffect(FORCE_POWER_DRAIN_LIFE, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_DEATH_FIELD, oTarget))
                            SWFP_DAMAGE *= 12 / 10;

                        nSaves = Sp_MySavingThrows(oUse);
                        if(nSaves == 0)
                        {
                            eDam = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);
                            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oUse);
                        }
                        else
                        {
                            SWFP_DAMAGE /= 2;
                            eDam = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);
                            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oUse);
                        }
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, oUse, fLightningDuration);
                    }
                    else
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceResisted(OBJECT_SELF), oTarget);
                    }
                }
                oUse = GetNextObjectInShape(SWFP_SHAPE, fRange, GetLocation(oTarget), FALSE, OBJECT_TYPE_CREATURE );
            }
        }
        break;

        case FORCE_POWER_FORCE_STORM:
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_WILL;

            float fRange = Sp_CalcRange( 12.0 );

            int nDice = GetHitDice(OBJECT_SELF);

            SWFP_DAMAGE = Sp_CalcDamage( oTarget, nDice, 6 );
            SWFP_DAMAGE_TYPE = DAMAGE_TYPE_ELECTRICAL;
            effect eBeam = EffectBeam(2061, OBJECT_SELF, BODY_NODE_HEAD);
            effect eVis = EffectVisualEffect(VFX_PRO_LIGHTNING_L);
            effect eForce;
            effect eDam;

            object oUse = GetFirstObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oTarget), FALSE, OBJECT_TYPE_CREATURE );
            while(GetIsObjectValid(oUse))
            {
                //Make Immunity Checks
                if(GetIsEnemy(oUse))
                {
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

                    int nResist = Sp_BlockingChecks(oUse, eVis, eBeam, eInvalid);
                    int nSaves;
                    if(nResist == 0)
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oUse);

                        // 20% more damage for each dark side power affecting target
                        if (GetHasSpellEffect(FORCE_POWER_WOUND, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_CHOKE, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_KILL, oTarget))
                            SWFP_DAMAGE *= 12 / 10;
                        if (GetHasSpellEffect(FORCE_POWER_FORCE_SCREAM, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_IMPROVED_FORCE_SCREAM, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_MASTER_FORCE_SCREAM, oTarget))
                            SWFP_DAMAGE *= 12 / 10;
                        if (GetHasSpellEffect(FORCE_POWER_SLOW, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_AFFLICTION, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_PLAGUE, oTarget))
                            SWFP_DAMAGE *= 12 / 10;
                        if (GetHasSpellEffect(FORCE_POWER_DRAIN_LIFE, oTarget) ||
                            GetHasSpellEffect(FORCE_POWER_DEATH_FIELD, oTarget))
                            SWFP_DAMAGE *= 12 / 10;

                        nSaves = Sp_MySavingThrows(oUse);
                        if(nSaves == 0)
                        {
                            eDam = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);
                            eForce = EffectDamageForcePoints(SWFP_DAMAGE);
                            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oUse);
                            ApplyEffectToObject(DURATION_TYPE_INSTANT, eForce, oUse);
                        }
                        else
                        {
                            eDam = EffectDamage(SWFP_DAMAGE/2, SWFP_DAMAGE_TYPE);
                            eForce = EffectDamageForcePoints(SWFP_DAMAGE/2);
                            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oUse);
                            ApplyEffectToObject(DURATION_TYPE_INSTANT, eForce, oUse);
                        }
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oUse, fLightningDuration);
                    }
                    else
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                }
                oUse = GetNextObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oTarget), FALSE, OBJECT_TYPE_CREATURE );
            }
        }
        break;

        case FORCE_POWER_WOUND:
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_FORT;

            SWFP_DAMAGE = 100; //GetMaxHitPoints(oTarget) / 5;
            SWFP_DAMAGE_TYPE = DAMAGE_TYPE_BLUDGEONING;

            effect eChoke = EffectChoke();
            eChoke = SetEffectIcon(eChoke, 31);
            effect eDamage = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);

            // Debuff increases all damage taken by 15 percent
            eLink1 = EffectDamageImmunityDecrease(DAMAGE_TYPE_BLUDGEONING, 15);
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_PIERCING, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_SLASHING, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_UNIVERSAL, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ACID, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_COLD, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_LIGHT_SIDE, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ELECTRICAL, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_FIRE, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_DARK_SIDE, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_SONIC, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ION, 15));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_BLASTER, 15));

            int nResist = Sp_BlockingChecks(oTarget, eChoke, eDamage, eInvalid);
            int nSaves;
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

            // Can only be wounded, choked, killed once
            if (GetHasSpellEffect(FORCE_POWER_WOUND, oTarget) || GetHasSpellEffect(FORCE_POWER_CHOKE, oTarget) || GetHasSpellEffect(FORCE_POWER_KILL, oTarget))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                CP_ListEffects(oTarget);
                break;
            }

            if(nResist == 0)
            {
                nSaves = Sp_MySavingThrows(oTarget);
                if(nSaves == 0)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_CHOKE), oTarget);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eChoke, oTarget, 1.0);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink1, oTarget);
                }
            }
            if(nResist > 0 || nSaves > 0)
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);

            CP_ListEffects(oTarget);
        }
        break;

        case FORCE_POWER_CHOKE:
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_FORT;

            SWFP_DAMAGE = GetMaxHitPoints(oTarget) / 5;
            SWFP_DAMAGE_TYPE = DAMAGE_TYPE_BLUDGEONING;

            effect eChoke = EffectChoke();
            eChoke = SetEffectIcon(eChoke, 3);
            effect eDamage = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);

            // Debuff increases all damage taken by 20 percent
            eLink1 = EffectDamageImmunityDecrease(DAMAGE_TYPE_BLUDGEONING, 20);
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_PIERCING, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_SLASHING, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_UNIVERSAL, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ACID, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_COLD, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_LIGHT_SIDE, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ELECTRICAL, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_FIRE, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_DARK_SIDE, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_SONIC, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ION, 20));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_BLASTER, 20));

            int nResist = Sp_BlockingChecks(oTarget, eChoke, eDamage, eInvalid);
            int nSaves;
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

            if (GetHasSpellEffect(FORCE_POWER_WOUND, oTarget) || GetHasSpellEffect(FORCE_POWER_CHOKE, oTarget) || GetHasSpellEffect(FORCE_POWER_KILL, oTarget))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                CP_ListEffects(oTarget);
                break;
            }

            if(nResist == 0)
            {
                nSaves = Sp_MySavingThrows(oTarget);
                if(nSaves == 0)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_CHOKE), oTarget);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eChoke, oTarget, 1.0);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink1, oTarget);
                }
            }
            if(nResist > 0 || nSaves > 0)
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);

            CP_ListEffects(oTarget);
        }
        break;

        case FORCE_POWER_KILL:
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_FORT;

            SWFP_DAMAGE = GetMaxHitPoints(oTarget) / 4;
            SWFP_DAMAGE_TYPE = DAMAGE_TYPE_BLUDGEONING;

            effect eChoke = EffectChoke();
            eChoke = SetEffectIcon(eChoke, 18);
            effect eDamage = EffectDamage(SWFP_DAMAGE, SWFP_DAMAGE_TYPE);

            // Debuff increases all damage taken by 25 percent
            eLink1 = EffectDamageImmunityDecrease(DAMAGE_TYPE_BLUDGEONING, 25);
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_PIERCING, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_SLASHING, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_UNIVERSAL, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ACID, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_COLD, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_LIGHT_SIDE, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ELECTRICAL, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_FIRE, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_DARK_SIDE, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_SONIC, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_ION, 25));
            eLink1 = EffectLinkEffects(eLink1, EffectDamageImmunityDecrease(DAMAGE_TYPE_BLASTER, 25));

            int nResist = Sp_BlockingChecks(oTarget, eChoke, eDamage, eInvalid);
            int nSaves;
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

            if (GetHasSpellEffect(FORCE_POWER_WOUND, oTarget) || GetHasSpellEffect(FORCE_POWER_CHOKE, oTarget) || GetHasSpellEffect(FORCE_POWER_KILL, oTarget))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                CP_ListEffects(oTarget);
                break;
            }

            if(nResist == 0)
            {
                nSaves = Sp_MySavingThrows(oTarget);
                if(nSaves == 0)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_CHOKE), oTarget);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eChoke, oTarget, 1.0);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink1, oTarget);
                }
            }
            if(nResist > 0 || nSaves > 0)
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);

            CP_ListEffects(oTarget);
        }
        break;

        case FORCE_POWER_DRAIN_LIFE:
        {
            SWFP_HARMFUL = TRUE;
            SWFP_PRIVATE_SAVE_TYPE = SAVING_THROW_FORT;
            int nDam = GetHitDice(OBJECT_SELF) / 6;
            if (nDam < 1)
                nDam = 1;

            SWFP_DAMAGE = d4(nDam);
            SWFP_DAMAGE_TYPE= DAMAGE_TYPE_DARK_SIDE;
            SWFP_DAMAGE_VFX = VFX_PRO_DRAIN;
            //Set up the drain effect link for the target
            effect eBeam = EffectBeam(VFX_BEAM_DRAIN_LIFE, OBJECT_SELF, BODY_NODE_HAND);
            effect eVFX = EffectVisualEffect(SWFP_DAMAGE_VFX);
            //Set up the link to Heal the user by the same amount.
            effect eHeal = EffectAbilityIncrease(ABILITY_CONSTITUTION, SWFP_DAMAGE);
            effect eDamage = EffectAbilityDecrease(ABILITY_CONSTITUTION, SWFP_DAMAGE);

            if (GetHasSpellEffect(FORCE_POWER_DRAIN_LIFE, oTarget) || GetHasSpellEffect(FORCE_POWER_DEATH_FIELD, oTarget))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                CP_DebugMsg("You can only drain one target at a time!");
                break;
            }

            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oTarget, fLightningDuration);
            DelayCommand(0.3, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFX, oTarget));

            int nResist = Sp_BlockingChecks(oTarget, eDamage, eInvalid, eInvalid);

            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), SWFP_HARMFUL));

            if(GetRacialType(oTarget) != RACIAL_TYPE_DROID)
            {
                if(nResist == 0)
                {
                    int nSaves = Sp_MySavingThrows(oTarget);
                    if(nSaves == 0)
                    {
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDamage, oTarget, 30.0);
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHeal, OBJECT_SELF, 30.0);
                    }
                    else
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
                }
                else
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectForceFizzle(), OBJECT_SELF);
            }
        }
        break;
    }
}
