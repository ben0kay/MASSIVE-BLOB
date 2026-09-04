/// @description Draws a simple test wall.
draw_set_alpha(1);
draw_set_color(make_color_rgb(45, 52, 64));
draw_self();

draw_set_color(make_color_rgb(90, 110, 130));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);