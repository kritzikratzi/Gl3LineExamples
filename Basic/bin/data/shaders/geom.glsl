#version 150
layout(lines_adjacency) in;
layout(triangle_strip, max_vertices=9) out;

uniform mat4 modelViewProjectionMatrix;
uniform float thickness;

in Vertex{
	vec4 color;
	vec4 pos;
} vertex[];


out vec4 vertex_color;
#define PI 3.1415926535897932384626433832795
#define TWO_PI 6.283185307179586476925286766559

void emitV( vec2 v, vec4 color ){
	gl_Position = modelViewProjectionMatrix * vec4(v,0,1);
	vertex_color = color;
	EmitVertex();
}

// keep an angle between -pi and +pi
// otherwise taking half the angle becomes awkward
float goodRad( float rad ){
	return mod(mod(rad+PI,TWO_PI)+TWO_PI,TWO_PI)-PI;
}

void main(){

	vec2 a = vertex[0].pos.xy;
	vec2 b = vertex[1].pos.xy;
	vec2 c = vertex[2].pos.xy;
	vec2 d = vertex[3].pos.xy;

	vec2 ba = b - a;
	vec2 cb = c - b;
	vec2 cd = d - c;
	
	float width = thickness;
	float len = length(cb);
	
	if( len > 0 ){
		// do things for a,b,c
		float alpha1 = 0.5 * goodRad(atan(ba.y, ba.x) - atan(cb.y, cb.x));
		
		float sa = sin(alpha1);
		float ca = cos(alpha1);

		// rotation matrix + compute normal
		mat2 rot = mat2(ca, sa, -sa, ca);
		vec2 b1 = b + rot * vec2(-cb.y, cb.x) * width / len;
		vec2 b2 = b + rot * vec2(cb.y, -cb.x) * width / len;
		
		// and for b,c,d
		float alpha2 = 0.5 * goodRad(atan(cd.y, cd.x) - atan(cb.y, cb.x));

		sa = sin(alpha2);
		ca = cos(alpha2);

		// rotation matrix + compute normal
		rot = mat2(ca, sa, -sa, ca);
		vec2 c1 = c + rot * vec2(-cb.y, cb.x) * width / len;
		vec2 c2 = c + rot * vec2(cb.y, -cb.x) * width / len;

		emitV( b1, vertex[1].color);
		emitV( c1, vertex[2].color);
		emitV( b2, vertex[1].color);
		emitV( c2, vertex[2].color);
	}
}