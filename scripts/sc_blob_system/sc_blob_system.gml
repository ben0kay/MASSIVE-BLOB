/// @function sc_blob_system_initialize(_system, _level, _capacity)
function sc_blob_system_initialize(_system, _level, _capacity)
{
    _system.initialized = true;
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

/// @function sc_blob_system_update(_system)
function sc_blob_system_update(_system)
{
    var _level = _system.level;
    var _cell = _level.flow_cell;
    var _cols = _level.flow_cols;
    var _rows = _level.flow_rows;

    for (var _i = 0; _i < _system.count; _i++)
    {
        if (!_system.blob_alive[_i])
            continue;

        var _x = _system.blob_x[_i];
        var _y = _system.blob_y[_i];
        var _cx = floor(_x / _cell);
        var _cy = floor(_y / _cell);

        if (_cx < 0 || _cy < 0 || _cx >= _cols || _cy >= _rows)
            continue;

        var _direction = _level.flow_direction[# _cx, _cy];
        var _target_vx = 0;
        var _target_vy = 0;
        var _speed = _system.blob_speed[_i];

        switch (_direction)
        {
            case FlowDirection.RIGHT: _target_vx =  _speed; break;
            case FlowDirection.DOWN:  _target_vy =  _speed; break;
            case FlowDirection.LEFT:  _target_vx = -_speed; break;
            case FlowDirection.UP:    _target_vy = -_speed; break;
        }

        _system.blob_vx[_i] = lerp(_system.blob_vx[_i], _target_vx, 0.18);
        _system.blob_vy[_i] = lerp(_system.blob_vy[_i], _target_vy, 0.18);

        var _next_x = _x + _system.blob_vx[_i];
        var _next_y = _y + _system.blob_vy[_i];

        // Safety collision against solid walls.
        if (!position_meeting(_next_x, _y, o_solid))
            _x = _next_x;
        else
            _system.blob_vx[_i] = 0;

        if (!position_meeting(_x, _next_y, o_solid))
            _y = _next_y;
        else
            _system.blob_vy[_i] = 0;

        _system.blob_x[_i] = _x;
        _system.blob_y[_i] = _y;
    }
}