//
//  VLGeometryInputSpecificationController.m
//  Geometry
//
//  Created by Jeffrey Varner on 6/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLGeometryInputSpecificationController.h"

@interface VLGeometryInputSpecificationController ()

// Private lifecycle methods -
-(void)setup;
-(void)cleanMyMemory;

// private helpers
-(void)loadHeaderIntoBuffer:(NSMutableString *)buffer;
-(void)loadFooterIntoBuffer:(NSMutableString *)buffer;
-(void)loadNodeArrayIntoBuffer:(NSMutableString *)buffer usingBlueprintDocument:(NSXMLDocument *)document;
-(void)loadEdgeParameterBlockIntoBuffer:(NSMutableString *)buffer usingBlueprintDocument:(NSXMLDocument *)document;
-(void)writeGeometryBuffer:(NSMutableString *)buffer usingBlueprintDocument:(NSXMLDocument *)document;

// private props -
@property (strong) NSMutableArray *myArgsArray;
@property (strong) NSArray *myTriangleNodeArray;


@end

@implementation VLGeometryInputSpecificationController


// special init method
-(id)initWithArgumentsArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        
        // setup -
        [self setup];
        
        // clean -
        [[self myArgsArray] removeAllObjects];
        [[self myArgsArray] addObjectsFromArray:array];
    }
    return self;

}

-(void)dealloc
{
    [self cleanMyMemory];
}

#pragma mark  - logic
-(void)processInputGeometrySpecificationFile
{
    // Get paths from the input specification -
    NSString *input_file_path = [[self myArgsArray] objectAtIndex:VLGeometryInputSpecificationInputFilePath];
    
    if (input_file_path == nil)
    {
        return;
    }
    
    
    // Get document -
    NSXMLDocument *document = [VLCoreUtilitiesLib createXMLDocumentFromFile:[NSURL fileURLWithPath:input_file_path isDirectory:NO]];
    
    // start -
    NSMutableString *buffer = [NSMutableString string];
    
    // header -
    [self loadHeaderIntoBuffer:buffer];
    
    // Load the points_array file
    [self loadNodeArrayIntoBuffer:buffer usingBlueprintDocument:document];
    
    // load the triangle_array file
    [self loadTriangleArrayIntoBuffer:buffer usingBlueprintDocument:document];
    
    // load the edge parameters -
    [self loadEdgeParameterBlockIntoBuffer:buffer usingBlueprintDocument:document];
    
    // footer -
    [self loadFooterIntoBuffer:buffer];
    
    // write buffer to disk
    [self writeGeometryBuffer:buffer usingBlueprintDocument:document];
}

#pragma mark - private helper methods
-(void)loadHeaderIntoBuffer:(NSMutableString *)buffer
{
    [buffer appendString:@"<?xml version=\"1.0\" standalone=\"yes\"?>\n"];
    [buffer appendString:@"<geometry>\n"];
}

-(void)loadFooterIntoBuffer:(NSMutableString *)buffer
{
    [buffer appendString:@"</geometry>\n"];
}


-(void)loadEdgeParameterBlockIntoBuffer:(NSMutableString *)buffer usingBlueprintDocument:(NSXMLDocument *)document
{
    // Get the path for node array -
    NSError *error;
    NSString *edge_spring_constant = [[[document nodesForXPath:@"//listOfProperties/property[@key='EDGE_SPRING_CONSTANT']/@value" error:&error] lastObject] stringValue];
    NSString *edge_damping_constant = [[[document nodesForXPath:@"//listOfProperties/property[@key='EDGE_DAMPING_CONSTANT']/@value" error:&error] lastObject] stringValue];
    if (error == nil &&
        edge_damping_constant != nil &&
        edge_spring_constant != nil)
    {
        // build points array text -
        [buffer appendString:@"\n"];
        [buffer appendString:@"\t<listOfEdges>\n"];
        
        // Number formatter -
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        // Triangle array -
        NSArray *triangle_array = [self myTriangleNodeArray];
        NSInteger counter = 0;
        for (NSArray *row_array in triangle_array)
        {
            // array -
            NSMutableArray *value_array = [NSMutableArray array];
            
            // space delimited -
            for (NSString *value_string in row_array)
            {
                if ([value_string isEqualToString:@""]== NO)
                {
                    // Convert to a number -
                    NSNumber *number = [formatter numberFromString:value_string];
                    NSString *converted_number = [number stringValue];
                    
                    // grab the value -
                    [value_array addObject:converted_number];
                }
            }

            // edge -
            [buffer appendFormat:@"\t\t<edge index='%lu' spring_constant='%@' damping_constant='%@'",counter,edge_spring_constant,edge_damping_constant];
            [buffer appendFormat:@" start_node='%@'",[value_array objectAtIndex:0]];
            [buffer appendFormat:@" end_node='%@'/>\n",[value_array objectAtIndex:1]];
            
            // edge -
            counter = counter + 1;
            [buffer appendFormat:@"\t\t<edge index='%lu' spring_constant='%@' damping_constant='%@'",counter,edge_spring_constant,edge_damping_constant];
            [buffer appendFormat:@" start_node='%@'",[value_array objectAtIndex:1]];
            [buffer appendFormat:@" end_node='%@'/>\n",[value_array objectAtIndex:2]];
            
            // edge -
            counter = counter + 1;
            [buffer appendFormat:@"\t\t<edge index='%lu' spring_constant='%@' damping_constant='%@'",counter,edge_spring_constant,edge_damping_constant];
            [buffer appendFormat:@" start_node='%@'",[value_array objectAtIndex:2]];
            [buffer appendFormat:@" end_node='%@'/>\n",[value_array objectAtIndex:0]];
            
            // update the counter -
            counter = counter + 1;
            
            // add a new line -
            [buffer appendString:@"\n"];
            
            // clear -
            [value_array removeAllObjects];
        }
        
        
        // end -
        [buffer appendString:@"\t</listOfEdges>\n"];
    }
}

-(void)loadNodeArrayIntoBuffer:(NSMutableString *)buffer usingBlueprintDocument:(NSXMLDocument *)document
{
    // Get the path for node array -
    NSError *error;
    NSString *node_array_path = [[[document nodesForXPath:@"//listOfProperties/property[@key='NODE_ARRAY_FILE_PATH']/@value" error:&error] lastObject] stringValue];
    if (node_array_path != nil &&
        error == nil)
    {
        // get points array -
        NSArray *points_array = [VLCoreUtilitiesLib loadGenericFlatFile:node_array_path withRecordDeliminator:@"\n" withFieldDeliminator:@" "];
        
        // build points array text -
        [buffer appendString:@"\n"];
        [buffer appendString:@"\t<listOfNodes>\n"];
        
        // iterate through list of points -
        NSInteger counter = 0;
        for (NSArray *row_array in points_array)
        {
            // array -
            NSMutableArray *value_array = [NSMutableArray array];
            
            // space delimited -
            for (NSString *value_string in row_array)
            {
                if ([value_string isEqualToString:@""]== NO)
                {
                    // grab the value -
                    [value_array addObject:value_string];
                }
            }
            
            // write the line -
            [buffer appendFormat:@"\t\t<node index='%lu' x_value='%@' y_value='%@'/>\n",counter,
             [value_array objectAtIndex:0],
             [value_array objectAtIndex:1]];
            
            // clear -
            [value_array removeAllObjects];
            
            // update counter -
            counter = counter + 1;
        }
        
        // end -
        [buffer appendString:@"\t</listOfNodes>\n"];
    }
}

-(void)loadTriangleArrayIntoBuffer:(NSMutableString *)buffer usingBlueprintDocument:(NSXMLDocument *)document
{
    // Get the path for node array -
    NSError *error;
    NSString *node_array_path = [[[document nodesForXPath:@"//listOfProperties/property[@key='TRIANGLE_ARRAY_FILE_PATH']/@value" error:&error] lastObject] stringValue];
    if (node_array_path != nil &&
        error == nil)
    {
        // get points array -
        NSArray *points_array = [VLCoreUtilitiesLib loadGenericFlatFile:node_array_path withRecordDeliminator:@"\n" withFieldDeliminator:@" "];
        
        // grab the points array -
        self.myTriangleNodeArray = points_array;
        
        // build points array text -
        [buffer appendString:@"\n"];
        [buffer appendString:@"\t<listOfTriangles>\n"];
        
        // Number formatter -
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        // iterate through list of points -
        NSInteger counter = 0;
        for (NSArray *row_array in points_array)
        {
            
            // array -
            NSMutableArray *value_array = [NSMutableArray array];
            
            // space delimited -
            for (NSString *value_string in row_array)
            {
                if ([value_string isEqualToString:@""]== NO)
                {
                    
                    // Convert to a number -
                    NSNumber *number = [formatter numberFromString:value_string];
                    NSString *converted_number = [number stringValue];
                    
                    // grab the value -
                    [value_array addObject:converted_number];                    
                }
            }
                        
            // line -
            [buffer appendFormat:@"\t\t<triangle index='%lu' node_index_1='%@' node_index_2='%@' node_index_3='%@'/>\n",counter,
             [value_array objectAtIndex:0],
             [value_array objectAtIndex:1],
             [value_array objectAtIndex:2]];
            
            // clear -
            [value_array removeAllObjects];
            
            // update counter -
            counter = counter + 1;
        }
        
        // end -
        [buffer appendString:@"\t</listOfTriangles>\n"];
    }
}

-(void)writeGeometryBuffer:(NSMutableString *)buffer usingBlueprintDocument:(NSXMLDocument *)document
{
    // Get the path for the ouput file -
    NSError *error;
    NSString *output_file_path = [[[document nodesForXPath:@"//listOfProperties/property[@key='GEOMETRY_FILE_PATH']/@value" error:&error] lastObject] stringValue];
    if (output_file_path != nil &&
        error == nil)
    {
        [VLCoreUtilitiesLib writeBuffer:buffer toURL:[NSURL URLWithString:output_file_path]];
    }
}

#pragma mark - private lifecycle
-(void)setup
{
    if ([self myArgsArray] == nil)
    {
        self.myArgsArray = [NSMutableArray array];
    }
}

-(void)cleanMyMemory
{
    // Clean my iVars -
    self.myArgsArray = nil;
    self.myTriangleNodeArray = nil;
    
    // Remove me from the NSNotificationCenter -
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
