shader_type spatial;

uniform vec4 tip_col : source_color;
uniform float tip_height;
uniform vec4 steep_col : source_color;
uniform float steepness_threshold;
uniform vec4 flat_col : source_color;
uniform vec4 deep_col : source_color;
uniform float deepness_threshold;

float huh(vec3 a, vec3 b)
{
	//return acos(((a.x*b.x)+(a.y*b.y)*(a.z*b.z))/(sqrt((a.x*a.x)+(a.y*a.y)+(a.z*a.z))*sqrt((b.x*b.x)+(b.y*b.y)+(b.z*b.z))));
	return acos((length(a)*length(b))/(length(normalize(a))*length(normalize(b))));
}

void vertex()
{
	if (VERTEX.y > tip_height)
	{
		 //tip_col.rgb;
	}
	else if (1.0f-dot(NORMAL, vec3(0,1,0)) > steepness_threshold)
	{
		NORMAL = steep_col.rgb;
	}
	else
	{
		NORMAL = flat_col.rgb;
	}
}

void fragment() {
}
