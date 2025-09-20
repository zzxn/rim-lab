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


var TerrainCell = {
	Terrain.Base: [0, Vector2i(8, 24)],
	Terrain.Dirt: [0, Vector2i(6, 3)],
	Terrain.Grass: [0, Vector2i(0, 0)],
	Terrain.Water: [0, Vector2i(6, 16)],
}
