/// @description Initializes every shared runtime-baked visual.
function sc_baking_init()
{
    if (variable_global_exists("baked_visuals"))
        sc_baking_destroy();

    global.baked_visuals = {
        blob: {
            enemy_basic: sc_baking_blob_create(16, BLOB_RADIUS)
        }
    };

    if (!sprite_exists(global.baked_visuals.blob.enemy_basic))
    {
        show_debug_message("BAKING INITIALIZATION FAILED - enemy_basic");
        return false;
    }

    show_debug_message("BAKING INITIALIZED");
    return true;
}

/// @description Bakes the neutral basic blob primitive into one shared sprite.
function sc_baking_blob_create(_canvas_size, _radius)
{
    if (_canvas_size <= 0 || _radius <= 0)
    {
        show_debug_message("BLOB BAKE ERROR - INVALID SIZE");
        return -1;
    }

    var _surface = surface_create(_canvas_size, _canvas_size);

    if (!surface_exists(_surface))
    {
        show_debug_message("BLOB BAKE ERROR - SURFACE CREATION FAILED");
        return -1;
    }

    var _centre = _canvas_size * 0.5;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    // Soft outer glow.
    draw_set_colour(c_white);
    draw_set_alpha(0.08);
    draw_circle(_centre, _centre, _radius + 2, false);

    draw_set_alpha(0.16);
    draw_circle(_centre, _centre, _radius + 1, false);

    // Main body.
    draw_set_colour(make_colour_rgb(185, 185, 185));
    draw_set_alpha(1);
    draw_circle(_centre, _centre, _radius, false);

    // Brighter interior gives the blob some primitive depth.
    draw_set_colour(c_white);
    draw_set_alpha(0.7);
    draw_circle(_centre - 1, _centre - 1, _radius - 2, false);

    // Small highlight.
    draw_set_alpha(0.85);
    draw_circle(_centre - 2, _centre - 2, 1, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0,
        0,
        _canvas_size,
        _canvas_size,
        false,
        false,
        _centre,
        _centre
    );

    surface_free(_surface);

    if (!sprite_exists(_sprite))
    {
        show_debug_message("BLOB BAKE ERROR - SPRITE CREATION FAILED");
        return -1;
    }

    show_debug_message(
        "BLOB VISUAL BAKED - " +
        string(_canvas_size) + "x" +
        string(_canvas_size)
    );

    return _sprite;
}

/// @description Returns one shared baked blob sprite.
function sc_baking_blob_get(_key)
{
    if (!variable_global_exists("baked_visuals"))
        return -1;

    if (!variable_struct_exists(global.baked_visuals, "blob"))
        return -1;

    if (!variable_struct_exists(global.baked_visuals.blob, _key))
        return -1;

    return variable_struct_get(global.baked_visuals.blob, _key);
}

/// @description Deletes all runtime-created baked sprites.
function sc_baking_destroy()
{
    if (!variable_global_exists("baked_visuals"))
        return;

    if (variable_struct_exists(global.baked_visuals, "blob"))
    {
        var _keys = variable_struct_get_names(global.baked_visuals.blob);

        for (var _i = 0; _i < array_length(_keys); _i++)
        {
            var _sprite = variable_struct_get(
                global.baked_visuals.blob,
                _keys[_i]
            );

            if (sprite_exists(_sprite))
                sprite_delete(_sprite);
        }
    }

    global.baked_visuals = {};
    show_debug_message("BAKING DESTROYED");
}