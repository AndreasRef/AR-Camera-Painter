#pragma once

#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"





typedef struct {
  
    vector < ofPoint > pts;
    
} plane;

class arUtils {

    public:
    
    ARSession * session;
    ARRef processor;
    
    float deviceW;
    float deviceH;
    
    arUtils(){
        deviceW = 0;
        deviceH = 0;
    }
    
    void getDeviceDimensions(float & w, float & h);
    plane getScreenPlane(float scale, float distFromScreen = 0.2);
    ofPoint getCurrentCameraPosition(float distFromScreen = 0.0);
    ofQuaternion getCurrentCameraOrientation(float distFromScreen = 0.0);
    ofPoint getCurrentCameraLookAt();
    ofPoint mapToPlane(plane, float pctx, float pcty);
    ofPoint projectToScreen( ofPoint worldPoint);
    matrix_float4x4 getNewCameraMat();
    
    ofMatrix4x4 convertMat(const simd::float4x4 &matrix){
        ofMatrix4x4 mat;
        mat.set(matrix.columns[0].x,matrix.columns[0].y,matrix.columns[0].z,matrix.columns[0].w,
                matrix.columns[1].x,matrix.columns[1].y,matrix.columns[1].z,matrix.columns[1].w,
                matrix.columns[2].x,matrix.columns[2].y,matrix.columns[2].z,matrix.columns[2].w,
                matrix.columns[3].x,matrix.columns[3].y,matrix.columns[3].z,matrix.columns[3].w);
        return mat;
    }
    simd::float4x4 convertMat(const ofMatrix4x4 &mat){
        simd::float4x4 matrix;
        const float * ptr = mat.getPtr();
        for (int i = 0; i < 4; i++){
            matrix.columns[i].x = ptr[0+i*4];
            matrix.columns[i].y = ptr[1+i*4];
            matrix.columns[i].z = ptr[2+i*4];
            matrix.columns[i].w = ptr[3+i*4];
        }
        return matrix;
    }
    
    
    
    
    
};

