//
//  drawView.h
//  DrawMe
//
//  Created by Денис Ромашов on 13.11.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGColorRef color;
@property (nonatomic, assign) CGFloat width;


- (void)drawLineFromPoint:(CGPoint)pt toPoint:(CGPoint)pt2;

- (void)drawPath:(UIView *)onView WithPoints:(NSArray *)points andColor:(CGColorRef)colorRef;

- (void)clearView;
@end
