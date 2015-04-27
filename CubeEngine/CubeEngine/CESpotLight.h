//
//  CESpotLight.h
//  CubeEngine
//
//  Created by chance on 4/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"

@interface CESpotLight : CELight

@property (nonatomic, assign) GLfloat attenuation;
@property (nonatomic, assign) GLint shiniess;
@property (nonatomic, assign) GLfloat specularItensity;
@property (nonatomic, assign) GLfloat coneAngle; // in degree
@property (nonatomic, assign) GLfloat spotExponent;

@end
