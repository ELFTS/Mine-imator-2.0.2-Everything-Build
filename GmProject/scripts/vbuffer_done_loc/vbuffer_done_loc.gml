/// vbuffer_done_loc([vbuffer])
/// @arg [vbuffer]

function vbuffer_done_loc()
{
	var vbuffer = vbuffer_current_loc;
	if (argument_count > 0)
		vbuffer_current_loc = argument[0]
	
	vertex_end(vbuffer)
	vbuffer = vbuffer_generate_tangents(vbuffer)
	vertex_freeze(vbuffer)
	
	return vbuffer
}
