enum GameState
{
    BOOT,
    MENU,
    PLAYING
}

enum FlowDirection
{
    NONE,
    RIGHT,
    DOWN,
    LEFT,
    UP
}

#macro FLOW_CELL_SIZE 16
#macro BLOB_RADIUS 5
#macro GAME_TICK global.game.tick
#macro BLOB_UPDATE_RATE 2
#macro BLOB_GRID_CELL_SIZE 32
#macro BLOB_GRID_UPDATE_RATE 2