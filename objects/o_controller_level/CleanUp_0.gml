/// @description Releases level-owned flow-field grids.
if (ds_exists(flow_wall, ds_type_grid))
    ds_grid_destroy(flow_wall);

if (ds_exists(flow_distance, ds_type_grid))
    ds_grid_destroy(flow_distance);

if (ds_exists(flow_direction, ds_type_grid))
    ds_grid_destroy(flow_direction);