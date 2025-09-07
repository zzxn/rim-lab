extends Node

var game_controller: GameController


enum Terrain {
	Base = 0,
	Dirt = 1,
	Grass = 2,
	Water = 3,
}

var M := 32.0  # 1m = 32 pixel
