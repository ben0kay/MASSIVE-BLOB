/// @description Updates movement and periodically rebuilds spatial occupancy.
if (!initialized) exit;

sc_blob_system_update(id);

if ((GAME_TICK mod BLOB_GRID_UPDATE_RATE) == 0)
    sc_blob_grid_rebuild(id);