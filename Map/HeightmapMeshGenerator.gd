extends MeshInstance3D

enum resolution
{
	FULL_RES = 1,
	HALF_RES = 2,
	QUARTER_RES = 4,
}

@export var heightmap: Texture2D = null
@export var map_scale: Vector3 = Vector3(1, 10, 1)
@export var resolution_scale: resolution = 1
@export var tip_color: Color = Color(Color.SNOW)
@export var tip_height: float
@export var tip_transition: float = 1
@export var steep_color: Color = Color(Color.GRAY)
@export var steepness_threshhold: float
@export var steep_transition: float = 1.5
@export var flat_color: Color = Color(Color.DARK_GREEN)
@export var save_map:bool = false

var img: Image
var verticies: PackedVector3Array = PackedVector3Array()
var normals: PackedVector3Array = PackedVector3Array()
var colors: PackedColorArray = PackedColorArray()

func appendVertex(pos: Vector2i)->float:
	var vertex: Vector3 = Vector3.ZERO
	
	pos *= resolution_scale
	if pos.x >= img.get_width():
		pos.x=img.get_width()-1
	if pos.y >= img.get_height():
		pos.y=img.get_height()-1
	
	var col: Color = img.get_pixel(pos.x, pos.y)
	var px_val: float = col.r + col.b + col.g
	var y_val: float = px_val*map_scale.y
	vertex = Vector3(pos.x*map_scale.x, y_val, pos.y*map_scale.z)
	verticies.push_back(vertex)
	
	#var normal: Vector3 = vertex.normalized()
	#normals.push_back(normal)
	
	#var v_col: Color = flat_color
	
	#var mix: Color = steep_color
	#var steepness: float = 1-normal.dot(Vector3.UP)
	#mix.a = steepness/0.6#clamp((steepness/steepness_threshhold), 0.0, 1.0)
	#v_col = v_col.blend(mix)
	
	#var mix: Color = tip_color
	#mix.a = clamp((px_val-tip_height)*tip_transition, 0.0, 1.0)
	#v_col = v_col.blend(mix)
	
	#colors.push_back(v_col)
	return y_val

func appendTriangle(v1: Vector2, v2: Vector2, v3: Vector2)->void:
	var y = []
	y.push_back(appendVertex(v1))
	y.push_back(appendVertex(v2))
	y.push_back(appendVertex(v3))
	
	var a: Vector3 = Vector3(v1.x*map_scale.y, y[0], v1.y*map_scale.z)
	var b: Vector3 = Vector3(v2.x*map_scale.y, y[1], v2.y*map_scale.z)
	var c: Vector3 = Vector3(v3.x*map_scale.y, y[2], v3.y*map_scale.z)
	
	var v: Vector3 = b-a
	var u: Vector3 = c-a
	
	var normal: Vector3 #= (a-c).cross(b-c).normalized()
	
	normal.x = (u.y*v.z)-(u.z*v.y)
	normal.y = (u.z*v.x)-(u.x*v.z)
	normal.z = (u.x*v.y)-(u.y*v.x)
	
	normal = normal.normalized()
	
	normals.push_back(normal)
	normals.push_back(normal)
	normals.push_back(normal)

func paintVertexColors()->void:
	for i in range(verticies.size()):
		var col: Color = flat_color
		var mix: Color
		
		mix = steep_color
		var steepness: float = 1-abs(normals[i]).dot(Vector3.UP)
		#print(steepness)
		mix.a = (steepness/steepness_threshhold)
		col = col.blend(mix)
		
		mix = tip_color
		mix.a = clamp(((verticies[i].y/map_scale.y)-tip_height)*tip_transition, 0.0, 1.0)
		col = col.blend(mix)
		
		colors.push_back(col)

func createPackedVector3Array()->void:
	var map_size: Vector2 = Vector2(img.get_width(), img.get_height())
	map_size /= 2
	map_size = Vector2(floor(map_size.x), floor(map_size.y))
	map_size *=2
	
	for x in range(map_size.x/resolution_scale):
		for y in range(map_size.y/resolution_scale):
			var offset: int = resolution_scale
			appendTriangle(Vector2i(x*resolution_scale, y*resolution_scale),
					Vector2i(x*resolution_scale+offset, y*resolution_scale),
					Vector2i(x*resolution_scale, y*resolution_scale+offset))
			
			appendTriangle(Vector2i(x*resolution_scale+offset, y*resolution_scale),
					Vector2i(x*resolution_scale+offset, y*resolution_scale+offset),
					Vector2i(x*resolution_scale, y*resolution_scale+offset))
			
			#verticies.push_back(getVertexPosition(img, Vector2i(x*2, y*2)))
			#verticies.push_back(getVertexPosition(img, Vector2i((x*2)+1, y*2)))
			#verticies.push_back(getVertexPosition(img, Vector2i(x*2, (y*2)+1)))
			
			#verticies.push_back(getVertexPosition(img, Vector2i((x*2)+1, (y*2)+1)))
			#verticies.push_back(getVertexPosition(img, Vector2i((x*2)+1, y*2)))
			#verticies.push_back(getVertexPosition(img, Vector2i(x*2, (y*2)+1)))

func createArrayMesh()->ArrayMesh:
	img = heightmap.get_image()
	createPackedVector3Array()
	#var verticies: PackedVector3Array = PackedVector3Array()

	var hmesh: ArrayMesh = ArrayMesh.new()
	
	paintVertexColors()
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_VERTEX] = verticies
	arrays[Mesh.ARRAY_COLOR] = colors
	
	hmesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return hmesh

func _ready():
	if heightmap == null:
		print("Heightmap cannot be null!")
		return
	var am: ArrayMesh = createArrayMesh()
	self.mesh = am
	
	self.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	if save_map:
		ResourceSaver.save("res://map/testMap.tres", self.mesh)

func _process(_delta):
	pass
