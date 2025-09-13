extends Node

var game_controller: GameController


enum Terrain {
	Base = 0,
	Dirt = 1,
	Grass = 2,
	Water = 3,
}

const M = 32.0  # 1m = 32 pixel
const MAX_PLAYER_POS = 8000 * M # 256000
