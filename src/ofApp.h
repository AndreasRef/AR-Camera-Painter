#pragma once

#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"
#include "arUtils.h"


class ofApp : public ofxiOSApp {
    
public:
    
    ofApp (ARSession * session);
    ofApp();
    ~ofApp ();
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs &touch);
    void touchMoved(ofTouchEventArgs &touch);
    void touchUp(ofTouchEventArgs &touch);
    void touchDoubleTap(ofTouchEventArgs &touch);
    void touchCancelled(ofTouchEventArgs &touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    

    ofTrueTypeFont font;
    ARSession * session;
    ARRef processor;

    arUtils utils;
    
    vector < plane > planes;
    vector < ofFbo > images;
    
    ofFbo myImage;
    plane myPlane;
    
    ofFbo camImage;
    
    //Alpha shader new
    ofImage     brushImg;
    ofImage     eraserImg;
    ofImage     uiBrushImg;
    
//    vector<ofVideoPlayer> videos;
    vector<ofFbo> maskFbos;
    vector<ofFbo> fbos;
    
    ofShader    shader;
    
    bool        bBrushDown;
    bool        eraserBrush = false;
    
    int nLayers = 1;
    
    int brushSize = 150;
    int brushAlpha = 255;
    int currentLayer = 0;
    bool pause = false;
    bool showFont = false;
    bool clear = false;
    
    ofTrueTypeFont    dinpro_black60;
    
    int paintX = 0;
    int paintY = 0;
    
    bool debugTouch = false;
    
    ofFbo debugMask;
    
};


