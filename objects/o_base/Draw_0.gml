/// @description Draws the blue player base.
draw_set_alpha(0.25);
draw_set_color(make_color_rgb(30, 120, 255));
draw_rectangle(
    x - base_width * 0.5,
    y - base_height * 0.5,
    x + base_width * 0.5,
    y + base_height * 0.5,
    false
);

draw_set_alpha(1);
draw_set_color(make_color_rgb(80, 190, 255));
draw_rectangle(
    x - base_width * 0.5,
    y - base_height * 0.5,
    x + base_width * 0.5,
    y + base_height * 0.5,
    true
);

draw_text(x - 34, y - 8, "BLUE BASE");