/// @description Initializes the project and enters the test level.

persistent = true;

randomize();

global.game = {
    initialized: true,
    state: GameState.BOOT,
    tick: 0
};

global.game.state = GameState.PLAYING;
room_goto(r_flow_test);