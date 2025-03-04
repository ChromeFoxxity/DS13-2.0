/obj/item/organ/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	visual = FALSE
	gender = PLURAL

	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = "<span class='info'>Your ears begin to resonate with an internal ring.</span>"
	now_failing = "<span class='warning'>You are unable to hear at all!</span>"
	now_fixed = "<span class='info'>Noise slowly begins filling your ears once more.</span>"
	low_threshold_cleared = "<span class='info'>The ringing in your ears has died down.</span>"

	relative_size = 5

	// `deaf` measures "ticks" of deafness. While > 0, the person is unable
	// to hear anything.
	var/deaf = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	//Resistance against loud noises
	var/bang_protect = 0
	// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/ears/on_life(delta_time, times_fired)
	// only inform when things got worse, needs to happen before we heal
	if((damage > (low_threshold * maxHealth) && prev_damage < (low_threshold * maxHealth)) || (damage > (high_threshold * maxHealth) && prev_damage < (high_threshold * maxHealth)))
		to_chat(owner, span_warning("The ringing in your ears grows louder, blocking out any external noises for a moment."))

	. = ..()
	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here. Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		return

	if((organ_flags & ORGAN_DEAD))
		deaf = max(deaf, 1) // if we're failing we always have at least 1 deaf stack (and thus deafness)
	else // only clear deaf stacks if we're not failing
		deaf = max(deaf - (0.5 * delta_time), 0)
		if((damage > low_threshold) && DT_PROB(damage / 60, delta_time))
			adjustEarDamage(0, 4)
			SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg'))

	if(deaf)
		ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
	else
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

/obj/item/organ/ears/proc/adjustEarDamage(ddmg, ddeaf)
	if(owner.status_flags & GODMODE)
		return
	setOrganDamage(max(damage + (ddmg*damage_multiplier), 0))
	deaf = max(deaf + (ddeaf*damage_multiplier), 0)

/obj/item/organ/ears/invincible
	damage_multiplier = 0

/obj/item/organ/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 2

	dna_block = DNA_EARS_BLOCK
	feature_key = "ears"
	layers = list(BODY_FRONT_LAYER, BODY_BEHIND_LAYER)
	color_source = ORGAN_COLOR_HAIR

/obj/item/organ/ears/cat/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	if(human.head && (human.head.flags_inv & HIDEHAIR) || (human.wear_mask && (human.wear_mask.flags_inv & HIDEHAIR)))
		return FALSE

/obj/item/organ/ears/cat/get_global_feature_list()
	return GLOB.ears_list

/obj/item/organ/ears/cat/build_overlays(physique, image_dir)
	. = ..()
	if(sprite_datum.hasinner)
		for(var/image_layer in layers)
			. += image(sprite_datum.icon, "m_earsinner_[sprite_datum.icon_state]_[global.layer2text["[image_layer]"]]", layer = -image_layer)


/obj/item/organ/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."

/obj/item/organ/ears/penguin/Insert(mob/living/carbon/human/ear_owner, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(!.)
		return

	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("You suddenly feel like you've lost your balance."))
		ADD_WADDLE(ear_owner, WADDLE_SOURCE_PENGUIN)

/obj/item/organ/ears/penguin/Remove(mob/living/carbon/human/ear_owner,  special = 0)
	. = ..()
	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("Your sense of balance comes back to you."))
		REMOVE_WADDLE(ear_owner, WADDLE_SOURCE_PENGUIN)

/obj/item/organ/ears/bronze
	name = "tin ears"
	desc = "The robust ears of a bronze golem. "
	damage_multiplier = 0.1 //STRONK
	bang_protect = 1 //Fear me weaklings.

/obj/item/organ/ears/cybernetic
	name = "cybernetic ears"
	icon_state = "ears-c"
	desc = "A basic cybernetic organ designed to mimic the operation of ears."
	damage_multiplier = 0.9
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/ears/cybernetic/upgraded
	name = "upgraded cybernetic ears"
	icon_state = "ears-c-u"
	desc = "An advanced cybernetic ear, surpassing the performance of organic ears."
	damage_multiplier = 0.5

/obj/item/organ/ears/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	applyOrganDamage(40/severity)
