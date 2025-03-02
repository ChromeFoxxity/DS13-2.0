

/mob/living/carbon/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, spread_damage = FALSE, sharpness = NONE, attack_direction = null, cap_loss_at = 0)
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone)
	var/hit_percent = (100-blocked)/100
	if(!damage || (!forced && hit_percent <= 0))
		return 0

	var/obj/item/bodypart/BP = null
	if(!spread_damage)
		if(isbodypart(def_zone)) //we specified a bodypart object
			BP = def_zone
		else
			if(!def_zone)
				def_zone = ran_zone(def_zone)
			BP = get_bodypart(deprecise_zone(def_zone))
			if(!BP)
				BP = bodyparts[1]

	var/damage_amount = forced ? damage : damage * hit_percent
	switch(damagetype)
		if(BRUTE)
			if(BP)
				BP.receive_damage(damage_amount, 0, sharpness = sharpness)
			else //no bodypart, we deal damage with a more general method.
				adjustBruteLoss(damage_amount, forced = forced)
		if(BURN)
			if(BP)
				BP.receive_damage(0, damage_amount, sharpness = sharpness)
			else
				adjustFireLoss(damage_amount, forced = forced)
		if(TOX)
			adjustToxLoss(damage_amount, forced = forced)
		if(OXY)
			adjustOxyLoss(damage_amount, forced = forced)
		if(CLONE)
			adjustCloneLoss(damage_amount, forced = forced)
		if(STAMINA)
			CRASH("apply_damage tried to adjust stamina loss!")
	return TRUE


//These procs fetch a cumulative total damage from all bodyparts
/mob/living/carbon/getBruteLoss()
	var/amount = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		amount += BP.brute_dam
	return amount

/mob/living/carbon/getFireLoss()
	var/amount = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		amount += BP.burn_dam
	return amount


/mob/living/carbon/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(amount, 0, updating_health, required_status, can_break_bones = FALSE)
	else
		heal_overall_damage(abs(amount), 0, required_status ? required_status : BODYTYPE_ORGANIC, updating_health)
	return amount

/mob/living/carbon/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(0, amount, updating_health, required_status, can_break_bones = FALSE)
	else
		heal_overall_damage(0, abs(amount), required_status ? required_status : BODYTYPE_ORGANIC, updating_health)
	return amount

/mob/living/carbon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!amount)
		return
	var/heal = amount < 0
	if(!forced && HAS_TRAIT(src, TRAIT_TOXINLOVER)) //damage becomes healing and healing becomes damage
		amount = -amount
		if(HAS_TRAIT(src, TRAIT_TOXIMMUNE)) //Prevents toxin damage, but not healing
			amount = min(amount, 0)
		if(!heal)
			blood_volume = max(blood_volume - (5*amount), 0)
		else
			blood_volume = max(blood_volume - amount, 0)
	else if(HAS_TRAIT(src, TRAIT_TOXIMMUNE)) //Prevents toxin damage, but not healing
		amount = min(amount, 0)

	if(!heal) //Not a toxin lover
		amount *= (1 - (CHEM_EFFECT_MAGNITUDE(src, CE_ANTITOX) * 0.25)) || 1

	var/list/pick_organs = shuffle(processing_organs)
	// Prioritize damaging our filtration organs first.
	var/obj/item/organ/liver/liver = organs_by_slot[ORGAN_SLOT_LIVER]
	if(liver)
		pick_organs -= liver
		pick_organs.Insert(1, liver)

	// Move the brain to the very end since damage to it is vastly more dangerous
	// (and isn't technically counted as toxloss) than general organ damage.
	var/obj/item/organ/brain/brain = organs_by_slot[ORGAN_SLOT_BRAIN]
	if(brain)
		pick_organs -= brain
		pick_organs += brain

	for(var/obj/item/organ/O as anything in pick_organs)
		if(heal)
			if(amount >= 0)
				break
		else if(amount <= 0)
			break

		amount -= O.applyOrganDamage(amount, silent = TRUE, updating_health = FALSE)

	if(updating_health)
		updatehealth()

/mob/living/carbon/getToxLoss()
	for(var/obj/item/organ/O as anything in processing_organs)
		. += O.getToxLoss()

/mob/living/carbon/pre_stamina_change(diff as num, forced)
	if(!forced && (status_flags & GODMODE))
		return 0
	return diff

/**
 * If an organ exists in the slot requested, and we are capable of taking damage (we don't have [GODMODE] on), call the damage proc on that organ.
 *
 * Arguments:
 * * slot - organ slot, like [ORGAN_SLOT_HEART]
 * * amount - damage to be done
 * * maximum - currently an arbitrarily large number, can be set so as to limit damage
 */
/mob/living/carbon/adjustOrganLoss(slot, amount, maximum, updating_health)
	var/obj/item/organ/O = getorganslot(slot)
	if(O && !(status_flags & GODMODE))
		O.applyOrganDamage(amount, maximum, updating_health = updating_health)

/**
 * If an organ exists in the slot requested, and we are capable of taking damage (we don't have [GODMODE] on), call the set damage proc on that organ, which can
 * set or clear the failing variable on that organ, making it either cease or start functions again, unlike adjustOrganLoss.
 *
 * Arguments:
 * * slot - organ slot, like [ORGAN_SLOT_HEART]
 * * amount - damage to be set to
 */
/mob/living/carbon/setOrganLoss(slot, amount)
	var/obj/item/organ/O = getorganslot(slot)
	if(O && !(status_flags & GODMODE))
		O.setOrganDamage(amount)

/**
 * If an organ exists in the slot requested, return the amount of damage that organ has
 *
 * Arguments:
 * * slot - organ slot, like [ORGAN_SLOT_HEART]
 */
/mob/living/carbon/getOrganLoss(slot)
	if(slot == ORGAN_SLOT_BRAIN)
		return getBrainLoss()

	var/obj/item/organ/O = getorganslot(slot)
	if(O)
		return O.damage

/mob/living/carbon/getBrainLoss()
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	return B ? B.damage : maxHealth

////////////////////////////////////////////

///Returns a list of damaged bodyparts
/mob/living/carbon/proc/get_damaged_bodyparts(brute = FALSE, burn = FALSE, status, check_flags)
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		if(status && !(BP.bodytype & status))
			continue
		if((brute && BP.brute_dam) || (burn && BP.burn_dam) || (BP.bodypart_flags & check_flags))
			parts += BP

	return parts

///Returns a list of damageable bodyparts
/mob/living/carbon/proc/get_damageable_bodyparts(status)
	var/list/obj/item/bodypart/parts = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(status && !(BP.bodytype & status))
			continue
		if(BP.is_damageable())
			parts += BP
	return parts

/**
 * Heals ONE bodypart randomly selected from damaged ones.
 *
 * It automatically updates damage overlays if necessary
 *
 * It automatically updates health status
 */
/mob/living/carbon/heal_bodypart_damage(brute = 0, burn = 0, updating_health = TRUE, required_status)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute,burn,required_status)
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	var/damage_calculator = picked.get_damage() //heal_damage returns update status T/F instead of amount healed so we dance gracefully around this
	if(picked.heal_damage(brute, burn, required_status))
		update_damage_overlays()
	return max(damage_calculator - picked.get_damage(), 0)


/**
 * Damages ONE bodypart randomly selected from damagable ones.
 *
 * It automatically updates damage overlays if necessary
 *
 * It automatically updates health status
 */
/mob/living/carbon/take_bodypart_damage(brute = 0, burn = 0, updating_health = TRUE, required_status, check_armor = FALSE, sharpness = NONE)
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_status)
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	if(picked.receive_damage(brute, burn, blocked = check_armor ? run_armor_check(picked, (brute ? MELEE : burn ? FIRE : null)) : FALSE, sharpness = sharpness))
		update_damage_overlays()

///Heal MANY bodyparts, in random order
/mob/living/carbon/heal_overall_damage(brute = 0, burn = 0, required_status, updating_health = TRUE)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute, burn, required_status)

	var/update = NONE
	while(parts.len && (brute > 0 || burn > 0))
		var/obj/item/bodypart/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute, burn, required_status, FALSE)

		brute = round(brute - (brute_was - picked.brute_dam), DAMAGE_PRECISION)
		burn = round(burn - (burn_was - picked.burn_dam), DAMAGE_PRECISION)

		parts -= picked

	if(updating_health)
		updatehealth()
	if(update)
		update_damage_overlays()

/// damage MANY bodyparts, in random order
/mob/living/carbon/take_overall_damage(brute = 0, burn = 0, updating_health = TRUE, required_status, sharpness, can_break_bones = TRUE)
	if(status_flags & GODMODE)
		return //godmode

	var/list/obj/item/bodypart/not_full = get_damageable_bodyparts(required_status)
	if(!length(not_full))
		return

	var/update = 0

	// Receive_damage() rounds to damage precision, dont bother doing it here.
	brute /= length(not_full)
	burn /= length(not_full)

	for(var/obj/item/bodypart/bp as anything in not_full)
		update |= bp.receive_damage(brute, burn, 0, FALSE, required_status, sharpness, can_break_bones)

	if(updating_health && (update & BODYPART_LIFE_UPDATE_HEALTH))
		updatehealth()
	if(update & BODYPART_LIFE_UPDATE_DAMAGE_OVERLAYS)
		update_damage_overlays()

/mob/living/carbon/getOxyLoss()
	var/obj/item/organ/lungs/L = getorganslot(ORGAN_SLOT_LUNGS)
	if(!L || (L.organ_flags & ORGAN_DEAD))
		return maxHealth / 2
	return ..()
