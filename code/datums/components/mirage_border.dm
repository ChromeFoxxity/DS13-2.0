/datum/component/mirage_border
	can_transfer = TRUE
	var/obj/effect/abstract/mirage_holder/holder

/datum/component/mirage_border/Initialize(turf/target, direction, range=world.view)
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	if(!target || !istype(target) || !direction)
		. = COMPONENT_INCOMPATIBLE
		CRASH("[type] improperly instanced with the following args: target=\[[target]\], direction=\[[direction]\], range=\[[range]\]")

	holder = new(parent)

	var/x = target.x
	var/y = target.y
	var/z = target.z
	var/turf/southwest = locate(clamp(x - (direction & WEST ? range : 0), 1, world.maxx), clamp(y - (direction & SOUTH ? range : 0), 1, world.maxy), clamp(z, 1, world.maxz))
	var/turf/northeast = locate(clamp(x + (direction & EAST ? range : 0), 1, world.maxx), clamp(y + (direction & NORTH ? range : 0), 1, world.maxy), clamp(z, 1, world.maxz))
	//holder.vis_contents += block(southwest, northeast) // This doesnt work because of beta bug memes
	for(var/i in block(southwest, northeast))
		holder.vis_contents += i
	if(direction & SOUTH)
		holder.pixel_y -= world.icon_size * range
	if(direction & WEST)
		holder.pixel_x -= world.icon_size * range

/datum/component/mirage_border/Destroy()
	QDEL_NULL(holder)
	return ..()

/datum/component/mirage_border/PreTransfer()
	holder.moveToNullspace()

/datum/component/mirage_border/PostTransfer()
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	holder.forceMove(parent)

INITIALIZE_IMMEDIATE(/obj/effect/abstract/mirage_holder)
/obj/effect/abstract/mirage_holder
	name = "Mirage holder"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/abstract/mirage_holder/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE
	return INITIALIZE_HINT_NORMAL

/obj/effect/abstract/mirage_holder/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	loc = null
	return QDEL_HINT_QUEUE
