#include "arUtils.h"



plane arUtils::getScreenPlane(float scale, float distFromScreen){
    
    ofMatrix4x4 view = processor->getViewMatrix();
    ofMatrix4x4 proj = processor->getProjectionMatrix();
    
    ofRectangle viewport = ofRectangle(0,0,ofGetWidth(), ofGetHeight());
    ofMatrix4x4 modelviewProjectionMatrix = view * proj;
    auto inverseCamera = modelviewProjectionMatrix.getInverse();
    
    plane p;
    
    ofPoint midPt(ofGetWidth()/2, ofGetHeight()/2);
    
    for (int i = 0; i < 4; i++){
        
        ofPoint ScreenXYZ;
        if (i == 0) ScreenXYZ.set(0,0);
        if (i == 1) ScreenXYZ.set(ofGetWidth(),0);
        if (i == 2) ScreenXYZ.set(ofGetWidth(),ofGetHeight());
        if (i == 3) ScreenXYZ.set(0,ofGetHeight());
        
        ScreenXYZ = midPt + (ScreenXYZ - midPt) * scale;

        ScreenXYZ.z = distFromScreen;
        //convert from screen to camera
        ofVec4f CameraXYZ;
        CameraXYZ.x = 2.0f * (ScreenXYZ.x - viewport.x) / viewport.width - 1.0f;
        CameraXYZ.y = 1.0f - 2.0f *(ScreenXYZ.y - viewport.y) / viewport.height;
        CameraXYZ.z = ScreenXYZ.z;
        CameraXYZ.w = 1.0;
        
        //convert camera to world
        ofVec4f world = CameraXYZ * inverseCamera;
        
        ofPoint pp = ofPoint(world.x, world.y, world.z) / world.w;
        p.pts.push_back( pp);
    }
    
    return p;
    
}

ofPoint arUtils::mapToPlane(plane p, float pctx, float pcty){
    vector < ofPoint > & pts = p.pts;
    ofPoint aa = pts[0] + (pts[3] - pts[0]) * pcty;
    ofPoint bb = pts[1] + (pts[2] - pts[1]) * pcty;
    ofPoint mix = aa + pctx * (bb - aa);
    return mix;
}

ofPoint arUtils::projectToScreen(ofPoint pos){
    ofMatrix4x4 view = processor->getViewMatrix();
    ofMatrix4x4 proj = processor->getProjectionMatrix();
    pos = pos *  view;
    pos = pos *  proj;
    return pos;
}


ofQuaternion arUtils::getCurrentCameraOrientation(float distFromScreen){
    matrix_float4x4 translation = matrix_identity_float4x4;
    translation.columns[3].z = distFromScreen;
    matrix_float4x4 transform = matrix_multiply(session.currentFrame.camera.transform, translation);
    ofMatrix4x4 matTemp = convertMat(transform);
    ofPoint pos;
    ofQuaternion q;
    ofPoint scale;
    ofQuaternion so;
    matTemp.decompose(pos, q, scale, so);
    return q;
}


ofPoint arUtils::getCurrentCameraPosition(float distFromScreen){
    matrix_float4x4 translation = matrix_identity_float4x4;
    translation.columns[3].z = distFromScreen;
    matrix_float4x4 transform = matrix_multiply(session.currentFrame.camera.transform, translation);
    ofMatrix4x4 matTemp = convertMat(transform);
    ofPoint pos;
    ofQuaternion q;
    ofPoint scale;
    ofQuaternion so;
    matTemp.decompose(pos, q, scale, so);
    return pos;
}

ofPoint arUtils::getCurrentCameraLookAt(){
    matrix_float4x4 translation = matrix_identity_float4x4;
    translation.columns[3].z = -0.2;
    matrix_float4x4 translation2 = matrix_identity_float4x4;
    translation2.columns[3].z = -0.9;
    matrix_float4x4 transform = matrix_multiply(session.currentFrame.camera.transform, translation);
    matrix_float4x4 transform2 = matrix_multiply(session.currentFrame.camera.transform, translation2);
    ofMatrix4x4 matTemp = convertMat(transform);
    ofMatrix4x4 matTemp2 = convertMat(transform2);
    ofPoint pos;
    ofQuaternion q;
    ofPoint scale;
    ofQuaternion so;
    matTemp.decompose(pos, q, scale, so);
    ofPoint pos2;
    ofQuaternion q2;
    ofPoint scale2;
    ofQuaternion so2;
    matTemp2.decompose(pos2, q2, scale2, so2);
    return ((pos2 - pos).getNormalized());
}


matrix_float4x4 arUtils::getNewCameraMat(){
    
    matrix_float4x4 coordinateSpaceTransform = matrix_identity_float4x4;
    coordinateSpaceTransform.columns[2].z = -1.0;
    
    matrix_float4x4 newMat = matrix_multiply(session.currentFrame.camera.transform, coordinateSpaceTransform);
    return newMat;
}



//ofPoint getCurrentCameraPosition(ofMatrix4x4 view, ofMatrix4x4 proj, float z){
//
//    ofRectangle viewport = ofRectangle(0,0,ofGetWidth(), ofGetHeight());
//    ofMatrix4x4 modelviewProjectionMatrix = view * proj;
//    auto inverseCamera = modelviewProjectionMatrix.getInverse();
//
//    plane p;
//
//    ofPoint ScreenXYZ;
//    ScreenXYZ.set(ofGetWidth()/2,ofGetHeight()/2);
//    ScreenXYZ.z = z;
//    //convert from screen to camera
//    ofVec4f CameraXYZ;
//    CameraXYZ.x = 2.0f * (ScreenXYZ.x - viewport.x) / viewport.width - 1.0f;
//    CameraXYZ.y = 1.0f - 2.0f *(ScreenXYZ.y - viewport.y) / viewport.height;
//    CameraXYZ.z = ScreenXYZ.z;
//    CameraXYZ.w = 1.0;
//
//    //convert camera to world
//    ofVec4f world = CameraXYZ * inverseCamera;
//
//    ofPoint pp = ofPoint(world.x, world.y, world.z) / world.w;
//    return pp;
//
//}
//
//// this should be optimized but ok
//ofPoint getScreenPoint(ofMatrix4x4 view, ofMatrix4x4 proj, ofPoint screenPoint, float z){
//
//    ofRectangle viewport = ofRectangle(0,0,ofGetWidth(), ofGetHeight());
//    ofMatrix4x4 modelviewProjectionMatrix = view * proj;
//    auto inverseCamera = modelviewProjectionMatrix.getInverse();
//
//    plane p;
//
//    ofPoint ScreenXYZ;
//    ScreenXYZ = screenPoint;
//    ScreenXYZ.z = z;
//    //convert from screen to camera
//    ofVec4f CameraXYZ;
//    CameraXYZ.x = 2.0f * (ScreenXYZ.x - viewport.x) / viewport.width - 1.0f;
//    CameraXYZ.y = 1.0f - 2.0f *(ScreenXYZ.y - viewport.y) / viewport.height;
//    CameraXYZ.z = ScreenXYZ.z;
//    CameraXYZ.w = 1.0;
//
//    //convert camera to world
//    ofVec4f world = CameraXYZ * inverseCamera;
//
//    ofPoint pp = ofPoint(world.x, world.y, world.z) / world.w;
//    return pp;
//
//}
//
