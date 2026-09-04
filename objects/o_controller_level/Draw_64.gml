/// @description Draws level test statistics.
if (!initialized)
    exit;

draw_set_alpha(1);
draw_set_color(c_white);

draw_text(24, 24, "MASS BLOB FLOW TEST");
draw_text(24, 48, "Blobs: " + string(blob_system.count));
draw_text(24, 72, "FPS: " + string(fps_real));
draw_text(24, 96, "Flow cells: " + string(flow_cols * flow_rows));