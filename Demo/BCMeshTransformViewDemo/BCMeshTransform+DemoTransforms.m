//
//  BCMutableMeshTransform+DemoTransforms.m
//  BCMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "BCMeshTransform+DemoTransforms.h"
#import "BCMutableMeshTransform+Convenience.h"
void IFPrint (NSString *format, ...) {
    va_list args;
    va_start(args, format);
    
    fputs([[[NSString alloc] initWithFormat:format arguments:args] UTF8String], stdout);
    
    va_end(args);
}

@implementation BCMeshTransform (DemoTransforms)


+ (instancetype)curtainMeshTransformAtPoint:(CGPoint)point boundsSize:(CGSize)boundsSize
{
    const float Frills = 3;
    
    point.x = MIN(point.x, boundsSize.width);
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:20 numberOfColumns:50];
    
    CGPoint np = CGPointMake(point.x/boundsSize.width, point.y/boundsSize.height);
    
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        float dy = vertex.to.y - np.y;
        float bend = 0.25f * (1.0f - expf(-dy * dy * 10.0f));
        
        float x = vertex.to.x;
        
        vertex.to.z = 0.1 + 0.1f * sin(-1.4f * cos(x * x * Frills * 2.0 * M_PI)) * (1.0 - np.x);
        vertex.to.x = (vertex.to.x) * np.x + vertex.to.x * bend * (1.0 - np.x);
        
        return vertex;
    }];
    
    return transform;
}


+ (instancetype)buldgeMeshTransformAtPoint:(CGPoint)point
                                     withRadius:(CGFloat)radius
                                     boundsSize:(CGSize)size
{
    const CGFloat Bulginess = 0.4;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:36 numberOfColumns:36];
    
    CGFloat rMax = radius/size.width;
    
    CGFloat yScale = size.height/size.width;
    
    CGFloat x = point.x/size.width;
    CGFloat y = point.y/size.height;
    
    NSUInteger vertexCount = transform.vertexCount;
    
    for (int i = 0; i < vertexCount; i++) {
        BCMeshVertex v = [transform vertexAtIndex:i];
        
        CGFloat dx = v.to.x - x;
        CGFloat dy = (v.to.y - y) * yScale;
        
        CGFloat r = sqrt(dx*dx + dy*dy);
        
        if (r > rMax) {
            continue;
        }
        
        CGFloat t = r/rMax;
        
        CGFloat scale = Bulginess*(cos(t * M_PI) + 1.0);
        
        v.to.x += dx * scale;
        v.to.y += dy * scale / yScale;
        v.to.z = scale * 0.2;
        [transform replaceVertexAtIndex:i withVertex:v];
    }
    
    return transform;
}

+ (instancetype)shiverTransformWithPhase:(CGFloat)phase magnitude:(CGFloat)magnitude
{
    const int Slices = 100;

    const float R = M_SQRT2/2.0;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform new];
    
    for (int i = 0; i < Slices; i++) {
        float t = (float)i / (Slices);
        float angle = t * 2.0 * M_PI;
        
        float r = R + magnitude * sin(M_PI * cos(t * 2.0 * M_PI * 2 + phase)) * cos(M_PI * t * 2 + phase);
        
        BCMeshVertex v;
        v.from.x = 0.5 + R * sinf(angle);
        v.from.y = 0.5 + R * cosf(angle);
        
        v.to.x = 0.5 + r * sinf(angle);
        v.to.y = 0.5 + r * cosf(angle);
        v.to.z = 0.0;
        
        [transform addVertex:v];
    }
    
    BCMeshVertex center = (BCMeshVertex) {
        .from = CGPointMake(0.5, 0.5),
        .to = BCPoint3DMake(0.5 + 0.02 * cos(phase), 0.5 + 0.02 * sin(phase), 0.0)
    };
    
    [transform addVertex:center];
    
    for (int i = 0; i < Slices / 2; i++) {
        BCMeshFace face = (BCMeshFace) {
            .indices = {(2*i + 1) % Slices, 2*i, Slices, (2*i + 2) % Slices}
        };
        [transform addFace:face];
    }
    
    return transform;
}


+ (instancetype)ellipseMeshTransform
{
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:30 numberOfColumns:30];
    
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        float x = 2.0 * (vertex.from.x - 0.5f);
        float y = 2.0 * (vertex.from.y - 0.5f);
        
        vertex.to.x = 0.5f + 0.5 * x * sqrt(1.0f - 0.5 * y * y);
        vertex.to.y = 0.5f + 0.5 * y * sqrt(1.0f - 0.5 * x * x);
        return vertex;
        
    }];
    
    return transform;
}


+ (instancetype)rippleMeshTransform
{
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:50 numberOfColumns:50];
    
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        
        float x = vertex.from.x - 0.5f;
        float y = vertex.from.y - 0.5f;
        
        float r = sqrtf(x * x + y * y);
        
        vertex.to.z = 0.05 * sinf(r * 2.0 * M_PI * 4.0);
        
        return vertex;
    }];
    
    return transform;
}

+ (instancetype)identityForSize:(CGSize)size
{
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:size.height numberOfColumns:size.width];
    
    return transform;
}

#pragma mark - Scott Code
#pragma mark - Melt

+ (instancetype)meltTransformIdentity
{
    return [self identityForSize:CGSizeMake(200, 15)];
}

+ (instancetype)meltTransform
{
    
    NSInteger size = 200;
    //our grid is going to be 50w by 70h, 3500 vertices total
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:15 numberOfColumns:size];
    
    //We need to generate a series of control points where the melting will start.
    //A second series of control points will be used to "stop" the melting
    size += 1;
    //in order to have vertical "streakiness", we need to increase the intensity array size by 1
    //we do this because the mesh transform is calculated using rows/columns and we want the vertices.
    //num edges + spaces between columns = size + 1
    NSInteger influence = 12;
    float stepSize = 1.75f;
    NSInteger numControlPoints = 128;
    NSInteger magnification = 5;
    NSInteger magnificationThreshold = 2;
    NSArray<NSNumber *> *intensityArray = [self generateIntensityArrayOfSize:size
                                                            numControlPoints:numControlPoints
                                                                   influence:influence
                                                                    stepSize:stepSize
                                                               magnification:magnification
                                                      magnificationThreshold:magnificationThreshold];
    
    __block NSUInteger highestVertex = 0;
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        NSInteger vertexXCoord = vertexIndex%size;
        NSInteger vertexYCoord = vertexIndex/size;
        if (vertexXCoord == 0 || vertexXCoord == size) return vertex;
        
        float modifier = [intensityArray[vertexIndex%size] floatValue] / (float)size;
        float lowerModifier = MIN(vertexYCoord, influence);
        float upperModifier = MIN(size - vertexYCoord, influence);
        float modifierModifier = MIN(lowerModifier, upperModifier) / influence;
        float newModifier = modifier * modifierModifier;
        
        vertex.to.y = MIN(vertex.to.y + newModifier, 1.0f);
//        vertex.to.z = modifier * 0.5;
        
        if (vertexIndex > highestVertex) highestVertex = vertexIndex;
        return vertex;
    }];
    
    return transform;
}

+ (NSSet<NSNumber *> *)generateControlPointsForSize:(NSInteger)size
                       numControlPoints:(NSInteger)numControlPoints
                              influence:(NSInteger)influence {
    NSMutableSet<NSNumber *> *xCoordsSet = [[NSMutableSet<NSNumber *> alloc] init];
    for (int i = 0; i < numControlPoints; i++) {
        NSUInteger newCoord = arc4random_uniform((int)(size - (influence * 2)));
        
        [xCoordsSet addObject:@(newCoord + influence)];
    }
    
    return xCoordsSet;
}



+ (NSArray<NSNumber *> *)generateIntensityArrayOfSize:(NSInteger)size
                                     numControlPoints:(NSInteger)numControlPoints
                                            influence:(NSInteger)influence
                                             stepSize:(float)stepSize
                                        magnification:(NSInteger)magnification
                               magnificationThreshold:(NSInteger)magnificationThreshold {
    NSSet<NSNumber *> *controlPoints = [self generateControlPointsForSize:size
                                                         numControlPoints:numControlPoints
                                                                influence:influence];
    
    NSArray<NSNumber *> *intensityArray = [self generateIntensityArrayForControlPointSet:controlPoints
                                                                                 forSize:size
                                                                               influence:influence
                                                                                stepSize:stepSize
                                                                           magnification:magnification
                                                                  magnificationThreshold:magnificationThreshold];
    
    return intensityArray;
}

+ (NSArray<NSNumber *> *)generateIntensityArrayForControlPointSet:(NSSet *)controlPointSet
                                                          forSize:(NSInteger)size
                                                        influence:(NSInteger)influence
                                                         stepSize:(float)stepSize
                                                    magnification:(NSInteger)magnification
                                           magnificationThreshold:(NSInteger)magnificationThreshold {
    NSInteger retVal[size];
    
    for (int i = 0; i < size; i++) {
        retVal[i] = 0;
    }
    
    for (NSNumber *controlPoint in controlPointSet) {
        if ([controlPoint isKindOfClass:[NSNumber class]]) {
            NSInteger controlPointInt = controlPoint.integerValue;
            NSInteger tempInfluence = influence;
            NSInteger tempMagnificationCounter = magnificationThreshold;
            while (tempInfluence >= 0) {
                if (controlPointInt - tempInfluence >= 0 && controlPointInt + tempInfluence < size) {
                    for (NSInteger i = controlPointInt - tempInfluence; i < controlPointInt + tempInfluence; i++) {
                        retVal[i] += stepSize;
                        
                        if (tempMagnificationCounter == 0) retVal[i] += magnification;
                    }
                }
                
                tempInfluence -= 1;
                tempMagnificationCounter -= 1;
            }
        }
    }
    
    for (int i = 0; i < size; i++) {
        IFPrint(@"%d", retVal[i]);
    }
    
    //now we have an array that has numbers based on how fucked things are.
    //to emphasize, we can leave 0's and 1's as is, and make everything else increased by some arbitrary value
    NSMutableArray<NSNumber *> *retValObjC = [[NSMutableArray<NSNumber *> alloc] init];
    for (int i = 0; i < size; i++) {
        [retValObjC addObject:@(retVal[i])];
    }
    
    return retValObjC;
}

#pragma mark - Water Drip

+ (CGSize)dripTransformSize {
    return CGSizeMake(200, 200);
}

+ (instancetype)dripTransformIdentity {
    return [self identityForSize:[self dripTransformSize]];
}

+ (instancetype)dripTransform {
    CGSize ourTransformSize = [self dripTransformSize];
    NSInteger ourHeight = ourTransformSize.height;
    NSInteger ourWidth = ourTransformSize.width;
    //our grid is going to be 50w by 70h, 3500 vertices total
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:ourHeight numberOfColumns:ourWidth];
    
    ourTransformSize.width = ourTransformSize.width + 1;
    //We need to generate a series of control points where the melting will start.
    //A second series of control points will be used to "stop" the melting
//    ourWidth = ourWidth + 1;
    //in order to have vertical "streakiness", we need to increase the intensity array size by 1
    //we do this because the mesh transform is calculated using rows/columns and we want the vertices.
    //num edges + spaces between columns = size + 1
    NSInteger influence = 12;
    float stepSize = 1.75f;
    NSInteger numControlPoints = 128;
    NSInteger magnification = 5;
    NSInteger magnificationThreshold = 2;
    NSArray<NSNumber *> *intensityArray = [self generateDripIntensityArrayForSize:ourTransformSize
                                                                 numControlPoints:12
                                                                           margin:5
                                                                        influence:10
                                                                             base:9.0f
                                                                         stepSize:10.0f
                                                                    dripMinLength:60
                                                                    dripMaxLength:80];
    
    __block NSUInteger highestVertex = 0;
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        if (vertexIndex > highestVertex) highestVertex = vertexIndex;
        NSInteger vertexXCoord = vertexIndex%ourWidth;
        NSInteger vertexYCoord = vertexIndex/ourWidth;
        if (vertexIndex >= intensityArray.count) return vertex;
        if (vertexXCoord == 0 || vertexXCoord == ourWidth) return vertex;
        
        float modifier = [intensityArray[vertexIndex] floatValue] / (float)ourWidth;
        float lowerModifier = MIN(vertexYCoord, influence);
        float upperModifier = MIN(ourWidth - vertexYCoord, influence);
        float modifierModifier = MIN(lowerModifier, upperModifier) / influence;
        float newModifier = modifier * modifierModifier;
        
        vertex.to.y = MIN(vertex.to.y + newModifier, 1.0f);
        vertex.to.z = modifier*2;
        
        if (vertexIndex > highestVertex) highestVertex = vertexIndex;
        return vertex;
    }];
    
    return transform;
}

+ (NSSet<NSValue *> *)generateDripControlPointsForSize:(CGSize)size
                                      numControlPoints:(NSInteger)numControlPoints
                                                margin:(NSInteger)margin {
    NSMutableSet<NSValue *> *xCoordsSet = [[NSMutableSet<NSValue *> alloc] init];
    for (int i = 0; i < numControlPoints; i++) {
        NSUInteger newCoordX = arc4random_uniform((int)(size.width - (margin * 2)));
        NSUInteger newCoordY = arc4random_uniform((int)((size.height - (margin * 2)) / 2)); // divide by two to only include on top half
        
        CGPoint ourPoint = CGPointMake(newCoordX + margin, newCoordY + margin);
        NSValue *ourValue = [NSValue valueWithCGPoint:ourPoint];
        [xCoordsSet addObject:ourValue];
    }
    
    return xCoordsSet;
}

+ (NSArray<NSNumber *> *)generateDripIntensityArrayForSize:(CGSize)size
                                          numControlPoints:(NSInteger)numControlPoints
                                                    margin:(NSInteger)margin
                                                 influence:(NSInteger)influence
                                                      base:(float)base
                                                  stepSize:(float)stepSize
                                             dripMinLength:(NSInteger)dripMinLength
                                             dripMaxLength:(NSInteger)dripMaxLength {
    NSSet<NSValue *> *dripControlPoints = [self generateDripControlPointsForSize:size
                                                                numControlPoints:numControlPoints
                                                                          margin:margin];

    //For example, height should be the page.  Accessing (3,4) with a width of 5 should access item 23
    float dripHeightArray[(int)size.height * (int)size.width];
    
    for (int i = 0; i < (int)size.width * (int)size.height; i++) {
        dripHeightArray[i] = 0;
    }
    
    //for each of the control points, form an elevated cylinder with capped ends around it.
    //To simplify, draw cylinder first
    for(NSValue *pointValue in dripControlPoints) {
        NSInteger dripLength = arc4random_uniform((int)(dripMaxLength - dripMinLength)) + dripMinLength;
        CGPoint point = pointValue.CGPointValue;
        
        for (int y = point.y; y < point.y + dripLength; y++) {
            for (int x = point.x - influence; x < point.x + influence; x++) {
                float stepSizeToUse = stepSize * (1.0 - powf(0.5, (influence + 1 - ABS(x - point.x))));
                dripHeightArray[y*(int)size.width + x] = MAX(base + stepSizeToUse, dripHeightArray[y*(int)size.width + x]);
            }
        }
        
        if (influence * 2 / 3 > 0) {
            for (NSInteger i = 1; i < influence * 2 / 3; i++) {
                int y1 = point.y - i;
                int y2 = point.y + dripLength + i;
                NSInteger tempInfluence = influence - i;
                for (int x = point.x - tempInfluence; x < point.x + tempInfluence; x++) {
                    float stepSizeToUse = stepSize * (1.0 - powf(0.5, (influence + 1 - ABS(x - point.x))));
                    dripHeightArray[y1*(int)size.width + x] = MAX(base + stepSizeToUse, dripHeightArray[y1*(int)size.width + x]);
                    dripHeightArray[y2*(int)size.width + x] = MAX(base + stepSizeToUse, dripHeightArray[y2*(int)size.width + x]);
                }
            }
        }
    }
    
    NSMutableArray<NSNumber *> *retVal = [[NSMutableArray<NSNumber *> alloc] init];
    for (int i = 0; i < (int)size.height * (int)size.width; i++) {
        [retVal addObject:@(dripHeightArray[i])];
    }
    
    return retVal;
}



@end
