//
//  CESpotLight.m
//  CubeEngine
//
//  Created by chance on 4/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CESpotLight.h"
#import "CELight_Rendering.h"

@implementation CESpotLight {
    GLfloat _coneAngleCosine;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSharedVertexBuffer];
        _hasChanged = YES;
        _specularItensity = 1.0;
        _shiniess = 20;
        _attenuation = 0.001;
        [self setConeAngle:30];
        _spotExponent = 10;
    }
    return self;
}

#define kCirclePointCount 16
- (void)setupSharedVertexBuffer {
    static CEVertexBuffer *_sharedVertexBuffer;
    static CEIndicesBuffer *_sharedIndicesBuffer;
    if (!_sharedVertexBuffer) {
        GLfloat red = 200.0 / 255.0, green = 150.0 / 255.0, blue = 0.0, alpha = 1.0;
        GLfloat vertices[(kCirclePointCount + 7) * 7] = {0};
        // create circle points
        GLfloat radius = 2 * tanf(GLKMathDegreesToRadians(_coneAngle));
        for (int i = 0; i < kCirclePointCount; i++) {
            GLfloat angle = i * 2 * M_PI / kCirclePointCount;
            vertices[i * 7] = 0.5;                        // X
            vertices[i * 7 + 1] = sin(angle) * radius;  // Y
            vertices[i * 7 + 2] = cos(angle) * radius;  // Z
            vertices[i * 7 + 3] = red;                  // red
            vertices[i * 7 + 4] = green;                // green
            vertices[i * 7 + 5] = blue;                 // blue
            vertices[i * 7 + 6] = alpha;                // angle
        }
        // add other points
        GLfloat otherVertices[7 * 7] = {
            0.0, 0.0, 0.0, red, green, blue, alpha,
            -0.15, -0.15, -0.15, 1.0, 0.0, 0.0, 1.0,
            0.15, -0.15, -0.15, 1.0, 0.0, 0.0, 1.0,
            -0.15, -0.15, -0.15, 0.0, 1.0, 0.0, 1.0,
            -0.15, 0.15, -0.15, 0.0, 1.0, 0.0, 1.0,
            -0.15, -0.15, -0.15, 0.0, 0.0, 1.0, 1.0,
            -0.15, -0.15, 0.15, 0.0, 0.0, 1.0, 1.0,
        };
        for (int i = 0; i < 49; i++) {
            vertices[i + kCirclePointCount * 7] = otherVertices[i];
        }
        
        NSData *vertexData = [NSData dataWithBytes:&vertices length:sizeof(vertices)];
        NSArray *attributes = @[[CEVBOAttribute attributeWithname:CEVBOAttributePosition],
                                [CEVBOAttribute attributeWithname:CEVBOAttributeColor]];
        _sharedVertexBuffer = [[CEVertexBuffer alloc] initWithData:vertexData attributes:attributes];
    }
    
    if (!_sharedIndicesBuffer) {
        int indexCount = 0;
        GLubyte indices[kCirclePointCount * 2 + 14] = {0};
        for (int i = 0; i < kCirclePointCount; i++) {
            indices[indexCount] = i;
            indices[indexCount + 1] = (i + 1) % kCirclePointCount;
             indexCount += 2;
            if (i % (kCirclePointCount / 4) == 0) {
                indices[indexCount] = i;
                indices[indexCount + 1] = kCirclePointCount;
                indexCount += 2;
            }
        }
        for (int i = 0; i < 6; i++) {
            indices[indexCount] = kCirclePointCount + 1 + i;
            indexCount++;
        }
        
        for (int i = 0; i < sizeof(indices); i++) {
            printf("indices[%d] = %d\n", i, indices[i]);
        }
        
        NSData *indicesData = [NSData dataWithBytes:&indices length:sizeof(indices)];
        _sharedIndicesBuffer = [[CEIndicesBuffer alloc] initWithData:indicesData indicesCount:sizeof(indices)];
    }
    
    _vertexBuffer = _sharedVertexBuffer;
    _indicesBuffer = _sharedIndicesBuffer;
}

- (void)setShiniess:(GLint)shiniess {
    if (_shiniess != shiniess) {
        _shiniess = shiniess;
        _hasLightChanged = YES;
    }
}

- (void)setSpecularItensity:(GLfloat)specularItensity {
    if (_specularItensity != specularItensity) {
        _specularItensity = specularItensity;
        _hasLightChanged = YES;
    }
}

- (void)setAttenuation:(GLfloat)attenuation {
    if (_attenuation != attenuation) {
        _attenuation = attenuation;
        _hasLightChanged = YES;
    }
}


- (void)setConeAngle:(GLfloat)coneAngle {
    if (_coneAngle != coneAngle) {
        _coneAngle = coneAngle;
        // change model data
        _hasLightChanged = YES;
    }
}


- (void)setSpotExponent:(GLfloat)spotExponent {
    if (_spotExponent != spotExponent) {
        _spotExponent = spotExponent;
        _hasLightChanged = YES;
    }
}


- (void)updateUniformsWithCamera:(CECamera *)camera {
    if (!_uniformInfo || (!_hasLightChanged && !self.hasChanged && !camera.hasChanged)) return;
    
    glUniform1i(_uniformInfo.lightType_i, CEPointLightType);
    glUniform3fv(_uniformInfo.lightColor_vec3, 1, _lightColorV3.v);
    glUniform3fv(_uniformInfo.ambientColor_vec3, 1, _ambientColorV3.v);
    glUniform1f(_uniformInfo.shiniess_f, (GLfloat)_shiniess);
    glUniform1f(_uniformInfo.specularIntensity_f, _specularItensity);
    glUniform1f(_uniformInfo.attenuation_f, _attenuation);
    
    // !!!: transfer light position in view space
    GLKVector4 lightPosition = GLKMatrix4MultiplyVector4([self transformMatrix], GLKVector4Make(0, 0, 0, 1));
    lightPosition = GLKMatrix4MultiplyVector4(camera.viewMatrix, lightPosition);
    glUniform4fv(_uniformInfo.lightPosition_vec4, 1, lightPosition.v);
    
    _hasLightChanged = NO;
    CEPrintf("Update Point Light Uniform\n");
}


@end
