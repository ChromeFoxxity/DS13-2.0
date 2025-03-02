/**
Seeker Rifles
*/

/obj/item/gun/ballistic/deadspace/twohanded/seeker //Based a bit on /obj/item/gun/ballistic/automatic/sniper_rifle
	name = "Seeker Rifle"
	desc = "The Seeker Rifle is a riot control device that is meant for accuracy at long-range. Comes with a built-in scope."
	icon = 'deadspace/icons/obj/weapons/ds13guns48x32.dmi'
	icon_state = "seeker"
	base_icon_state = "seeker"
	lefthand_file = 'deadspace/icons/mob/onmob/items/lefthand_guns.dmi'
	righthand_file = 'deadspace/icons/mob/onmob/items/righthand_guns.dmi'
	worn_icon = 'deadspace/icons/mob/onmob/back.dmi'
	worn_icon_state = "seeker"
	inhand_icon_state = null
	mag_display = FALSE
	show_bolt_icon = FALSE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	mag_type = /obj/item/ammo_box/magazine/seeker
	fire_delay = 1.5 SECONDS
	can_suppress = FALSE
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_SUITSTORE
	one_handed_penalty = 50
	recoil = 2
	burst_size = 1
	bolt_type = BOLT_TYPE_OPEN
	actions_types = list()
	//tier_1_bonus = 1 //Cut slashers some slack
	fire_sound = 'deadspace/sound/weapons/guns/seeker_fire.ogg'
	fire_sound_volume = 90
	load_sound = 'deadspace/sound/weapons/guns/seeker_load.ogg'
	eject_sound = 'deadspace/sound/weapons/guns/pulse_magout.ogg'

/obj/item/gun/ballistic/deadspace/twohanded/seeker/no_mag
	spawnwithmagazine = FALSE

//Scope is bugged. Wait until upstream gets merged in.
/obj/item/gun/ballistic/deadspace/twohanded/seeker/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(on_unwield))
	AddComponent(/datum/component/scope, range_modifier = 2) //Scope component seems bugged, will need checking on

	AddComponent(/datum/component/two_handed, force_unwielded=5, force_wielded=8, icon_wielded="[base_icon_state]-wielded")

/obj/item/gun/ballistic/deadspace/twohanded/seeker/egov
	name = "Earthgov Seeker Rifle"
	desc = "The Earthgov Seeker Rifle is a riot control device that is meant for accuracy at long-range. Comes with a built-in scope."
	icon_state = "seeker" //Maybe get a new sprite for it in the future
	fire_delay = 4
	recoil = 0.4
	burst_size = 3
	actions_types = list(/datum/action/item_action/toggle_firemode)
	projectile_damage_multiplier = 1.15

/obj/item/gun/ballistic/deadspace/twohanded/seeker/egov/Initialize(mapload)
	magazine = new /obj/item/ammo_box/magazine/seeker/egov(src)
	return ..()

/**
Magazines
*/

/obj/item/ammo_box/magazine/seeker
	name = "seeker shells"
	desc = "High caliber armor piercing shells designed for use in the Seeker Rifle."
	icon = 'deadspace/icons/obj/ammo.dmi'
	icon_state = "seeker"
	base_icon_state = "seeker-6"
	caliber = CALIBER_SEEKER
	ammo_type = /obj/item/ammo_casing/caseless/seeker
	max_ammo = 6
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/magazine/seeker/egov
	name = "assault seeker shells"
	desc = "Medium caliber armor piercing shells designed for use in the Seeker Rifle, designed for use with Earthgov models, to be used more akin to an assault rifle."
	icon_state = "seeker-6"
	base_icon_state = "seeker"
	ammo_type = /obj/item/ammo_casing/caseless/seeker/egov
	max_ammo = 24
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/seeker/egov/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4) / 4]"

//Can potentially add alternative ammo, like the .50 cal. Soporific, penetrator, marksman, etc

/**
Ammo casings for the mags
*/

/obj/item/ammo_casing/caseless/seeker
	name = "seeker shell"
	desc = "A high caliber round designed for the Seeker Rifle."
	icon_state = "ionshell-live"
	caliber = CALIBER_SEEKER
	projectile_type = /obj/projectile/bullet/seeker

/obj/item/ammo_casing/caseless/seeker/egov
	projectile_type = /obj/projectile/bullet/seeker/egov

/**
Projectiles for the casings
*/

/obj/projectile/bullet/seeker
	name ="seeker shell"
	speed = 0.4
	damage = 60
	paralyze = 10
	dismemberment = 30
	armour_penetration = 50
	embedding = list(embed_chance=50, fall_chance=2, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=7, rip_time=8)
	// var/breakthings = TRUE

/obj/projectile/bullet/seeker/egov
	name ="seeker shell"
	damage = 20
	paralyze = 30
	dismemberment = 10
	armour_penetration = 20
	embedding = list(embed_chance=40, fall_chance=2, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=7, rip_time=8)

//Taken from .50 sniper. Keeping here for now, as something to check on later
// /obj/projectile/bullet/seeker/on_hit(atom/target, blocked = 0)
// 	if(isobj(target) && (blocked != 100) && breakthings)
// 		var/obj/O = target
// 		O.take_damage(80, BRUTE, BULLET, FALSE)
// 	return ..()
