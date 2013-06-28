//
//  main.m
//  Geometry
//
//  Created by Jeffrey Varner on 6/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLGeometryInputSpecificationController.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        // args array -
        NSMutableArray *myArgsArray = [NSMutableArray array];
        
        // Loop through the input args and convert into job files names -
        for (int argument_index = 0;argument_index<argc;argument_index++)
        {
            // Grab the arguments, convert into NSString and then put into the dictionary -
            NSString *argString = [NSString stringWithCString:argv[argument_index] encoding:[NSString defaultCStringEncoding]];
            
            if (argument_index>0)
            {
                [myArgsArray addObject:argString];
            }
        }
        
        // build controller -
        VLGeometryInputSpecificationController *mySpecificationController = [[VLGeometryInputSpecificationController alloc] initWithArgumentsArray:[NSArray arrayWithArray:myArgsArray]];
        [mySpecificationController processInputGeometrySpecificationFile];
    }
    return 0;
}



