	//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical voidsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	inhand_icon_state = "medical_helm"
	hardsuit_type = "medical"
	flash_protect = FLASH_PROTECTION_NONE
	armor = list(MELEE = 15, BULLET = 10, LASER = 10, ENERGY = 20, BOMB = 40, BIO = 100, FIRE = 60, ACID = 100)
	clothing_traits = list(TRAIT_REAGENT_SCANNER)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT

/obj/item/clothing/suit/space/hardsuit/medical
	name = "medical voidsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Built with lightweight materials for easier movement."
	icon_state = "hardsuit-medical"
	inhand_icon_state = "medical_hardsuit"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/medkit, /obj/item/healthanalyzer, /obj/item/stack/medical)
	armor = list(MELEE = 15, BULLET = 10, LASER = 10, ENERGY = 20, BOMB = 40, BIO = 100, FIRE = 60, ACID = 100)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical
	slowdown = 0.5
