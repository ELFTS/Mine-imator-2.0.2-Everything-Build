/// render_world_tl_shadow()
/// @desc Renders the 3D model of the timeline instance for shadowpass.

function render_world_tl_shadow()
{
	// No 3D representation?
	if (type = e_tl_type.CHARACTER ||
		type = e_tl_type.SPECIAL_BLOCK ||
		type = e_tl_type.FOLDER ||
		type = e_tl_type.BACKGROUND ||
		type = e_tl_type.AUDIO ||
		type = e_tl_type.PATH_POINT ||
		type = e_tl_type.SPOT_LIGHT ||
		type = e_tl_type.POINT_LIGHT ||
		type = e_tl_type.CAMERA)
		return 0
	
	if (type = e_tl_type.MODEL && (temp.model = null || temp.model.model_format = e_model_format.MIMODEL))
		return 0
	
	if (!app.place_tl_render && (placed || parent_is_placed))
		return 0
	
	// Invisible?
	if (!render_visible) 
		return 0
	
	// Not registered on shadow depth testing?
	if (!shadows && (render_mode = e_render_mode.HIGH_LIGHT_SUN_DEPTH ||
		 render_mode = e_render_mode.HIGH_LIGHT_SPOT_DEPTH ||
		 render_mode = e_render_mode.HIGH_LIGHT_POINT_DEPTH))
		return 0
		
	if ((value_inherit[e_value.ALPHA]) = 0)
		return 0
	
	if (depth_ignore)
		return 0
		
	if (app.project_render_performance_mode && (render_mode = e_render_mode.HIGH_LIGHT_POINT_DEPTH || render_mode = e_render_mode.HIGH_LIGHT_SPOT_DEPTH) && point3D_distance(render_light_from, world_pos) > render_light_far + (16 * max(value[e_value.SCA_X], value[e_value.SCA_Y], value[e_value.SCA_Z])) + app.project_render_performance_mode_light_occlusion_distance && type != e_tl_type.SCENERY)
		return 0
	
	// Only render glow effect?
	if ((glow && only_render_glow))
		return 0
	
	/*
	// Ignore any depth test for volume mode
	if (volume_mode && !shadowpass && !shadowdepthpass)
		return 0
	*/
	
	// Set render options
	render_set_culling(!backfaces)
	shader_texture_filter_linear = texture_blur
	shader_texture_filter_mipmap = (app.project_render_texture_filtering && texture_filtering)
	
	// Light and Object Tags linking
	if (render_light_tl != null && string(render_light_tl.object_tag) != "Main" && 
		 string(object_tag) != string(render_light_tl.object_tag))
		render_set_uniform("uIgnore", true)
	else
		render_set_uniform("uIgnore", false)
	
	shader_blend_color = value_inherit[e_value.RGB_MUL]
	shader_blend_alpha = value_inherit[e_value.ALPHA]
	render_set_uniform_color("uBlendColor", shader_blend_color, shader_blend_alpha)
	
	if (!render_alpha_hash_force)
	{
		render_alpha_hash = (alpha_mode = e_alpha_mode.DEFAULT ? app.project_render_alpha_mode : alpha_mode)
		render_set_uniform_int("uAlphaHash", render_alpha_hash)
	}
	
	if (value_inherit[e_value.EMISSIVE] != shader_uniform_emissive)
	{
		shader_uniform_emissive = value_inherit[e_value.EMISSIVE]
		render_set_uniform("uEmissive", shader_uniform_emissive)
	}
	
	if (value_inherit[e_value.METALLIC] != shader_uniform_metallic)
	{
		shader_uniform_metallic = value_inherit[e_value.METALLIC]
		render_set_uniform("uMetallic", shader_uniform_metallic)
	}
	
	if (value_inherit[e_value.ROUGHNESS] != shader_uniform_roughness)
	{
		shader_uniform_roughness = value_inherit[e_value.ROUGHNESS]
		render_set_uniform("uRoughness", shader_uniform_roughness)
	}
	
	if (value_inherit[e_value.NORMAL_STRENGTH] != shader_uniform_normal_strength)
	{
		shader_uniform_normal_strength = value_inherit[e_value.NORMAL_STRENGTH]
		render_set_uniform("uNormalStrength", shader_uniform_normal_strength)
	}
	
	if (wind != shader_uniform_wind)
	{
		shader_uniform_wind = wind
		render_set_uniform("uWindEnable", shader_uniform_wind)
	}
	
	if (wind_terrain != shader_uniform_wind_terrain)
	{
		shader_uniform_wind_terrain = wind_terrain
		render_set_uniform("uWindTerrain", shader_uniform_wind_terrain)
	}
	
	if (value_inherit[e_value.SUBSURFACE] != shader_uniform_sss ||
		value_inherit[e_value.SUBSURFACE_RADIUS_RED] != shader_uniform_sss_red ||
		value_inherit[e_value.SUBSURFACE_RADIUS_GREEN] != shader_uniform_sss_green ||
		value_inherit[e_value.SUBSURFACE_RADIUS_BLUE] != shader_uniform_sss_blue ||
		value_inherit[e_value.SUBSURFACE_COLOR] != shader_uniform_sss_color)
	{
		shader_uniform_sss = value_inherit[e_value.SUBSURFACE]
		shader_uniform_sss_red = value_inherit[e_value.SUBSURFACE_RADIUS_RED]
		shader_uniform_sss_green = value_inherit[e_value.SUBSURFACE_RADIUS_GREEN]
		shader_uniform_sss_blue = value_inherit[e_value.SUBSURFACE_RADIUS_BLUE]
		shader_uniform_sss_color = value_inherit[e_value.SUBSURFACE_COLOR]
		
		render_set_uniform("uSSS", shader_uniform_sss)
		render_set_uniform_vec3("uSSSRadius", shader_uniform_sss_red, shader_uniform_sss_green, shader_uniform_sss_blue)
		render_set_uniform_color("uSSSColor", shader_uniform_sss_color, 1.0)
	}
	
	if (value_inherit[e_value.WIND_INFLUENCE] != shader_uniform_wind_strength)
	{
		shader_uniform_wind_strength = app.background_wind_strength * app.setting_wind_enable * value_inherit[e_value.WIND_INFLUENCE]
		render_set_uniform("uWindStrength", shader_uniform_wind_strength)
		render_set_uniform("uWindDirectionalStrength", shader_uniform_wind_strength * app.background_wind_directional_strength) 
	}
	
	// Render
	if (type != e_tl_type.PARTICLE_SPAWNER)
	{
		matrix_set(matrix_world, matrix_render)
		
		// Reset material textures for other timelines
		if (type != e_tl_type.SCENERY && type != e_tl_type.BLOCK)
		{
			render_set_texture(spr_default_material, "Material")
			render_set_texture(spr_default_normal, "Normal")
		}
		
		render_set_uniform_vec2("uTextureOffset", 0, 0)
		
		switch (type)
		{
			case e_tl_type.BODYPART:
			{
				if (model_part = null || render_res_diffuse = null)
					break
				
				render_world_model_part(model_part, render_res_diffuse, temp.model_texture_name_map, model_shape_vbuffer_map, temp.model_color_map, temp.model_shape_hide_list, temp.model_shape_texture_name_map, self)
				break
			}
			
			case e_tl_type.SCENERY:
			case e_tl_type.BLOCK:
			{
				if (type = e_tl_type.BLOCK)
					render_world_block(temp.block_vbuffer, [render_res_diffuse, render_res_material, render_res_normal], true, temp.block_repeat_enable ? temp.block_repeat : vec3(1), temp)
				else if (temp.scenery)
					render_world_scenery(temp.scenery, [render_res_diffuse, render_res_material, render_res_normal], temp.block_repeat_enable, temp.block_repeat)
				break
			}
			
			// case e_tl_type.OBJ:
			
			case e_tl_type.ITEM:
			{
				if (item_vbuffer = null)
					render_world_item(temp.item_vbuffer, temp.item_3d, temp.item_face_camera, temp.item_bounce, temp.item_spin, [item_res, item_material_res, item_normal_res])
				else
					render_world_item(item_vbuffer, temp.item_3d, temp.item_face_camera, temp.item_bounce, temp.item_spin, [item_res, item_material_res, item_normal_res])
				break
			}
			
			case e_tl_type.TEXT:
			{
				var font = value[e_value.TEXT_FONT];
				if (font = null)
					font = temp.text_font
				render_world_text(text_vbuffer, text_texture, temp.text_face_camera, text_res, value[e_value.TEXT_OUTLINE] ? value[e_value.TEXT_OUTLINE_COLOR] : null)
				break
			}
			
			case e_tl_type.MODEL:
			{
				if (temp.model != null)
				{
					var res = value_inherit[e_value.TEXTURE_OBJ];
					if (res = null)
						res = temp.model_tex
					if (res = null || res.block_sheet_texture = null)
						res = mc_res
					render_world_block(temp.model.block_vbuffer, res)
					
					with (temp)
						res = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
					render_world_block_map(temp.model.model_block_map, res)
				}
				break
			}
			
			case e_tl_type.PATH:
			{
				if (path_vbuffer != null)
				{
					var tex, texmat, texnorm;
					
					if (value_inherit[e_value.TEXTURE_OBJ] = null)
						tex = spr_shape
					else
						tex = value_inherit[e_value.TEXTURE_OBJ].texture
					
					if (value_inherit[e_value.TEXTURE_MATERIAL_OBJ] = null)
					{
						texmat = spr_default_material
						render_set_uniform_int("uMaterialFormat", e_material.FORMAT_NONE)
					}
					else
					{
						texmat = value_inherit[e_value.TEXTURE_MATERIAL_OBJ].texture
						render_set_uniform_int("uMaterialFormat", value_inherit[e_value.TEXTURE_MATERIAL_OBJ].material_format)
					}
					
					if (value_inherit[e_value.TEXTURE_NORMAL_OBJ] = null)
						texnorm = spr_default_normal
					else
						texnorm = value_inherit[e_value.TEXTURE_NORMAL_OBJ].texture
					
					render_set_texture(tex)
					render_set_texture(texmat, "Material")
					render_set_texture(texnorm, "Normal")
					
					vbuffer_render(path_vbuffer)
				}
				else if (render_mode = e_render_mode.CLICK)
				{
					render_set_texture(spr_shape)
					render_set_texture(spr_default_material, "Material")
					render_set_texture(spr_default_normal, "Normal")
					render_set_uniform_int("uMaterialFormat", e_material.FORMAT_NONE)
					
					vbuffer_render(path_select_vbuffer)
				}
				
				break
			}
			
			default: // Shapes
			{
				var tex, matres, texmat, normtex;
				with (temp)
				{
					tex = temp_get_shape_tex(temp_get_shape_texobj(other.value_inherit[e_value.TEXTURE_OBJ]))
					
					matres = temp_get_shape_tex_material_obj(other.value_inherit[e_value.TEXTURE_MATERIAL_OBJ])
					texmat = temp_get_shape_tex(matres, spr_default_material)
					normtex = temp_get_shape_tex(temp_get_shape_tex_normal_obj(other.value_inherit[e_value.TEXTURE_NORMAL_OBJ]), spr_default_normal)
					
					if (matres != null)
						render_set_uniform_int("uMaterialFormat", matres.material_format)
					else
						render_set_uniform_int("uMaterialFormat", e_material.FORMAT_NONE)
				}
				
				render_world_shape(temp.type, temp.shape_vbuffer, temp.shape_face_camera, [tex, texmat, normtex])
				break
			}
		}
	} 
	else if (render_particles) 
	{
		for (var p = 0; p < ds_list_size(particle_list); p++)
			with (particle_list[|p])
				render_world_particle()
	}
	
	matrix_world_reset()
	shader_texture_surface = false
}
