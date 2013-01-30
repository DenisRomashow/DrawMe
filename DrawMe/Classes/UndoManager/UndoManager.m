//
//  UndoManager.m
//  DrawMe
//
//  Created by Денис Ромашов on 10.12.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import "UndoManager.h"

@interface UndoManager ()
{
    NSMutableArray *_undoArray;
    int _redoCount;
    BOOL _usedUndo;
}

-(void)addObject:(NSArray*)array;
-(NSArray*)undoObject;
-(NSArray*)redoObject;

-(void)clearManager;

@end

@implementation UndoManager
-(id)init
{
    self = [super init];
    if (self) {
        _undoArray = [NSMutableArray array];
    }
    return self;
}

-(void)addObject:(NSArray *)array
{
    if (_usedUndo) {
        [self clearManager];
        _usedUndo=NO;
    }
    [_undoArray addObject:array];
    _redoCount = [_undoArray count]-1;
}

-(NSArray*)undoObject
{
    if (_redoCount < [_undoArray count]) {
        _usedUndo = YES;
        NSIndexSet *index = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _redoCount--)];
        return [_undoArray objectsAtIndexes:index];
    } else {
        [self clearManager];
        return _undoArray;
    }
}

-(NSArray*)redoObject
{
    if ([_undoArray count ] >_redoCount) {
        NSIndexSet *index = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _redoCount++)];
        return [_undoArray objectsAtIndexes:index];
    } else {
        return nil;
    }
}

-(void)clearManager
{
    _redoCount = 0;
    [_undoArray removeAllObjects];
}
@end