#version 150

in vec4 in_pos;
in vec4 vertex_color;

out Vertex{
	vec4 pos;
	vec4 color;
} vertex;


void main(){
	vertex.pos = in_pos;
	vertex.color =  vertex_color;
}
