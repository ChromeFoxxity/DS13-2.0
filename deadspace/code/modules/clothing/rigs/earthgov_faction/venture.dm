/datum/mod_theme/deadspace/venture
	name = "venture"
	desc = "The colors of the EDF Corps of Engineers, adopted after their victory at Europa's Conamara Chaos Iceworks during the Resource Wars."
	default_skin = "venture"
	armor = list(MELEE = 50, BULLET = 40, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = 25

	skins = list(
		"venture" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = WOUND_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/control/pre_equipped/ds/venture
	theme = /datum/mod_theme/deadspace/venture
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/anomaly_locked/kinesis/prebuilt,
		/obj/item/mod/module/t_ray,
	)
