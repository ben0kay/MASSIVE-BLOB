/// @description Builds and starts the flow-field test.
initialized = false;

flow_cell = FLOW_CELL_SIZE;
flow_cols = ceil(room_width / flow_cell);
flow_rows = ceil(room_height / flow_cell);

flow_wall = ds_grid_create(flow_cols, flow_rows);
flow_distance = ds_grid_create(flow_cols, flow_rows);
flow_direction = ds_grid_create(flow_cols, flow_rows);

var _base = instance_find(o_base, 0);

if (_base == noone)
{
    show_debug_message("LEVEL ERROR - NO o_base INSTANCE FOUND");
    exit;
}

sc_flow_build(id, _base.x, _base.y);

blob_system = instance_create_layer(0, 0, "Instances", o_blob_system);
sc_blob_system_initialize(blob_system, id, 5000);

// Spawn an orderly red army near the left side.
var _columns = 50;
var _rows = 30;
var _spacing = 12;
var _start_x = 80;
var _start_y = 220;

for (var _row = 0; _row < _rows; _row++)
{
    for (var _column = 0; _column < _columns; _column++)
    {
        var _x = _start_x + (_column * _spacing);
        var _y = _start_y + (_row * _spacing);

        if (!position_meeting(_x, _y, o_solid))
            sc_blob_add(blob_system, _x, _y);
    }
}

initialized = true;

show_debug_message(
    "FLOW TEST READY - " +
    string(blob_system.count) +
    " RED BLOBS"
);