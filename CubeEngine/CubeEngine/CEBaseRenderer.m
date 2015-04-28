//
//  CEBaseRenderer.m
//  CubeEngine
//
//  Created by chance on 4/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEBaseRenderer.h"
#import "CEProgram.h"
#import "CELight_Rendering.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"

NSString *const kBaseVertexShader = CE_SHADER_STRING
(
 attribute highp vec4 VertexPosition;
 attribute highp vec3 VertexNormal;
 
 uniform mat4 MVPMatrix;
 uniform mat4 MVMatrix;
 uniform mat3 NormalMatrix;
 
 varying vec3 Normal;
 varying vec4 Position;
 
 void main () {
     Normal = normalize(NormalMatrix * VertexNormal);
     Position = MVMatrix * VertexPosition;
     gl_Position = MVPMatrix * VertexPosition;
 }
 );

NSString *const kBaseFragmentSahder = CE_SHADER_STRING
(
 precision mediump float;
 
 struct LightInfo {
     int LightType; // 0:none 1:directional 2:point 3:spot
     vec4 LightPosition;
     vec3 LightDirection;
     vec3 LightColor;
     vec3 AmbientColor;
     float SpecularIntensity;
     float Shiniess;
     float Attenuation;
     float SpotConsCutoff;
     float SpotExponent;
 };
 uniform LightInfo Lights[LIGHT_COUNT];
 
 uniform vec4 BaseColor;
 uniform vec3 EyeDirection;
 uniform int LightCount;
 
 vec3 TotalDiffuse;
 vec3 TotalSpecular;
 
 varying vec3 Normal;
 varying vec4 Position;
 
 // Directional Light
 void ApplyDirectionalLight(LightInfo light) {
     // half vector
     vec3 halfVector = normalize(light.LightDirection + EyeDirection);
     
     // diffuse and specular factor
     float diffuse = max(0.0, dot(Normal, light.LightDirection));
     float specular = max(0.0, dot(Normal, halfVector));
     
     specular = (diffuse == 0.0) ? 0.0 : pow(specular, light.Shiniess);
     vec3 scatteredLight = light.AmbientColor + light.LightColor * diffuse;
     vec3 reflectedLight = light.LightColor * specular * light.SpecularIntensity;
     TotalDiffuse += scatteredLight;
     TotalSpecular += reflectedLight;
 }
 
 // Point Light
 void ApplyPointLight(LightInfo light) {
     // calcualte attenuation
     vec3 lightDirection = vec3(light.LightPosition) - vec3(Position);
     float lightDistance = length(lightDirection);
     lightDirection = lightDirection / lightDistance; // normalize light direction
     
     float attenuation = 1.0 / (1.0 + light.Attenuation * lightDistance + light.Attenuation * lightDistance * lightDistance);
     
     // calculate diffuse and specular factor
     vec3 halfVector = normalize(lightDirection + EyeDirection);
     float diffuse = max(0.0, dot(Normal, lightDirection));
     float specular = max(0.0, dot(Normal, halfVector));
     
     specular = (diffuse == 0.0) ? 0.0 : pow(specular, light.Shiniess);
     vec3 scatteredLight = light.AmbientColor + light.LightColor * diffuse * attenuation;
     vec3 reflectedLight = light.LightColor * specular * light.SpecularIntensity * attenuation;
     
     TotalDiffuse += scatteredLight;
     TotalSpecular += reflectedLight;
 }
 
 
 void ApplySpotLight(LightInfo light) {
     // calcualte attenuation
     vec3 lightDirection = vec3(light.LightPosition) - vec3(Position);
     float lightDistance = length(lightDirection);
     lightDirection = lightDirection / lightDistance; // normalize light direction
     
     float attenuation = 1.0 / (1.0 + light.Attenuation * lightDistance + light.Attenuation * lightDistance * lightDistance);
     
     // spot cos
     // lightDirection: current position to light position Direction
     // light.LightDirection: source light direction, ref as ConeDirection
     float spotCos = dot(lightDirection, light.LightDirection);
     if (spotCos < light.SpotConsCutoff) {
         attenuation = 0.0;
     } else {
         attenuation *= pow(spotCos, light.SpotExponent);
     }
     
     // calculate diffuse and specular factor
     vec3 halfVector = normalize(lightDirection + EyeDirection);
     float diffuse = max(0.0, dot(Normal, lightDirection));
     float specular = max(0.0, dot(Normal, halfVector));
     
     specular = (diffuse == 0.0) ? 0.0 : pow(specular, light.Shiniess);
     vec3 scatteredLight = light.AmbientColor + light.LightColor * diffuse * attenuation;
     vec3 reflectedLight = light.LightColor * specular * light.SpecularIntensity * attenuation;
     
     TotalDiffuse += scatteredLight;
     TotalSpecular += reflectedLight;
 }
 
 
 void main() {
     vec3 processColor = BaseColor.rgb;
     if (LightCount > 0) {
         TotalDiffuse = vec3(0.0);
         TotalSpecular = vec3(0.0);
         for (int i = 0; i < LightCount; i++) {
             LightInfo light  = Lights[i];
             if (light.LightType == 1) { // apply directional light
                 ApplyDirectionalLight(light);
                 
             } else if (light.LightType == 2) { // apply point light
                 ApplyPointLight(light);
                 
             } else if (light.LightType == 3) { // apply spot light
                 ApplySpotLight(light);
             }
         }
         processColor = processColor * TotalDiffuse + TotalSpecular;
     }
     
     gl_FragColor = vec4(min(processColor, vec3(1.0)), BaseColor.a);
 }
);


@implementation CEBaseRenderer {
    CEProgram *_program;
    NSArray *_lightUniformInfos;
    
    GLint _attribVec4Position;
    GLint _attribVec3Normal;
    
    GLint _uniMtx4MVPMatrix;
    GLint _uniMtx4MVMatrix;
    GLint _uniMtx3NormalMatrix;
    
    GLint _uniVec4BaseColor;
    GLint _uniVec3EyeDirection;
    GLint _uniIntLightCount;
}

- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    NSString *fragmentShader = [kBaseFragmentSahder stringByReplacingOccurrencesOfString:@"LIGHT_COUNT" withString:[NSString stringWithFormat:@"%lu", (unsigned long)[CELight maxLightCount]]];
    _program = [[CEProgram alloc] initWithVertexShaderString:kBaseVertexShader
                                        fragmentShaderString:fragmentShader];
    [_program addAttribute:@"VertexPosition"];
    [_program addAttribute:@"VertexNormal"];
    BOOL isOK = [_program link];
    if (isOK) {
        _attribVec4Position     = [_program attributeIndex:@"VertexPosition"];
        _attribVec3Normal       = [_program attributeIndex:@"VertexNormal"];
        _uniMtx4MVPMatrix       = [_program uniformIndex:@"MVPMatrix"];
        _uniMtx3NormalMatrix    = [_program uniformIndex:@"NormalMatrix"];
        _uniIntLightCount       = [_program uniformIndex:@"LightCount"];
        _uniVec4BaseColor       = [_program uniformIndex:@"BaseColor"];
        _uniMtx4MVMatrix        = [_program uniformIndex:@"MVMatrix"];
        _uniVec3EyeDirection    = [_program uniformIndex:@"EyeDirection"];
        
        // get uniform infos
        NSMutableArray *uniformInfos = [NSMutableArray arrayWithCapacity:[CELight maxLightCount]];
        for (int i = 0; i < [CELight maxLightCount]; i++) {
            CELightUniformInfo *info = [CELightUniformInfo new];
            info.lightType_i = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightType", i]];
            if (info.lightType_i < 0) continue;
            info.lightPosition_vec4 = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightPosition", i]];
            if (info.lightPosition_vec4 < 0) continue;
            info.lightDirection_vec3 = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightDirection", i]];
            if (info.lightDirection_vec3 < 0) continue;
            info.lightColor_vec3 = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightColor", i]];
            if (info.lightColor_vec3 < 0) continue;
            info.ambientColor_vec3 = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].AmbientColor", i]];
            if (info.ambientColor_vec3 < 0) continue;
            info.specularIntensity_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpecularIntensity", i]];
            if (info.specularIntensity_f < 0) continue;
            info.shiniess_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].Shiniess", i]];
            if (info.shiniess_f < 0) continue;
            info.attenuation_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].Attenuation", i]];
            if (info.attenuation_f < 0) continue;
            info.spotCosCutoff_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpotConsCutoff", i]];
            if (info.spotCosCutoff_f < 0) continue;
            info.spotExponent_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpotExponent", i]];
            if (info.spotExponent_f < 0) continue;
            
            [uniformInfos addObject:info];
        }
        _lightUniformInfos = [uniformInfos copy];
        
    } else {
        // print error info
        NSString *progLog = [_program programLog];
        CEError(@"Program link log: %@", progLog);
        NSString *fragLog = [_program fragmentShaderLog];
        CEError(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [_program vertexShaderLog];
        CEError(@"Vertex shader compile log: %@", vertLog);
        _program = nil;
    }
    
    return isOK;
}

- (void)setLights:(NSArray *)lights {
    if (_lights != lights) {
        _lights = [lights copy];
        [_lights enumerateObjectsUsingBlock:^(CELight *light, NSUInteger idx, BOOL *stop) {
            if (idx < _lightUniformInfos.count) {
                light.uniformInfo = _lightUniformInfos[idx];
            }
        }];
    }
}

- (void)renderObject:(CEModel *)object {
    if (!_program || !object.vertexBuffer || !_camera) {
        CEError(@"Invalid paramater for rendering");
        return;
    }
    
    // setup vertex buffer
    if (![object.vertexBuffer setupBufferWithContext:self.context] ||
        (object.indicesBuffer && ![object.indicesBuffer setupBufferWithContext:self.context])) {
        return;
    }
    // prepare for rendering
    if (![object.vertexBuffer prepareAttribute:CEVBOAttributePosition withProgramIndex:_attribVec4Position] ||
        ![object.vertexBuffer prepareAttribute:CEVBOAttributeNormal withProgramIndex:_attribVec3Normal]){
        return;
    }
    if (object.indicesBuffer && ![object.indicesBuffer prepareForRendering]) {
        return;
    }
    [_program use];
    
    // setup lighting uniforms !!!: must setup light before mvp matrix;
    glUniform1i(_uniIntLightCount, (GLint)_lights.count);
    for (CELight *light in _lights) {
        [light updateUniformsWithCamera:_camera];
    }
    
    // setup other uniforms
    glUniform4f(_uniVec4BaseColor, object.vec3BaseColor.r, object.vec3BaseColor.g,
                object.vec3BaseColor.b, object.vec3BaseColor.a);
    GLKVector3 eyeDirection = GLKVector3Normalize(_camera.position);
    glUniform3f(_uniVec3EyeDirection, eyeDirection.x, eyeDirection.y, eyeDirection.z);
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, object.transformMatrix);
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    glUniformMatrix4fv(_uniMtx4MVPMatrix, 1, GL_FALSE, projectionMatrix.m);
    glUniformMatrix4fv(_uniMtx4MVMatrix, 1, GL_FALSE, modelViewMatrix.m);
    // setup normal matrix
    GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(modelViewMatrix);
    normalMatrix = GLKMatrix3InvertAndTranspose(normalMatrix, NULL);
    glUniformMatrix3fv(_uniMtx3NormalMatrix, 1, GL_FALSE, normalMatrix.m);
    
    if (object.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, object.indicesBuffer.indicesCount, object.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, object.vertexBuffer.vertexCount);
    }
}

@end
