/mob/living/carbon/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	. = list("<span class='info'>This is [icon2html(src, user)] \a <EM>[src]</EM>!<hr>") //PARIAH EDIT CHANGE
	var/obscured = check_obscured_slots()

	if (handcuffed)
		. += span_warning("[t_He] [t_is] handcuffed with [icon2html(handcuffed, user)] [handcuffed]!")
	if (head)
		. += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head. "
	if(wear_mask && !(obscured & ITEM_SLOT_MASK))
		. += "[t_He] [t_is] wearing [wear_mask.get_examine_string(user)] on [t_his] face."
	if(wear_neck && !(obscured & ITEM_SLOT_NECK))
		. += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck."

	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[t_He] [t_is] holding [I.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(I))]."

	if (back)
		. += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."
	var/appears_dead = FALSE
	if (stat == DEAD)
		appears_dead = TRUE
		if(getorgan(/obj/item/organ/brain))
			. += span_deadsay("[t_He] [t_is] limp and unresponsive, with no signs of life.")
		else if(get_bodypart(BODY_ZONE_HEAD))
			. += span_deadsay("It appears that [t_his] brain is missing...")

	var/list/msg = list("<span class='warning'>")
	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/list/disabled = list()
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		if(BP.bodypart_disabled)
			disabled += BP
		missing -= BP.body_zone
		for(var/obj/item/I in BP.embedded_objects)
			if(I.isEmbedHarmless())
				msg += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] stuck to [t_his] [BP.name]!</B>\n"
			else
				msg += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] embedded in [t_his] [BP.name]!</B>\n"

		msg += BP.mob_examine()

	for(var/obj/item/bodypart/BP as anything in disabled)
		var/damage_text
		if(!(BP.get_damage() >= BP.max_damage)) //Stamina is disabling the limb
			damage_text = "limp and lifeless"
		else
			damage_text = (BP.brute_dam >= BP.burn_dam) ? BP.heavy_brute_msg : BP.heavy_burn_msg
		msg += "<B>[capitalize(t_his)] [BP.name] is [damage_text]!</B>\n"

	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "[span_deadsay("<B>[t_His] [parse_zone(t)] is missing!</B>")]\n"
			continue
		msg += "[span_warning("<B>[t_His] [parse_zone(t)] is missing!</B>")]\n"


	var/temp = getBruteLoss()
	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if (temp < 25)
				msg += "[t_He] [t_has] minor bruising.\n"
			else if (temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> bruising!\n"
			else
				msg += "<B>[t_He] [t_has] severe bruising!</B>\n"

		temp = getFireLoss()
		if(temp)
			if (temp < 25)
				msg += "[t_He] [t_has] minor burns.\n"
			else if (temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> burns!\n"
			else
				msg += "<B>[t_He] [t_has] severe burns!</B>\n"

		temp = getCloneLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_is] slightly deformed.\n"
			else if (temp < 50)
				msg += "[t_He] [t_is] <b>moderately</b> deformed!\n"
			else
				msg += "<b>[t_He] [t_is] severely deformed!</b>\n"

	if(HAS_TRAIT(src, TRAIT_DUMB))
		msg += "[t_He] seem[p_s()] to be clumsy and unable to think.\n"

	if(has_status_effect(/datum/status_effect/fire_handler/fire_stacks))
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(has_status_effect(/datum/status_effect/fire_handler/wet_stacks))
		msg += "[t_He] look[p_s()] a little soaked.\n"

	if(pulledby?.grab_state)
		msg += "[t_He] [t_is] restrained by [pulledby]'s grip.\n"

	msg += "</span>"

	. += msg.Join("")

	if(!appears_dead)
		if(stat != CONSCIOUS)
			. += "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.\n"
		else if(HAS_TRAIT(src, TRAIT_SOFT_CRITICAL_CONDITION))
			msg += "[t_He] [t_is] barely conscious.\n"

	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/mob/living/carbon/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You examine [src] closer, and note the following...</i>")

	//On closer inspection, this man isnt a man at all!
	var/list/covered_zones = get_covered_body_zones()
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(part.body_zone in covered_zones)
			continue
		if(part.limb_id != (dna.species.examine_limb_id ? dna.species.examine_limb_id : dna.species.id))
			. += "[span_info("[p_they(TRUE)] [p_have()] \an [part.name].")]"

	return .
