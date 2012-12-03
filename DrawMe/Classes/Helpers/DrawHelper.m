//
//  drawView.m
//  DrawMe
//
//  Created by Денис Ромашов on 13.11.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import "DrawHelper.h"

@interface DrawHelper ()
{
    UIImage *_currentImage;
    UIImage *_clearImage;
    UIImage *_emptyImage;
    BOOL _isClearImage;
}

-(void)drawLineFromPoint:(CGPoint)pt toPoint:(CGPoint)pt2;
-(void)drawLineOnView:(UIView *)onView fromPoint:(CGPoint)fromPt toPoint:(CGPoint)toPt;
-(void)drawPath:(UIView *)onView WithPoints:(NSArray *)points andColor:(CGColorRef)colorRef;

-(void)combineImage:(UIImage*)overlayImage;

-(void)clearView;

@end


@implementation DrawHelper


#pragma mark -
#pragma mark Drawing
-(void)drawLineFromPoint:(CGPoint)pt toPoint:(CGPoint)pt2
{
    [self drawLineOnView:_imageView fromPoint:pt toPoint:pt2];
}

-(void)drawLineOnView:(UIView *)onView fromPoint:(CGPoint)fromPt toPoint:(CGPoint)toPt
{  
    UIGraphicsBeginImageContext(onView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetStrokeColorWithColor(context, _color);
    CGContextSetLineWidth(context, _width);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, fromPt.x, fromPt.y);
    CGContextAddLineToPoint(context, toPt.  x, toPt.y);
    CGContextStrokePath(context);
    
    [self combineImage:UIGraphicsGetImageFromCurrentImageContext()];
    
    UIGraphicsEndImageContext();
}

#pragma mark - Smooth Line Draw
-(void)drawPath:(UIView *)onView WithPoints:(NSArray *)points andColor:(CGColorRef)colorRef
{
    UIGraphicsBeginImageContext(onView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetStrokeColorWithColor(context, colorRef);
	CGContextSetLineWidth(context, _width);

	CGContextBeginPath(context);
    
    int count = [points count];
    CGPoint point = [[points objectAtIndex:0] CGPointValue];
	CGContextMoveToPoint(context, point.x, point.y);
    for(int i = 1; i < count; i++) {
        point = [[points objectAtIndex:i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
    _isClearImage = YES;
  
    [self combineImage:UIGraphicsGetImageFromCurrentImageContext()];

	UIGraphicsEndImageContext();
}

#pragma mark -
#pragma mark Image Saving
-(void)combineImage:(UIImage*)overlayImage
{
    if (!_currentImage) {
        _currentImage = [UIImage new];
        _clearImage   = [UIImage new];
    }
    UIGraphicsBeginImageContext(overlayImage.size);
    
    if (_isClearImage) {
        [_clearImage drawAtPoint:CGPointZero];
        CGRect imageRect = CGRectMake(0, 0, overlayImage.size.width, overlayImage.size.height);
        [overlayImage drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0];

        _clearImage  = UIGraphicsGetImageFromCurrentImageContext();
        [_imageView setImage:_clearImage];

        _isClearImage = NO;
    } else {
        [[_imageView image] drawAtPoint:CGPointZero];
        CGRect imageRect = CGRectMake(0, 0, overlayImage.size.width, overlayImage.size.height);
        [overlayImage drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0];

        _currentImage = UIGraphicsGetImageFromCurrentImageContext();
        [_imageView setImage:_currentImage];
    }
    UIGraphicsEndImageContext();
}

#pragma mark -
#pragma mark Clearing

-(void)clearView
{
    if (!_emptyImage) {
        _emptyImage = [UIImage new];
    }
    _clearImage   = _emptyImage;
    _currentImage = _emptyImage;
    [_imageView setImage:_currentImage];
}

@end;
