//
//  CEShaderVariable.h
//  CubeEngine
//
//  Created by chance on 8/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface CEShaderVariable : NSObject {
    GLint _index;
}

@property (nonatomic, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name;

// return the data type of the variable, must be implement by subclass
- (NSString *)dataType;

@end
