/// @function sc_blob_system_initialize(_system, _level, _capacity)
/// @description Initializes the array-driven blob system and caches shared resources.
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

    // Cache the baked sprite once instead of looking it up every Draw Event.
    _system.sprite_enemy_basic = sc_baking_blob_get("enemy_basic");

    if (!sprite_exists(_system.sprite_enemy_basic))
    {
        show_debug_message("BLOB SYSTEM ERROR - ENEMY SPRITE MISSING");
        return false;
    }

    _system.initialized = true;
    show_debug_message("BLOB SYSTEM INITIALIZED - CAPACITY " + string(_capacity));
    return true;
}

/// @function sc_blob_add(_system, _x, _y)
function sc_blob_add(_system, _x, _y)
{
    if (_system.count >= _system.capacity)
    {
        show_debug_message("BLOB ADD FAILED - CAPACITY REACHED");
        return -1;
    }

    var _id = _system.count;
    _system.count++;

    _system.blob_x[_id] = _x;
    _system.blob_y[_id] = _y;
    _system.blob_vx[_id] = 0;
    _system.blob_vy[_id] = 0;
    _system.blob_hp[_id] = 100;
    _system.blob_speed[_id] = random_range(1.15, 1.35);
    _system.blob_alive[_id] = true;

    return _id;
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