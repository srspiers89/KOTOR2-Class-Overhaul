// cgo_inc_force.nss
// Modified & Custom Force Powers for Complete Gameplay Overhaul

void CGO_RunForcePowers();

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

        case 900: // Force Empathy 284 -> enemies take damage when they attack
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
    }
}
