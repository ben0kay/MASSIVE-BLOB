/// @function sc_blob_system_initialize(_system, _level, _capacity)
/// @description Initializes all array-driven blob simulation and spatial-grid data.
function sc_blob_system_initialize(_system, _level, _capacity)
{
    _system.initialized = false;
    _system.level = _level;
    _system.capacity = _capacity;
    _system.count = 0;

    _system.blob_x = array_create(_capacity, 0);
    _system.blob_y = array_create(_capacity, 0);
    _system.blob_vx = array_create(_capacity, 0);
    _system.blob_vy = array_create(_capacity, 0);
    _system.blob_hp = array_create(_capacity, 0);
    _system.blob_speed = array_create(_capacity, 0);
    _system.blob_alive = array_create(_capacity, false);

    var _grid_cols = ceil(room_width / BLOB_GRID_CELL_SIZE);
    var _grid_rows = ceil(room_height / BLOB_GRID_CELL_SIZE);
    var _grid_count = _grid_cols * _grid_rows;

    _system.grid = {
        cell: BLOB_GRID_CELL_SIZE,
        cols: _grid_cols,
        rows: _grid_rows,
        count: _grid_count,
        generation: 0,
        head: array_create(_grid_count, -1),
        stamp: array_create(_grid_count, -1),
        next: array_create(_capacity, -1),
        blob_cell: array_create(_capacity, -1),
        occupied_cells: 0,
        registered_blobs: 0
    };

    _system.sprite_enemy_basic = sc_baking_blob_get("enemy_basic");

    if (!sprite_exists(_system.sprite_enemy_basic))
    {
        show_debug_message("BLOB SYSTEM ERROR - ENEMY SPRITE MISSING");
        return false;
    }

    _system.initialized = true;
    show_debug_message("BLOB SYSTEM INITIALIZED - CAPACITY " + string(_capacity) + " / GRID " + string(_grid_cols) + "x" + string(_grid_rows));
    return true;
}

/// @function sc_blob_add(_system, _x, _y)
/// @description Adds one blob to the array-driven system.
function sc_blob_add(_system, _x, _y)
{
    if (_system.count >= _system.capacity)
    {
        show_debug_message("BLOB ADD FAILED - CAPACITY REACHED");
        return -1;
    }

    var _blob_id = _system.count++;
    _system.blob_x[_blob_id] = _x;
    _system.blob_y[_blob_id] = _y;
    _system.blob_vx[_blob_id] = 0;
    _system.blob_vy[_blob_id] = 0;
    _system.blob_hp[_blob_id] = 100;
    _system.blob_speed[_blob_id] = random_range(1.15, 1.35);
    _system.blob_alive[_blob_id] = true;
    return _blob_id;
}

/// @description Staggers blob simulation across frames while preserving movement speed.
function sc_blob_system_update(_system)
{
    var _level = _system.level;
    var _cell = _level.flow_cell;
    var _cols = _level.flow_cols;
    var _rows = _level.flow_rows;
    var _flow = _level.flow_direction;
    var _walls = _level.flow_wall;
    var _move_scale = BLOB_UPDATE_RATE;
    var _velocity_lerp = 1 - power(1 - 0.18, BLOB_UPDATE_RATE);

    for (var _i = 0; _i < _system.count; _i++)
    {
        if (((GAME_TICK + _i) mod BLOB_UPDATE_RATE) != 0) continue;
        if (!_system.blob_alive[_i]) continue;

        var _x = _system.blob_x[_i];
        var _y = _system.blob_y[_i];
        var _cx = floor(_x / _cell);
        var _cy = floor(_y / _cell);

        if (_cx < 0 || _cy < 0 || _cx >= _cols || _cy >= _rows) continue;

        var _speed = _system.blob_speed[_i];
        var _target_vx = 0;
        var _target_vy = 0;

        switch (_flow[# _cx, _cy])
        {
            case FlowDirection.RIGHT: _target_vx =  _speed; break;
            case FlowDirection.DOWN:  _target_vy =  _speed; break;
            case FlowDirection.LEFT:  _target_vx = -_speed; break;
            case FlowDirection.UP:    _target_vy = -_speed; break;
        }

        var _vx = lerp(_system.blob_vx[_i], _target_vx, _velocity_lerp);
        var _vy = lerp(_system.blob_vy[_i], _target_vy, _velocity_lerp);
        var _next_x = _x + (_vx * _move_scale);
        var _next_y = _y + (_vy * _move_scale);
        var _next_cx = floor(_next_x / _cell);

        if (_next_cx >= 0 && _next_cx < _cols && _walls[# _next_cx, _cy] == 0)
            _x = _next_x;
        else
            _vx = 0;

        _cx = floor(_x / _cell);
        var _next_cy = floor(_next_y / _cell);

        if (_next_cy >= 0 && _next_cy < _rows && _walls[# _cx, _next_cy] == 0)
            _y = _next_y;
        else
            _vy = 0;

        _system.blob_x[_i] = _x;
        _system.blob_y[_i] = _y;
        _system.blob_vx[_i] = _vx;
        _system.blob_vy[_i] = _vy;
    }
}

/// @description Rebuilds current blob occupancy using array-based linked lists.
function sc_blob_grid_rebuild(_system)
{
    var _grid = _system.grid;
    var _generation = _grid.generation + 1;
    var _cell = _grid.cell;
    var _cols = _grid.cols;
    var _rows = _grid.rows;
    var _occupied = 0;
    var _registered = 0;

    for (var _i = 0; _i < _system.count; _i++)
    {
        _grid.next[_i] = -1;
        _grid.blob_cell[_i] = -1;

        if (!_system.blob_alive[_i]) continue;

        var _cx = floor(_system.blob_x[_i] / _cell);
        var _cy = floor(_system.blob_y[_i] / _cell);

        if (_cx < 0 || _cy < 0 || _cx >= _cols || _cy >= _rows) continue;

        var _cell_index = _cx + (_cy * _cols);

        if (_grid.stamp[_cell_index] != _generation)
        {
            _grid.stamp[_cell_index] = _generation;
            _grid.head[_cell_index] = -1;
            _occupied++;
        }

        _grid.next[_i] = _grid.head[_cell_index];
        _grid.head[_cell_index] = _i;
        _grid.blob_cell[_i] = _cell_index;
        _registered++;
    }

    _grid.generation = _generation;
    _grid.occupied_cells = _occupied;
    _grid.registered_blobs = _registered;
}

/// @description Counts blobs inside a radius by searching intersecting grid cells only.
function sc_blob_grid_count_radius(_system, _x, _y, _radius)
{
    var _grid = _system.grid;
    var _cell = _grid.cell;
    var _cols = _grid.cols;
    var _rows = _grid.rows;
    var _generation = _grid.generation;
    var _radius_sq = _radius * _radius;
    var _min_cx = max(0, floor((_x - _radius) / _cell));
    var _max_cx = min(_cols - 1, floor((_x + _radius) / _cell));
    var _min_cy = max(0, floor((_y - _radius) / _cell));
    var _max_cy = min(_rows - 1, floor((_y + _radius) / _cell));
    var _found = 0;

    for (var _cy = _min_cy; _cy <= _max_cy; _cy++)
    {
        for (var _cx = _min_cx; _cx <= _max_cx; _cx++)
        {
            var _cell_index = _cx + (_cy * _cols);
            if (_grid.stamp[_cell_index] != _generation) continue;

            var _blob_id = _grid.head[_cell_index];

            while (_blob_id != -1)
            {
                var _dx = _system.blob_x[_blob_id] - _x;
                var _dy = _system.blob_y[_blob_id] - _y;

                if ((_dx * _dx) + (_dy * _dy) <= _radius_sq) _found++;
                _blob_id = _grid.next[_blob_id];
            }
        }
    }

    return _found;
}