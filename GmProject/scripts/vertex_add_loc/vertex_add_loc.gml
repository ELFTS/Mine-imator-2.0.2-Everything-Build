/// vertex_add_loc(x, y, z, nx, ny, nz, tx, ty)
/// vertex_add_loc(pos, normal, texcoord)
/// @arg pos
/// @arg normal
/// @arg texcoord

function vertex_add_loc()
{
	var xx, yy, zz;
	
	if (argument_count < 8)
	{
		var pos, normal, texcoord;
		pos = argument[0]
		normal = vec3_normalize(argument[1])
		texcoord = argument[2]
		
		xx = pos[@ X]
		yy = pos[@ Y]
		zz = pos[@ Z]
		
		vertex_position_3d(vbuffer_current_loc, xx, yy, pos[@ Z])
		vertex_normal(vbuffer_current_loc, normal[@ X], normal[@ Y], normal[@ Z])
		vertex_color(vbuffer_current_loc, vertex_rgb_loc, vertex_alpha_loc)
		vertex_texcoord(vbuffer_current_loc, texcoord[@ X], texcoord[@ Y])
	}
	else
	{
		xx = argument[0]
		yy = argument[1]
		zz = argument[2]
		
		var normal = vec3_normalize([argument[3], argument[4], argument[5]]);
		
		vertex_position_3d(vbuffer_current_loc, xx, yy, zz)
		vertex_normal(vbuffer_current_loc, normal[X], normal[Y], normal[Z])
		vertex_color(vbuffer_current_loc, vertex_rgb_loc, vertex_alpha_loc)
		vertex_texcoord(vbuffer_current_loc, argument[6], argument[7])
	}
	
	var wavexy, wavez;
	wavexy = 0
	wavez = 0
	
	// Wind/custom values
	if (vertex_wave_loc != e_vertex_wave.NONE)
	{
		// Vertex Z must be within zmin and zmax (if set)
		if ((vertex_wave_zmin_loc = null || zz > vertex_wave_zmin_loc) &&
			(vertex_wave_zmax_loc = null || zz < vertex_wave_zmax_loc))
		{
			if (vertex_wave_loc = e_vertex_wave_loc.ALL)
			{
				wavexy = 1
				wavez = 1
			}
			else if (vertex_wave_loc = e_vertex_wave.Z_ONLY)
				wavez = 1
		}
		
		vertex_float4(vbuffer_current_loc, wavexy, wavez, vertex_emissive_loc, vertex_subsurface_loc)
	}
	else
		vertex_float4(vbuffer_current_loc, 0, 0, vertex_emissive_loc, vertex_subsurface_loc)
	
	vertex_float3(vbuffer_current_loc, 0, 0, 0)
}
