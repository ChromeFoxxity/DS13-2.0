/obj/item/bodypart/chest/necromorph/leaper
	name = BODY_ZONE_CHEST
	limb_id = SPECIES_NECROMORPH_LEAPER
	icon_static = 'deadspace/icons/necromorphs/leaper.dmi'
	icon_state = "chest"
	max_damage = 200
	px_x = 0
	px_y = 0
	wound_resistance = 10

/obj/item/bodypart/head/necromorph/leaper
	name = BODY_ZONE_HEAD
	limb_id = SPECIES_NECROMORPH_LEAPER
	icon_static = 'deadspace/icons/necromorphs/leaper.dmi'
	icon_state = "head"
	max_damage = 200
	px_x = 0
	px_y = -8
	wound_resistance = 5

//Leapers use arms to walk
/obj/item/bodypart/leg/left/necromorph/leaper
	name = "left arm"
	limb_id = SPECIES_NECROMORPH_LEAPER
	icon_static = 'deadspace/icons/necromorphs/leaper.dmi'
	icon_state = "l_arm"
	body_part = LEG_LEFT
	attack_verb_continuous = list("kicks", "stomps")
	attack_verb_simple = list("kick", "stomp")
	max_damage = 50
	px_x = -2
	px_y = 12
	wound_resistance = 0

/obj/item/bodypart/leg/right/necromorph/leaper
	name = "right arm"
	limb_id = SPECIES_NECROMORPH_LEAPER
	icon_static = 'deadspace/icons/necromorphs/leaper.dmi'
	icon_state = "l_arm"
	attack_verb_continuous = list("kicks", "stomps")
	attack_verb_simple = list("kick", "stomp")
	max_damage = 50
	px_x = 2
	px_y = 12
	wound_resistance = 0
