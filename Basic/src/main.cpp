#include "ofMain.h"
#include "ofApp.h"

//========================================================================
int main( ){
	ofGLWindowSettings settings;
	settings.setGLVersion(3,2);
	settings.width = 1400;
	settings.height = 768; 
	
	ofCreateWindow(settings);
	
	
	/*
	ofSetupOpenGL(1400,768, OF_WINDOW);			// <-------- setup the GL context
	if(!ofGLCheckExtension("GL_ARB_geometry_shader4") && !ofGLCheckExtension("GL_EXT_geometry_shader4") && !ofIsGLProgrammableRenderer()){
		ofLogFatalError() << "geometry shaders not supported on this graphics card";
		return 1;
	}*/

	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp( new ofApp());

}
