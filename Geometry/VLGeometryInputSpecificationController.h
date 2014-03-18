//
//  VLGeometryInputSpecificationController.h
//  Geometry
//
//  Created by Jeffrey Varner on 6/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>


#define MAX_NODES 10000    // number of maximum nodes that can be accomodated 

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
    
    // array used to keep track of the edges which have been printed in the
    // geometry file. If an edge exists from start-node (x) to end
    // -node (y) then the myEdgeArray[x][y] = 1, otherwise 0. The size of
    // myEdgeArray is determined by MAX_NODES.
    int myEdgeArray[MAX_NODES][MAX_NODES];
}

// custom init method
-(id)initWithArgumentsArray:(NSArray *)array;
-(void)processInputGeometrySpecificationFile;

@end
