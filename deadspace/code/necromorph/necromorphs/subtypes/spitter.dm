/mob/living/carbon/human/necromorph/spitter
	class = /datum/necro_class/spitter
	necro_species = /datum/species/necromorph/spitter

/mob/living/carbon/human/necromorph/spitter/play_necro_sound(audio_type, volume, vary, extra_range)
	playsound(src, pick(GLOB.spitter_sounds[audio_type]), volume, vary, extra_range)

/datum/necro_class/spitter
	display_name = "Spitter"
	desc = "A midline skirmisher with the ability to spit acid at medium range. Works best when accompanied by slashers to protect it from attacks. Weak and fragile in direct combat."
	ui_icon = 'deadspace/icons/necromorphs/spitter.dmi'
	necromorph_type_path = /mob/living/carbon/human/necromorph/spitter
	nest_allowed = TRUE
	tier = 1
	biomass_cost = 50
	biomass_spent_required = 0
	melee_damage_lower = 10
	melee_damage_upper = 13
	max_health = 100
	actions = list(
		/datum/action/cooldown/necro/shoot/spitter_snapshoot,
		/datum/action/cooldown/necro/shoot/spitter_longshoot,
		/datum/action/cooldown/necro/shout,
		/datum/action/cooldown/necro/scream,
	)
	minimap_icon = "spitter"
	implemented = TRUE

/datum/species/necromorph/spitter
	name = "Spitter"
	id = SPECIES_NECROMORPH_SPITTER
	speedmod = 1.5
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/necromorph/spitter,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/necromorph/spitter,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/necromorph/spitter,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/necromorph/spitter,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/necromorph/spitter,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/necromorph/spitter,
	)

	deathsound = list(
		'deadspace/sound/effects/creatures/necromorph/spitter/spitter_death_1.ogg',
		'deadspace/sound/effects/creatures/necromorph/spitter/spitter_death_2.ogg',
		'deadspace/sound/effects/creatures/necromorph/spitter/spitter_death_3.ogg'
	)

/datum/species/necromorph/spitter/get_scream_sound(mob/living/carbon/human/necromorph/spitter)
	return pick(
		'deadspace/sound/effects/creatures/necromorph/spitter/spitter_pain_extreme.ogg',
		'deadspace/sound/effects/creatures/necromorph/spitter/spitter_pain_extreme_2.ogg',
	)

/datum/action/cooldown/necro/shoot/spitter_longshoot
	name = "Long shot"
	desc = "A powerful projectile for longrange shooting."
	cooldown_time = 3.5 SECONDS
	windup_time = 0.5 SECONDS
	projectiletype = /obj/projectile/bullet/biobomb/spitter_longshoot
	activate_keybind = COMSIG_KB_NECROMORPH_ABILITY_LONGSHOT_DOWN

/datum/action/cooldown/necro/shoot/spitter_longshoot/pre_fire(atom/target)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, src)

/datum/action/cooldown/necro/shoot/spitter_longshoot/post_fire()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, src)

/obj/projectile/bullet/biobomb/spitter_longshoot
	name = "acid blast"
	icon = 'deadspace/icons/obj/projectiles.dmi'
	icon_state = "acid_large"

	damage = 15
	speed = 0.8
	pixel_speed_multiplier = 0.5

	acid_type = /datum/reagent/toxin/acid/fluacid
	acid_amount = 3

#define SPITTER_SNAPSHOT_AUTOTARGET_RANGE 3

/datum/action/cooldown/necro/shoot/spitter_snapshoot
	name = "Snapshot"
	desc = "A moderate-strength projectile that auto-aims at targets within X range."
	cooldown_time = 3 SECONDS
	windup_time = 0 SECONDS
	projectiletype = /obj/projectile/bullet/biobomb/spitter_snapshoot
	activate_keybind = COMSIG_KB_NECROMORPH_ABILITY_SNAPSHOT_DOWN

/datum/action/cooldown/necro/shoot/spitter_snapshoot/New(Target, original, cooldown)
	desc = "A moderate-strength projectile. Auto-aims at targets within [SPITTER_SNAPSHOT_AUTOTARGET_RANGE] range."
	..()

/datum/action/cooldown/necro/shoot/spitter_snapshoot/PreActivate(atom/target)
	if(!isliving(target))
		for(var/mob/potential_target in view(SPITTER_SNAPSHOT_AUTOTARGET_RANGE, get_turf(target)))
			if(!faction_check(potential_target.faction, owner.faction))
				target = potential_target
				break
		if(!isliving(target))
			to_chat(owner, span_warning("No valid targets found within [SPITTER_SNAPSHOT_AUTOTARGET_RANGE] tiles range."))
			return TRUE
	return ..()

#undef SPITTER_SNAPSHOT_AUTOTARGET_RANGE

/obj/projectile/bullet/biobomb/spitter_snapshoot
	name = "acid bolt"
	icon = 'deadspace/icons/obj/projectiles.dmi'
	icon_state = "acid_large"

	damage = 9
	speed = 0.8
	pixel_speed_multiplier = 0.7 //meant to be a close range attack, easier to hit but does less damage

	acid_type = /datum/reagent/toxin/acid/fluacid
	acid_amount = 2
