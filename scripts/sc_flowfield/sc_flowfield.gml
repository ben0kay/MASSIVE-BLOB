/// @function sc_flow_build(_level, _target_x, _target_y)
/// @description Builds a shared flow field around o_solid walls.
function sc_flow_build(_level, _target_x, _target_y)
{
    var _cols = _level.flow_cols;
    var _rows = _level.flow_rows;
    var _cell = _level.flow_cell;

    ds_grid_clear(_level.flow_wall, 0);
    ds_grid_clear(_level.flow_distance, -1);
    ds_grid_clear(_level.flow_direction, FlowDirection.NONE);

    // Mark cells occupied by walls.
    for (var _cy = 0; _cy < _rows; _cy++)
    {
        for (var _cx = 0; _cx < _cols; _cx++)
        {
            var _left = _cx * _cell;
            var _top = _cy * _cell;
            var _right = _left + _cell - 1;
            var _bottom = _top + _cell - 1;

            if (collision_rectangle(_left, _top, _right, _bottom, o_solid, false, true) != noone)
                _level.flow_wall[# _cx, _cy] = 1;
        }
    }

    var _target_cx = clamp(floor(_target_x / _cell), 0, _cols - 1);
    var _target_cy = clamp(floor(_target_y / _cell), 0, _rows - 1);

    var _maximum = _cols * _rows;
    var _queue_x = array_create(_maximum, 0);
    var _queue_y = array_create(_maximum, 0);
    var _queue_read = 0;
    var _queue_write = 0;

    _queue_x[_queue_write] = _target_cx;
    _queue_y[_queue_write] = _target_cy;
    _queue_write++;

    _level.flow_distance[# _target_cx, _target_cy] = 0;

    while (_queue_read < _queue_write)
    {
        var _cx = _queue_x[_queue_read];
        var _cy = _queue_y[_queue_read];
        var _distance = _level.flow_distance[# _cx, _cy] + 1;
        _queue_read++;

        // Cell left of us must move right.
        if (_cx > 0 &&
            _level.flow_wall[# _cx - 1, _cy] == 0 &&
            _level.flow_distance[# _cx - 1, _cy] < 0)
        {
            _level.flow_distance[# _cx - 1, _cy] = _distance;
            _level.flow_direction[# _cx - 1, _cy] = FlowDirection.RIGHT;
            _queue_x[_queue_write] = _cx - 1;
            _queue_y[_queue_write] = _cy;
            _queue_write++;
        }

        // Cell right of us must move left.
        if (_cx < _cols - 1 &&
            _level.flow_wall[# _cx + 1, _cy] == 0 &&
            _level.flow_distance[# _cx + 1, _cy] < 0)
        {
            _level.flow_distance[# _cx + 1, _cy] = _distance;
            _level.flow_direction[# _cx + 1, _cy] = FlowDirection.LEFT;
            _queue_x[_queue_write] = _cx + 1;
            _queue_y[_queue_write] = _cy;
            _queue_write++;
        }

        // Cell above us must move down.
        if (_cy > 0 &&
            _level.flow_wall[# _cx, _cy - 1] == 0 &&
            _level.flow_distance[# _cx, _cy - 1] < 0)
        {
            _level.flow_distance[# _cx, _cy - 1] = _distance;
            _level.flow_direction[# _cx, _cy - 1] = FlowDirection.DOWN;
            _queue_x[_queue_write] = _cx;
            _queue_y[_queue_write] = _cy - 1;
            _queue_write++;
        }

        // Cell below us must move up.
        if (_cy < _rows - 1 &&
            _level.flow_wall[# _cx, _cy + 1] == 0 &&
            _level.flow_distance[# _cx, _cy + 1] < 0)
        {
            _level.flow_distance[# _cx, _cy + 1] = _distance;
            _level.flow_direction[# _cx, _cy + 1] = FlowDirection.UP;
            _queue_x[_queue_write] = _cx;
            _queue_y[_queue_write] = _cy + 1;
            _queue_write++;
        }
    }

    show_debug_message("FLOW FIELD BUILT - " + string(_queue_write) + " REACHABLE CELLS");
}