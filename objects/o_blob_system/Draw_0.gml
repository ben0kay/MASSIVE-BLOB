/// @description Draws every living blob using one shared baked sprite.
if (!initialized)
    exit;

var _sprite = sprite_enemy_basic;

if (!sprite_exists(_sprite))
{
    draw_set_colour(c_red);

    for (var _i = 0; _i < count; _i++)
    {
        if (blob_alive[_i])
            draw_circle(blob_x[_i], blob_y[_i], BLOB_RADIUS, false);
    }

    draw_set_colour(c_white);
    exit;
}

var _colour = make_colour_rgb(235, 50, 65);

for (var _i = 0; _i < count; _i++)
{
    if (!blob_alive[_i])
        continue;

    draw_sprite_ext(
        _sprite,
        0,
        blob_x[_i],
        blob_y[_i],
        1,
        1,
        0,
        _colour,
        1
    );
}

draw_set_alpha(1);
draw_set_colour(c_white);