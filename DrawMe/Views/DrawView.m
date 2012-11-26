//
//  drawView.m
//  DrawMe
//
//  Created by Денис Ромашов on 13.11.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import "DrawView.h"

@interface DrawView ()
{
    UIImage *_currentImage;
    UIImage *_clearImage;
    UIImage *_emptyImage;
    BOOL isClearImage;
}
@end


@implementation DrawView

- (void)drawLineFromPoint:(CGPoint)pt toPoint:(CGPoint)pt2
{
    [self drawLinetoPoints:_imageView fromPoint:pt toPoint:pt2];
}
#pragma mark -
#pragma mark Drawing

-(void)drawLinetoPoints:(UIView *)onView fromPoint:(CGPoint)fromPt toPoint:(CGPoint)toPt
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
- (void)drawPath:(UIView *)onView WithPoints:(NSArray *)points andColor:(CGColorRef)colorRef
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
    isClearImage = YES;
  
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

    UIGraphicsBeginImageContext(self.frame.size);
    
    if (isClearImage) {
        [_clearImage drawAtPoint:CGPointZero];
        CGRect imageRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [overlayImage drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0];

        _clearImage  = UIGraphicsGetImageFromCurrentImageContext();
        [_imageView setImage:_clearImage];

        isClearImage = NO;
    }
    else {
        [[_imageView image] drawAtPoint:CGPointZero];
        CGRect imageRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [overlayImage drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0];

        _currentImage = UIGraphicsGetImageFromCurrentImageContext();
        [_imageView setImage:_currentImage];
    }
    
    UIGraphicsEndImageContext();
}

#pragma mark -
#pragma mark Claering

-(void)clearView {
    if (!_emptyImage) {
        _emptyImage = [UIImage new];
    }
    _clearImage   = _emptyImage;
    _currentImage = _emptyImage;
    [_imageView setImage:_currentImage];
}

@end;
