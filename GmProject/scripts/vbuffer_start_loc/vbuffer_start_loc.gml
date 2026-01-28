/// vbuffer_start_loc()

function vbuffer_start_loc()
{
	vbuffer_current_loc = vertex_create_buffer()
	vertex_begin(vbuffer_current_loc, vertex_format_loc)
	
	if (!is_cpp())
		repeat (3) // Workaround vertex error
			vertex_add_loc(0, 0, 0, 0, 0, 0, 0, 0)
	
	return vbuffer_current_loc
}
