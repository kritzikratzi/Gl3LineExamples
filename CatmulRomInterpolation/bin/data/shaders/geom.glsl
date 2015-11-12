#version 150
layout(lines_adjacency) in;
layout(triangle_strip, max_vertices=100) out;

uniform mat4 modelViewProjectionMatrix;
uniform float thickness;
// always keep N >= 4!!
uniform int N;

in Vertex{
	vec4 color;
	vec4 pos;
} vertex[];


out vec4 vertex_color;
#define PI 3.1415926535897932384626433832795
#define TWO_PI 6.283185307179586476925286766559

vec2 bezierPoint( vec2 a, vec2 b, vec2 c, vec2 d, float t );
void makeSegment( vec2 a, vec2 b, vec2 c, vec2 d );
float goodRad( float rad );
void emitV( vec2 v, vec4 color );

void main(){

	vec2 p0 = vertex[0].pos.xy;
	vec2 p1 = vertex[1].pos.xy;
	vec2 p2 = vertex[2].pos.xy;
	vec2 p3 = vertex[3].pos.xy;
	
	float d1 = distance( p0, p1 );
	float d2 = distance( p1, p2 );
	float d3 = distance( p2, p3 );
	
	// compute control/anchor points a, b, c, d for bezier curve
	float alpha = 0.5;
	
	vec2 a = p1;
	vec2 b = vec2(
				  (pow(d1, 2*alpha)*p2[0]-pow(d2, 2*alpha)*p0.x + (2 * pow(d1, 2*alpha) + 3*pow(d1*d2, alpha) + pow(d2, 2*alpha))*p1.x)  /  (3*pow(d1,alpha)*(pow(d1,alpha)+pow(d2,alpha))),
				  (pow(d1, 2*alpha)*p2.y-pow(d2, 2*alpha)*p0.y + (2 * pow(d1, 2*alpha) + 3*pow(d1*d2, alpha) + pow(d2, 2*alpha))*p1.y)  /  (3*pow(d1,alpha)*(pow(d1,alpha)+pow(d2,alpha)))
				  );
	vec2 c = vec2(
				  (pow(d3, 2*alpha)*p1.x-pow(d2, 2*alpha)*p3.x + (2 * pow(d3, 2*alpha) + 3*pow(d2*d3, alpha) + pow(d2, 2*alpha))*p2.x)  /  (3*pow(d3,alpha)*(pow(d3,alpha)+pow(d2,alpha))),
				  (pow(d3, 2*alpha)*p1.y-pow(d2, 2*alpha)*p3.y + (2 * pow(d3, 2*alpha) + 3*pow(d2*d3, alpha) + pow(d2, 2*alpha))*p2.y)  /  (3*pow(d3,alpha)*(pow(d3,alpha)+pow(d2,alpha)))
				 );
	vec2 d = p2;
	
	// first segment
	vertex_color = vec4( 1, 0, 0, 1 );
	vec2 A = 2*a-b;
	vec2 B = bezierPoint( a, b, c, d, (0)/float(N) );
	vec2 C = bezierPoint( a, b, c, d, (1)/float(N) );
	vec2 D = bezierPoint( a, b, c, d, (2)/float(N) );
	// the (C-B)*0.2 adds a bit of overdraw. this is not perfect,
	// how to fix this?
	makeSegment( A, B-(C-B)*thickness/50.0, C, D );
	
	// last segment
	vertex_color = vec4( 0, 1, 0, 1 );
	A = bezierPoint( a, b, c, d, (N-2)/float(N) );
	B = bezierPoint( a, b, c, d, (N-1)/float(N) );
	C = bezierPoint( a, b, c, d, (N)/float(N) );
	D = 2*d-c;
	makeSegment( A, B, C+(C-B)*thickness/50.0, D );
	
	// all the others
	vertex_color = vec4( 0, 0, 1, 1 );
	for( int i = 3; i <= N; i++ ){
		float t = i/float(N);
		A = bezierPoint( a, b, c, d, (i-3)/float(N) );
		B = bezierPoint( a, b, c, d, (i-2)/float(N) );
		C = bezierPoint( a, b, c, d, (i-1)/float(N) );
		D = bezierPoint( a, b, c, d, (i-0)/float(N) );
		makeSegment( A, B, C, D );
	}
}

vec2 bezierPoint( vec2 a, vec2 b, vec2 c, vec2 d, float t ){
	return vec2(
		pow((1 - t), 3) * a.x + 3 * t * pow((1 -t), 2) * b.x + 3 * (1-t) * pow(t, 2)* c.x + pow (t, 3)* d.x,
		pow((1 - t), 3) * a.y + 3 * t * pow((1 -t), 2) * b.y + 3 * (1-t) * pow(t, 2)* c.y + pow (t, 3)* d.y
	);
}

void makeSegment( vec2 a, vec2 b, vec2 c, vec2 d ){
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
		vec2 b1 = b + rot * vec2(-cb.y, cb.x) * width / len / cos(alpha1);
		vec2 b2 = b + rot * vec2(cb.y, -cb.x) * width / len / cos(alpha1);
		
		// and for b,c,d
		float alpha2 = 0.5 * goodRad(atan(cd.y, cd.x) - atan(cb.y, cb.x));

		sa = sin(alpha2);
		ca = cos(alpha2);

		// rotation matrix + compute normal
		rot = mat2(ca, sa, -sa, ca);
		vec2 c1 = c + rot * vec2(-cb.y, cb.x) * width / len / cos(alpha2);
		vec2 c2 = c + rot * vec2(cb.y, -cb.x) * width / len / cos(alpha2);

		// the color is actually wrong! 
		emitV( b1, vertex[1].color);
		emitV( c1, vertex[2].color);
		emitV( b2, vertex[1].color);
		emitV( c2, vertex[2].color);
		EndPrimitive();
	}
}


// keeps an angle between -pi and +pi
// otherwise taking half the angle becomes awkward
float goodRad( float rad ){
	return mod(mod(rad+PI,TWO_PI)+TWO_PI,TWO_PI)-PI;
}

void emitV( vec2 v, vec4 color ){
	gl_Position = modelViewProjectionMatrix * vec4(v,0,1);
	vertex_color = color;
	EmitVertex();
}

