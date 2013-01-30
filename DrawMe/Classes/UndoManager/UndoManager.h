//
//  UndoManager.h
//  DrawMe
//
//  Created by Денис Ромашов on 10.12.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UndoManager : NSObject

-(void)addObject:(NSArray*)array;
-(NSArray*)undoObject;
-(NSArray*)redoObject;

-(void)clearManager;

@end
