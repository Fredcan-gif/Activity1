extends ParallaxBackground

@onready var sky: ParallaxLayer = $ParallaxLayer
@onready var grass: ParallaxLayer = $ParallaxLayer2
@onready var sky2: ParallaxLayer = $ParallaxLayer4
@onready var grass2: ParallaxLayer = $ParallaxLayer3
@onready var grass3: ParallaxLayer = $ParallaxLayer6
@onready var sky3: ParallaxLayer = $ParallaxLayer5
@onready var grass4: ParallaxLayer = $ParallaxLayer8


@export var skySpeed = 0.1
@export var grassSpeed = 0.3
@export var sky2Speed = 0.1
@export var grass2Speed = 0.3
@export var sky3Speed = 0.1
@export var grass3Speed = 0.3
@export var grass4Speed = 0.3

func _process(delta: float) -> void:
	sky.motion_offset -= Vector2(skySpeed,0)
	grass.motion_offset -= Vector2(grassSpeed,0)
	sky2.motion_offset -= Vector2(sky2Speed,0)
	grass2.motion_offset -= Vector2(grass2Speed,0)
	sky3.motion_offset -= Vector2(sky3Speed,0)
	grass3.motion_offset -= Vector2(grass3Speed,0)
	grass4.motion_offset -= Vector2(grass4Speed,0)
