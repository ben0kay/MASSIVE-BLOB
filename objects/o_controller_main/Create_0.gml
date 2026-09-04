/// @description Initializes the project, baked visuals and first level.
if (instance_number(o_controller_main) > 1)
{
    instance_destroy();
    exit;
}

persistent = true;
randomize();

global.game = {
    initialized: false,
    state: GameState.BOOT,
    tick: 0
};

if (!sc_baking_init())
{
    show_debug_message("GAME INITIALIZATION FAILED - BAKING");
    exit;
}

global.game.initialized = true;
global.game.state = GameState.PLAYING;

show_debug_message("GAME INITIALIZED");
room_goto(r_flow_test);