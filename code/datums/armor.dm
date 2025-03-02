#define ARMORID "armor-[melee]-[bullet]-[laser]-[energy]-[bomb]-[bio]-[fire]-[acid]"

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0)
	. = locate(ARMORID)
	if (!.)
		. = new /datum/armor(melee, bullet, laser, energy, bomb, bio, fire, acid)

///Retreive an atom's armor, creating it if it doesn't exist
/atom/proc/returnArmor() //This is copypasted to physiology/proc/returnArmor()!!! update it too!!!
	RETURN_TYPE(/datum/armor)
	if(istype(armor, /datum/armor))
		return armor

	if(islist(armor) || isnull(armor))
		armor = getArmor(arglist(armor))
		return armor

///Setter for armor
/atom/proc/setArmor(datum/new_armor)
	armor = new_armor

/datum/armor
	var/melee
	var/bullet
	var/laser
	var/energy
	var/bomb
	var/bio
	var/fire
	var/acid

/datum/armor/New(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0)
	src.melee = melee
	src.bullet = bullet
	src.laser = laser
	src.energy = energy
	src.bomb = bomb
	src.bio = bio
	src.fire = fire
	src.acid = acid
	GenerateTag()

/datum/armor/proc/modifyRating(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0)
	return getArmor(src.melee+melee, src.bullet+bullet, src.laser+laser, src.energy+energy, src.bomb+bomb, src.bio+bio, src.fire+fire, src.acid+acid)

/datum/armor/proc/modifyAllRatings(modifier = 0)
	return getArmor(melee+modifier, bullet+modifier, laser+modifier, energy+modifier, bomb+modifier, bio+modifier, fire+modifier, acid+modifier)

/datum/armor/proc/setRating(melee, bullet, laser, energy, bomb, bio, fire, acid, wound, consume)
	return getArmor((isnull(melee) ? src.melee : melee),\
					(isnull(bullet) ? src.bullet : bullet),\
					(isnull(laser) ? src.laser : laser),\
					(isnull(energy) ? src.energy : energy),\
					(isnull(bomb) ? src.bomb : bomb),\
					(isnull(bio) ? src.bio : bio),\
					(isnull(fire) ? src.fire : fire),\
					(isnull(acid) ? src.acid : acid))

/datum/armor/proc/getRating(rating)
	return vars[rating]

/datum/armor/proc/getList()
	return list(MELEE = melee, BULLET = bullet, LASER = laser, ENERGY = energy, BOMB = bomb, BIO = bio, FIRE = fire, ACID = acid)

/datum/armor/proc/attachArmor(datum/armor/AA)
	return getArmor(melee+AA.melee, bullet+AA.bullet, laser+AA.laser, energy+AA.energy, bomb+AA.bomb, bio+AA.bio, fire+AA.fire, acid+AA.acid)

/datum/armor/proc/detachArmor(datum/armor/AA)
	return getArmor(melee-AA.melee, bullet-AA.bullet, laser-AA.laser, energy-AA.energy, bomb-AA.bomb, bio-AA.bio, fire-AA.fire, acid-AA.acid)

/datum/armor/GenerateTag()
	. = ..()
	tag = ARMORID

/datum/armor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, tag))
		return FALSE
	. = ..()
	GenerateTag()

#undef ARMORID
