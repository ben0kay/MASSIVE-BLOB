/// @description Draws all living enemy blobs.
if (!initialized)
    exit;

draw_set_alpha(1);
draw_set_color(make_color_rgb(235, 50, 65));

for (var _i = 0; _i < count; _i++)
{
    if (!blob_alive[_i])
        continue;

    draw_circle(blob_x[_i], blob_y[_i], BLOB_RADIUS, false);
}

draw_set_color(c_white);