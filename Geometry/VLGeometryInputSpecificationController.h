//
//  VLGeometryInputSpecificationController.h
//  Geometry
//
//  Created by Jeffrey Varner on 6/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    VLGeometryInputSpecificationInputFilePath = 0,
    VLGeometryInputSpecificationOutputFilePath = 1
    
} VLGeometryInputSpecificationOptions;

@interface VLGeometryInputSpecificationController : NSObject
{
    @private
    NSMutableArray *_myArgsArray;
    NSArray *_myTriangleNodeArray;
}

// custom init method
-(id)initWithArgumentsArray:(NSArray *)array;
-(void)processInputGeometrySpecificationFile;

@end
