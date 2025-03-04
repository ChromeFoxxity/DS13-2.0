// Because we can control each corner of every lighting object.
// And corners get shared between multiple turfs (unless you're on the corners of the map, then 1 corner doesn't).
// For the record: these should never ever ever be deleted, even if the turf doesn't have dynamic lighting.

/datum/lighting_corner
	var/list/datum/light_source/affecting // Light sources affecting us.

	var/x = 0
	var/y = 0

	var/turf/master_NE
	var/turf/master_SE
	var/turf/master_SW
	var/turf/master_NW

	var/sum_r = 0
	var/sum_g = 0
	var/sum_b = 0

	//color values from lights shining DIRECTLY on us
	VAR_PRIVATE/self_r = 0
	VAR_PRIVATE/self_g = 0
	VAR_PRIVATE/self_b = 0

	//true color values, guaranteed to be between 0 and 1
	var/cache_r = LIGHTING_SOFT_THRESHOLD
	var/cache_g = LIGHTING_SOFT_THRESHOLD
	var/cache_b = LIGHTING_SOFT_THRESHOLD

	// The intensity we're inheriting from the turf below us, if we're a Z-turf.
	var/below_r = 0
	var/below_g = 0
	var/below_b = 0

	//additive light values
	var/add_r = 0
	var/add_g = 0
	var/add_b = 0
	var/applying_additive = FALSE

	///the maximum of sum_r, sum_g, and sum_b. if this is > 1 then the three cached color values are divided by this
	var/largest_color_luminosity = 0

	///whether we are to be added to SSlighting's corners_queue list for an update
	var/needs_update = FALSE

/datum/lighting_corner/New(turf/new_turf, diagonal)
	. = ..()
	save_master(new_turf, turn(diagonal, 180))

	var/vertical = diagonal & ~(diagonal - 1) // The horizontal directions (4 and 8) are bigger than the vertical ones (1 and 2), so we can reliably say the lsb is the horizontal direction.
	var/horizontal = diagonal & ~vertical       // Now that we know the horizontal one we can get the vertical one.

	x = new_turf.x + (horizontal == EAST  ? 0.5 : -0.5)
	y = new_turf.y + (vertical == NORTH ? 0.5 : -0.5)

	// My initial plan was to make this loop through a list of all the dirs (horizontal, vertical, diagonal).
	// Issue being that the only way I could think of doing it was very messy, slow and honestly overengineered.
	// So we'll have this hardcode instead.
	var/turf/new_master_turf

	// Diagonal one is easy.
	new_master_turf = get_step(new_turf, diagonal)
	if (new_master_turf) // In case we're on the map's border.
		save_master(new_master_turf, diagonal)

	// Now the horizontal one.
	new_master_turf = get_step(new_turf, horizontal)
	if (new_master_turf) // Ditto.
		save_master(new_master_turf, ((new_master_turf.x > x) ? EAST : WEST) | ((new_master_turf.y > y) ? NORTH : SOUTH)) // Get the dir based on coordinates.

	// And finally the vertical one.
	new_master_turf = get_step(new_turf, vertical)
	if (new_master_turf)
		save_master(new_master_turf, ((new_master_turf.x > x) ? EAST : WEST) | ((new_master_turf.y > y) ? NORTH : SOUTH)) // Get the dir based on coordinates.

/datum/lighting_corner/proc/save_master(turf/master, dir)
	switch (dir)
		if (NORTHEAST)
			master_NE = master
			master.lighting_corner_SW = src
		if (SOUTHEAST)
			master_SE = master
			master.lighting_corner_NW = src
		if (SOUTHWEST)
			master_SW = master
			master.lighting_corner_NE = src
		if (NORTHWEST)
			master_NW = master
			master.lighting_corner_SE = src

/datum/lighting_corner/proc/vis_update()
	for (var/datum/light_source/light_source as anything in affecting)
		light_source.vis_update()

/datum/lighting_corner/proc/full_update()
	for (var/datum/light_source/light_source as anything in affecting)
		light_source.recalc_corner(src)

#define UPDATE_ABOVE_LUM(Tt, corner) \
	if((T = Tt?.above)) { \
		if(T.lighting_object) { \
			C = T.##corner; \
			if(!C) { \
				T.generate_missing_corners(); \
				C = T.##corner; \
			} \
			C.update_below_lumcount(delta_r, delta_g, delta_b); \
		} \
	}

#define UPDATE_SUM_LUM(color) (sum_##color = below_##color + self_##color)

// God that was a mess, now to do the rest of the corner code! Hooray!
/datum/lighting_corner/proc/update_lumcount(delta_r, delta_g, delta_b)
	if (!(delta_r || delta_g || delta_b)) // 0 is falsey ok
		return

	self_r += delta_r
	self_g += delta_g
	self_b += delta_b
	UPDATE_SUM_LUM(r)
	UPDATE_SUM_LUM(g)
	UPDATE_SUM_LUM(b)

	add_r = clamp((self_r - 1.1) * 0.3, 0, 0.22)
	add_g = clamp((self_g - 1.1) * 0.3, 0, 0.22)
	add_b = clamp((self_b - 1.1) * 0.3, 0, 0.22)

	// Client-shredding, does not cull any additive overlays.
	//applying_additive = add_r || add_g || add_b
	// Cull additive overlays that would be below 0.03 alpha in any color.
	applying_additive = max(add_r, add_g, add_b) > 0.03
	// Cull additive overlays whose color alpha sum is lower than 0.03
	//applying_additive = (add_r + add_g + add_b) > 0.03

	#ifdef ZMIMIC_LIGHT_BLEED
	var/turf/T
	var/datum/lighting_corner/C
	UPDATE_ABOVE_LUM(master_NE, lighting_corner_NE)
	UPDATE_ABOVE_LUM(master_SE, lighting_corner_SE)
	UPDATE_ABOVE_LUM(master_SW, lighting_corner_SW)
	UPDATE_ABOVE_LUM(master_NW, lighting_corner_NW)
	#endif

	if (!needs_update)
		needs_update = TRUE
		SSlighting.corners_queue += src

/datum/lighting_corner/proc/update_below_lumcount(delta_r, delta_g, delta_b, now = FALSE)
	if (!(delta_r + delta_g + delta_b))
		return

	below_r += delta_r
	below_g += delta_g
	below_b += delta_b

	UPDATE_SUM_LUM(r)
	UPDATE_SUM_LUM(g)
	UPDATE_SUM_LUM(b)

	// This needs to be down here instead of the above if so the lum values are properly updated.
	if (needs_update)
		return

	needs_update = TRUE
	SSlighting.corners_queue += src

/datum/lighting_corner/proc/update_objects()
	// Cache these values ahead of time so 4 individual lighting objects don't all calculate them individually.
	var/lr = src.sum_r
	var/lg = src.sum_g
	var/lb = src.sum_b
	var/largest_color_luminosity = max(sum_r, sum_g, sum_b) // Scale it so one of them is the strongest lum, if it is above 1.

	. = 1 // factor
	if (largest_color_luminosity > 1)
		. = 1 / largest_color_luminosity

	#if LIGHTING_SOFT_THRESHOLD != 0
	else if (largest_color_luminosity < LIGHTING_SOFT_THRESHOLD)
		. = 0 // 0 means soft lighting.

	cache_r = round(lr * ., LIGHTING_ROUND_VALUE) || LIGHTING_SOFT_THRESHOLD
	cache_g = round(lg * ., LIGHTING_ROUND_VALUE) || LIGHTING_SOFT_THRESHOLD
	cache_b = round(lb * ., LIGHTING_ROUND_VALUE) || LIGHTING_SOFT_THRESHOLD
	#else
	cache_r = round(lr * ., LIGHTING_ROUND_VALUE)
	cache_g = round(lg * ., LIGHTING_ROUND_VALUE)
	cache_b = round(lb * ., LIGHTING_ROUND_VALUE)
	#endif

	src.largest_color_luminosity = round(largest_color_luminosity, LIGHTING_ROUND_VALUE)

	var/datum/lighting_object/lighting_object = master_NE?.lighting_object
	if (lighting_object && !lighting_object.needs_update)
		lighting_object.needs_update = TRUE
		SSlighting.objects_queue += lighting_object

	lighting_object = master_SE?.lighting_object
	if (lighting_object && !lighting_object.needs_update)
		lighting_object.needs_update = TRUE
		SSlighting.objects_queue += lighting_object

	lighting_object = master_SW?.lighting_object
	if (lighting_object && !lighting_object.needs_update)
		lighting_object.needs_update = TRUE
		SSlighting.objects_queue += lighting_object

	lighting_object = master_NW?.lighting_object
	if (lighting_object && !lighting_object.needs_update)
		lighting_object.needs_update = TRUE
		SSlighting.objects_queue += lighting_object

/datum/lighting_corner/dummy/New()
	return

/datum/lighting_corner/Destroy(force)
	//Welcome back soulful PJB comment.
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("Ok, Look, TG, I need you to find whatever fucker decided to call qdel on a fucking lighting corner, \
	then tell him very nicely and politely that he is 100% retarded and needs his head checked. Thanks. Send them my regards by the way.")
	return QDEL_HINT_LETMELIVE

#undef UPDATE_ABOVE_LUM
#undef UPDATE_SUM_LUM
