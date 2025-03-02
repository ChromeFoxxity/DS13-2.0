/atom/movable
	/// The mimic (if any) that's *directly* copying us.
	var/tmp/atom/movable/openspace/mimic/bound_overlay
	/// Movable-level Z-Mimic flags. This uses ZMM_* flags, not ZM_* flags.
	var/zmm_flags = NONE

/atom/movable/setDir(ndir)
	. = ..()
	if (bound_overlay)
		bound_overlay.setDir(dir)

/atom/movable/update_above()
	if (!bound_overlay || !isturf(loc))
		return

	if (MOVABLE_IS_BELOW_ZTURF(src))
		SSzcopy.queued_overlays += bound_overlay
		bound_overlay.queued += 1
	else if (bound_overlay && !bound_overlay.destruction_timer)
		bound_overlay.destruction_timer = QDEL_IN_STOPPABLE(bound_overlay, 10 SECONDS)

// Grabs a list of every openspace mimic that's directly or indirectly copying this object. Returns an empty list if none found.
/atom/movable/proc/get_associated_mimics()
	. = list()
	var/atom/movable/curr = src
	while (curr.bound_overlay)
		. += curr.bound_overlay
		curr = curr.bound_overlay

// -- Openspace movables --

/atom/movable/openspace
	name = ""
	simulated = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// Please respect the openspace objects' personal space by not interacting with them, they get spooked.

/atom/movable/openspace/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/atom/movable/openspace/fire_act(exposed_temperature, exposed_volume)
	return

/atom/movable/openspace/acid_act()
	return FALSE

/atom/movable/openspace/blob_act(obj/structure/blob/B)
	return

/atom/movable/openspace/attack_hulk(mob/living/carbon/human/user)
	return FALSE

/atom/movable/openspace/ex_act(severity, target)
	return FALSE

/atom/movable/openspace/singularity_pull()
	return

/atom/movable/openspace/singularity_act()
	return

/atom/movable/openspace/has_gravity(turf/T)
	return FALSE

/atom/movable/openspace/CanZFall(turf/from, direction, anchor_bypass)
	return FALSE

// -- MULTIPLIER / SHADOWER --

// Holder object used for dimming openspaces & copying lighting of below turf.
/atom/movable/openspace/multiplier
	name = "openspace multiplier"
	desc = "You shouldn't see this."
	icon = LIGHTING_ICON
	icon_state = "lighting_transparent"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ZMIMIC_MAX_PLANE
	layer = MIMICKED_LIGHTING_LAYER
	blend_mode = BLEND_MULTIPLY
	color = SHADOWER_DARKENING_COLOR

/atom/movable/openspace/multiplier/Destroy(force)
	if(!force)
		stack_trace("Turf shadower improperly qdel'd.")
		return QDEL_HINT_LETMELIVE
	var/turf/myturf = loc
	if (istype(myturf))
		myturf.shadower = null
	return ..()

/atom/movable/openspace/multiplier/proc/copy_lighting(datum/lighting_object/LO)
	ASSERT(LO != null)
	appearance = LO.current_underlay
	layer = MIMICKED_LIGHTING_LAYER
	plane = ZMIMIC_MAX_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/turf/Tloc = loc
	if (Tloc.ao_overlays_mimic)
		overlays += Tloc.ao_overlays_mimic
	invisibility = 0

	if (islist(color))
		// We're using a color matrix, so just darken the colors across the board.
		var/list/c_list = color
		c_list[CL_MATRIX_RR] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_RG] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_RB] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_GR] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_GG] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_GB] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_BR] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_BG] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_BB] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_AR] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_AG] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_AB] *= SHADOWER_DARKENING_FACTOR
		color = c_list
	else
		// Not a color matrix, so we can just use the color var ourselves.
		color = SHADOWER_DARKENING_COLOR
		icon_state = "lighting_transparent"

	UPDATE_OO_IF_PRESENT

//! -- OPENSPACE MIMIC --

/// Object used to hold a mimiced atom's appearance.
/atom/movable/openspace/mimic
	plane = ZMIMIC_MAX_PLANE
	var/atom/movable/associated_atom
	var/depth
	var/queued = 0
	var/destruction_timer
	var/mimiced_type
	var/original_z
	var/override_depth
	var/have_performed_fixup = FALSE

/atom/movable/openspace/mimic/New()
	initialized = TRUE
	SSzcopy.openspace_overlays += 1

/atom/movable/openspace/mimic/Destroy()
	SSzcopy.openspace_overlays -= 1
	queued = 0
	if(HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		lose_hearing_sensitivity()

	if (associated_atom)
		associated_atom.bound_overlay = null
		associated_atom = null

	if (destruction_timer)
		deltimer(destruction_timer)

	return ..()

/atom/movable/openspace/mimic/attackby(obj/item/W, mob/user)
	to_chat(user, span_notice("\The [src] is too far away."))
	return TRUE

/atom/movable/openspace/mimic/attack_hand(mob/user)
	to_chat(user, span_notice("You cannot reach \the [src] from here."))
	return TRUE

/atom/movable/openspace/mimic/examine(...)
	SHOULD_CALL_PARENT(FALSE)
	. = associated_atom.examine(arglist(args))	// just pass all the args to the copied atom

/atom/movable/openspace/mimic/forceMove(turf/dest)
	. = ..()
	if (MOVABLE_IS_BELOW_ZTURF(associated_atom))
		if (destruction_timer)
			deltimer(destruction_timer)
			destruction_timer = null
	else if (!destruction_timer)
		destruction_timer = QDEL_IN_STOPPABLE(src, 10 SECONDS)

/atom/movable/openspace/mimic/newtonian_move(direction, instant, start_delay) // No.
	return TRUE

/atom/movable/openspace/mimic/set_glide_size(target)
	return

/atom/movable/openspace/mimic/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, atom/sound_loc)
	if(speaker.z != src.z)
		return

	//Mimics of mimics aren't supposed to become hearing sensitive.
	associated_atom.Hear(arglist(args))

/atom/movable/openspace/mimic/show_message(msg, type, alt_msg, alt_type, avoid_highlighting = FALSE)
	if(ismob(associated_atom))
		associated_atom:show_message(arglist(args))

/atom/movable/openspace/mimic/proc/get_root()
	RETURN_TYPE(/atom/movable)

	. = associated_atom
	while (istype(., /atom/movable/openspace/mimic))
		. = (.):associated_atom

// Called when the turf we're on is deleted/changed.
/atom/movable/openspace/mimic/proc/owning_turf_changed()
	if (!destruction_timer)
		destruction_timer = QDEL_IN_STOPPABLE(src, 10 SECONDS)

/atom/movable/openspace/mimic/proc/z_shift()
	if (istype(associated_atom, type) && associated_atom:override_depth)
		depth = associated_atom:override_depth
	else if (isturf(associated_atom.loc))
		depth = min(SSzcopy.zlev_maximums[associated_atom.z] - associated_atom.z, ZMIMIC_MAX_DEPTH)
		override_depth = depth

	plane = ZMIMIC_MAX_PLANE - depth

	bound_overlay?.z_shift()

// -- TURF PROXY --

// This thing holds the mimic appearance for non-OVERWRITE turfs.
/atom/movable/openspace/turf_proxy
	plane = ZMIMIC_MAX_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	zmm_flags = ZMM_IGNORE  // Only one of these should ever be visible at a time, the mimic logic will handle that.

/atom/movable/openspace/turf_proxy/attackby(obj/item/W, mob/user)
	return loc.attackby(W, user)

/atom/movable/openspace/turf_proxy/attack_hand(mob/user as mob)
	return loc.attack_hand(user)

/atom/movable/openspace/turf_proxy/attack_generic(mob/user as mob)
	return loc.attack_generic(user)

/atom/movable/openspace/turf_proxy/examine(mob/examiner)
	SHOULD_CALL_PARENT(FALSE)
	. = loc.examine(examiner)


// -- TURF MIMIC --

// A type for copying non-overwrite turfs' self-appearance.
/atom/movable/openspace/turf_mimic
	plane = ZMIMIC_MAX_PLANE	// These *should* only ever be at the top?
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/turf/delegate

/atom/movable/openspace/turf_mimic/Initialize(mapload, ...)
	. = ..()
	ASSERT(isturf(loc))
	delegate = loc:below

/atom/movable/openspace/turf_mimic/attackby(obj/item/W, mob/user)
	return loc.attackby(W, user)

/atom/movable/openspace/turf_mimic/attack_hand(mob/user as mob)
	to_chat(user, span_notice("You cannot reach \the [src] from here."))
	return TRUE

/atom/movable/openspace/turf_mimic/attack_generic(mob/user as mob)
	to_chat(user, span_notice("You cannot reach \the [src] from here."))
	return TRUE

/atom/movable/openspace/turf_mimic/examine(mob/examiner)
	SHOULD_CALL_PARENT(FALSE)
	. = delegate.examine(examiner)
