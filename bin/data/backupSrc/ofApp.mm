#include "ofApp.h"



//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    this->session = session;
}

ofApp::ofApp(){
    
}

//--------------------------------------------------------------
ofApp :: ~ofApp () {
    
}

//--------------------------------------------------------------
void ofApp::setup() {
    
    ofBackground(127);
    
    
    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;
    
    font.load("fonts/mono0755.ttf", fontSize);
    
    
    
    processor = ARProcessor::create(session);
    processor->setup();
    
    // pass info to utils
    utils.processor = processor;
    utils.session = session;
    

    camImage.allocate(ofGetWidth(), ofGetHeight());
    
    
    
    
    //Alpha shader new
    ofEnableAlphaBlending();
    //ofBackground(0);
    ofSetVerticalSync(true);
    
    ofTrueTypeFont::setGlobalDpi(144);
    dinpro_black60.load("DINPro-Black.otf", 60, true, true);
    
    videos.resize(nLayers);
    
    maskFbos.resize(nLayers);
    fbos.resize(nLayers);
    
    for(int i = 0; i < nLayers; i++){
//
        videos[i].load("video" +  ofToString(i) +".mp4");

        videos[i].setLoopState(OF_LOOP_NORMAL);
        videos[i].play();
    
        maskFbos[i].allocate(ofGetWidth(), ofGetHeight());
        fbos[i].allocate(ofGetWidth(), ofGetHeight());
        
        maskFbos[i].begin();
        ofClear(0,0,0,255);
        maskFbos[i].end();
        
        fbos[i].begin();
        ofClear(0,0,0,255);
        fbos[i].end();
    }
    
    brushImg.load("brush2.png");
    eraserImg.load("brush3.png");
    
    tileImg.load("B.jpg");
    //tileImg.resize(1920, 1080);
    
    brushImg.setAnchorPercent(0.5, 0.5);
    eraserImg.setAnchorPercent(0.5, 0.5);
    
    
    
    // There are 3 of ways of loading a shader:
    //
    //  1 - Using just the name of the shader and ledding ofShader look for .frag and .vert:
    //      Ex.: shader.load( "myShader");
    //
    //  2 - Giving the right file names for each one:
    //      Ex.: shader.load( "myShader.vert","myShader.frag");
    //
    //  3 - And the third one is passing the shader programa on a single string;
    //
    
    
#ifdef TARGET_OPENGLES
    shader.load("shaders_gles/alphamask.vert","shaders_gles/alphamask.frag");
#else
    if(ofIsGLProgrammableRenderer()){
        string vertex = "#version 150\n\
        \n\
        uniform mat4 projectionMatrix;\n\
        uniform mat4 modelViewMatrix;\n\
        uniform mat4 modelViewProjectionMatrix;\n\
        \n\
        \n\
        in vec4  position;\n\
        in vec2  texcoord;\n\
        \n\
        out vec2 texCoordVarying;\n\
        \n\
        void main()\n\
        {\n\
        texCoordVarying = texcoord;\
        gl_Position = modelViewProjectionMatrix * position;\n\
        }";
        string fragment = "#version 150\n\
        \n\
        uniform sampler2DRect tex0;\
        uniform sampler2DRect maskTex;\
        in vec2 texCoordVarying;\n\
        \
        out vec4 fragColor;\n\
        void main (void){\
        vec2 pos = texCoordVarying;\
        \
        vec3 src = texture(tex0, pos).rgb;\
        float mask = texture(maskTex, pos).r;\
        \
        fragColor = vec4( src , mask);\
        }";
        shader.setupShaderFromSource(GL_VERTEX_SHADER, vertex);
        shader.setupShaderFromSource(GL_FRAGMENT_SHADER, fragment);
        shader.bindDefaults();
        shader.linkProgram();
    }else{
        string shaderProgram = "#version 120\n \
        #extension GL_ARB_texture_rectangle : enable\n \
        \
        uniform sampler2DRect tex0;\
        uniform sampler2DRect maskTex;\
        \
        void main (void){\
        vec2 pos = gl_TexCoord[0].st;\
        \
        vec3 src = texture2DRect(tex0, pos).rgb;\
        float mask = texture2DRect(maskTex, pos).r;\
        \
        gl_FragColor = vec4( src , mask);\
        }";
        shader.setupShaderFromSource(GL_FRAGMENT_SHADER, shaderProgram);
        shader.linkProgram();
    }
#endif
    
    bBrushDown = false;
    
    
}


//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    
    //cout << utils.getCurrentCameraPosition() << endl;
    
    
    
    
    //Shader alpha new
    if (pause == false) {
        for(int i = 0; i < videos.size(); i++){
            videos[i].update();
        }
    }
    
    std::stringstream strm;
    strm << "fps: " << ofGetFrameRate();
    ofSetWindowTitle(strm.str());
    
    if (clear) {
        for (int i = 0; i < nLayers; i++){
            maskFbos[i].begin();
            ofClear(0,0,0,255);
            maskFbos[i].end();
        }
    }
    
}


ofCamera camera;
//--------------------------------------------------------------
void ofApp::draw() {
    ofEnableAlphaBlending();
    
    ofDisableDepthTest();
    
    camImage.begin();
    processor->draw();
    camImage.end();
    
    camImage.draw(0,0);
    
    ofEnableDepthTest();
    
    
    if (session.currentFrame){
        if (session.currentFrame.camera){
           
            camera.begin();
            processor->setARCameraMatrices();
          
            for (int i = 0; i < planes.size(); i++){
            ofMesh m;
            m.setMode(OF_PRIMITIVE_TRIANGLE_STRIP);
            m.addVertex(planes[i].pts[0]);
            m.addVertex(planes[i].pts[1]);
            m.addVertex(planes[i].pts[3]);
            m.addVertex(planes[i].pts[2]);
            m.addTexCoord(images[i].getTexture().getCoordFromPercent(0,0));
            m.addTexCoord(images[i].getTexture().getCoordFromPercent(1,0));
            m.addTexCoord(images[i].getTexture().getCoordFromPercent(0,1));
            m.addTexCoord(images[i].getTexture().getCoordFromPercent(1,1));
            images[i].getTexture().bind();
            m.draw();
            images[i].getTexture().unbind();
             }
            
            camera.end();
        }
    }
    ofDisableDepthTest();
    // ========== DEBUG STUFF ============= //
    int w = MIN(ofGetWidth(), ofGetHeight()) * 0.6;
    int h = w;
    int x = (ofGetWidth() - w)  * 0.5;
    int y = (ofGetHeight() - h) * 0.5;
    int p = 0;
    
    x = ofGetWidth()  * 0.2;
    y = ofGetHeight() * 0.11;
    p = ofGetHeight() * 0.035;
    
    //ofSetColor(ofColor::black);
    font.drawString("frame num      = " + ofToString( ofGetFrameNum() ),    x, y+=p);
    font.drawString("frame rate     = " + ofToString( ofGetFrameRate() ),   x, y+=p);
    font.drawString("screen width   = " + ofToString( ofGetWidth() ),       x, y+=p);
    font.drawString("screen height  = " + ofToString( ofGetHeight() ),      x, y+=p);
    
    
    //Alpha shader new
    ofSetColor(255);
    ofEnableAlphaBlending();
    //----------------------------------------------------------
    // this is our alpha mask which we draw into.

    
    if(bBrushDown && eraserBrush==false) {
        for(int i = 0; i < nLayers; i++){
            if(currentLayer == i) {
                maskFbos[i].begin();
                ofSetColor(255,brushAlpha);
                brushImg.draw(mouseX,mouseY,brushSize,brushSize);
                maskFbos[i].end();
            } else {
                //Clear the other layers in the area your are painting
                maskFbos[i].begin();
                //ofSetColor(255, 255);
                eraserImg.draw(mouseX,mouseY,brushSize,brushSize);
                maskFbos[i].end();
            }
        }
    }
    
    
    for (int i = 0; i < nLayers; i ++) {
        ofEnableBlendMode(OF_BLENDMODE_SCREEN);
        //Could perhaps be out of the loop?
        fbos[i].begin();

        // Cleaning everthing with alpha mask on 0 in order to make it transparent by default
        ofClear(0, 0, 0, 0);

        shader.begin();
        // here is where the fbo is passed to the shader
        shader.setUniformTexture("maskTex", maskFbos[i].getTextureReference(), 1 );

        //videos[i].draw(0,0);
        //tileImg.draw(0,0); //or use a basic image
        
        camImage.draw(0,0); //Or use the cam image

        shader.end();
        fbos[i].end();
        ofEnableAlphaBlending();
        //fbos[i].draw(0,0);
    }
}

//--------------------------------------------------------------
void ofApp::exit() {
    //
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs &touch){
    
    plane p = utils.getScreenPlane(1.0, 0);
    planes.push_back(p);
    
    ofFbo temp;
    images.push_back(temp);
    images.back().allocate(camImage.getWidth(), camImage.getHeight());
    images.back().begin();
    //camImage.draw(0,0);
    fbos[0].draw(0,0);
    images.back().end();
    
//    for (int i = 0; i < 10; i++){
//        plane p = utils.getScreenPlane(1.0, ofMap(i, 0, 9, -.2, -1));
//        planes.push_back(p);
//    }

    bBrushDown = true;
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs &touch){
    
    
    
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs &touch){
    bBrushDown = false;
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs &touch){
    
    planes.clear();
    
//    maskFbo.begin();
//    ofClear(0,0,0,255);
//    maskFbo.end();
    
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}


//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs& args){
    
}


