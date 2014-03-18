//
//  VLGeometryInputSpecificationController.h
//  Geometry
//
//  Created by Jeffrey Varner on 6/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_NODES 10000

typedef enum {
    
    VLGeometryInputSpecificationInputFilePath = 0,
    VLGeometryInputSpecificationOutputFilePath = 1
    
} VLGeometryInputSpecificationOptions;

@interface VLGeometryInputSpecificationController : NSObject
{
    
@private
    NSMutableArray *_myArgsArray;
    NSArray *_myTriangleNodeArray;
    int numberOfNodes;
    int myEdgeArray[MAX_NODES][MAX_NODES];
}

// custom init method
-(id)initWithArgumentsArray:(NSArray *)array;
-(void)processInputGeometrySpecificationFile;

@end
