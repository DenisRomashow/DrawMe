//
//  LineSmoother.h
//  DrawMe
//
//  Created by Денис Ромашов on 03.12.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LineSmoother : NSObject

- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon;
- (NSArray *)catmullRomSpline:(NSArray *)points segments:(int)segments;

@end
