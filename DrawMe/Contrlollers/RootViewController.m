//
//  ViewController.m
//  DrawMe
//
//  Created by Денис Ромашов on 13.11.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import "RootViewController.h"
#import "DrawHelper.h"
#import "LineSmoother.h"

#define redColor [UIColor redColor]
#define blackColor [UIColor blackColor]
#define yellowColor [UIColor yellowColor]
#define greenColor [UIColor greenColor]
#define whiteColor [UIColor whiteColor]

static const CGFloat kPaletteViewWidth    = 120;
static const CGFloat kPaletteViewHeight   = 320;

static const CGFloat kPaletteButtonPosition = 10;
static const CGFloat kPaletteToolButtonPosition = 195;
static const CGFloat kPaletteButtonWidth  = 100;
static const CGFloat kPaletteButtonHeight = 31;

static const CGFloat kPenWidth    = 2;
static const CGFloat kCrayonWidth = 7;
static const CGFloat kUsualWidth  = 3;

static const int kEpsilontNumber = 2;
static const int kSegmentsNumber = 4;


@interface RootViewController ()
{
    DrawHelper *_drawHelper;
    LineSmoother *_lineSmoother;
    
    UIImageView *_paletteView;
    UIImage *_paletteImage;
    UIImage *_cleanImage;
    
    CGColorRef _currentColor;
    
    NSMutableArray *_pointsList;
    NSInteger _pointsCount;

    BOOL _isPaletteOpened;
    BOOL _isOneFingerTal;
}

-(void)loadPaletteViewItems;

-(void)penButtonDidPressed:(UIButton*)button;
-(void)crayonButtonDidPressed:(UIButton*)button;
-(void)eraseButtonDidPressed:(UIButton*)button;

-(void)showPalette:(UITapGestureRecognizer *)gestRecognizer;
-(void)hidePalette;

@end


@implementation RootViewController

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.viewForDraw setUserInteractionEnabled:YES];
    _pointsList = [NSMutableArray array];
    _currentColor = [UIColor blueColor].CGColor;
    
    _drawHelper = [DrawHelper new];
    [_drawHelper setWidth:kUsualWidth];
    [_drawHelper setColor:_currentColor];
    _drawHelper.imageView = self.viewForDraw;
    
    _lineSmoother = [LineSmoother new];
    
    _paletteView = [[UIImageView alloc] initWithFrame:CGRectMake(_drawHelper.imageView.frame.size.width + kPaletteButtonWidth * kCrayonWidth,
                                                                 0,
                                                                 kPaletteViewWidth,
                                                                 kPaletteViewHeight)];
    _paletteView.userInteractionEnabled = NO;
    
    [self loadPaletteViewItems];
    
    [_drawHelper.imageView addSubview:_paletteView];
    
    _isPaletteOpened = NO;
    _pointsCount = [_pointsList count];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                               action:@selector(showPalette:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
}


#pragma mark - addToViewDidLoad
-(void)loadPaletteViewItems
{
    _paletteImage = [UIImage imageNamed:@"paletteViewImage.png"];
    
    UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [colorButton setFrame:CGRectMake(kPaletteButtonPosition, kPaletteButtonPosition, kPaletteButtonWidth,kPaletteButtonHeight)];
    [colorButton setTitle:@"color" forState:UIControlStateNormal];
    [colorButton addTarget:self action:@selector(greenColorButtonDidPassed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *penButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [penButton setFrame:CGRectMake(kPaletteButtonPosition, kPaletteToolButtonPosition, kPaletteButtonWidth,kPaletteButtonHeight)];
    [penButton setTitle:@"Pen" forState:UIControlStateNormal];
    [penButton addTarget:self action:@selector(penButtonDidPressed:)
        forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *crayonButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [crayonButton setFrame:CGRectMake(kPaletteButtonPosition, kPaletteToolButtonPosition + 40, kPaletteButtonWidth,kPaletteButtonHeight)];
    [crayonButton setTitle:@"Crayon" forState:UIControlStateNormal];
    [crayonButton addTarget:self action:@selector(crayonButtonDidPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *eraseButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [eraseButton setFrame:CGRectMake(kPaletteButtonPosition, kPaletteToolButtonPosition + 80, kPaletteButtonWidth,kPaletteButtonHeight)];
    [eraseButton setTitle:@"Erase" forState:UIControlStateNormal];
    [eraseButton addTarget:self action:@selector(eraseButtonDidPressed:) forControlEvents:UIControlStateNormal];
    
    [_paletteView setImage:_paletteImage];
    [_paletteView setUserInteractionEnabled:YES];
    
    [_paletteView addSubview:colorButton];
    [_paletteView addSubview:penButton];
    [_paletteView addSubview:crayonButton];
    [_paletteView addSubview:eraseButton];
}
#pragma mark - Get current position
-(void)touchPosition:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.viewForDraw];
    [_pointsList addObject:[NSValue valueWithCGPoint:point]];
}

#pragma mark - Touches
-(BOOL)isPaletteViewTouched:(NSSet*)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_paletteView];
    if (point.x > 0 && point.y > 0) {
        return YES;
    }
    return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    if (![self isPaletteViewTouched:touches]) {
        [self touchPosition:touches];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!_pointsCount) {
        _pointsCount = 0;
    }
    if (![self isPaletteViewTouched:touches]) {
        [self touchPosition:touches];
        if ([_pointsList count] > _pointsCount+1) {
            [_drawHelper drawLineFromPoint:[[_pointsList objectAtIndex:_pointsCount] CGPointValue]
                                   toPoint:[[_pointsList objectAtIndex:_pointsCount+1] CGPointValue]];
            _pointsCount++;
        }
    } else {
        [self touchesEnded:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self touchPosition:touches];
        
    NSArray *generalizedPoints = [_lineSmoother douglasPeucker:_pointsList epsilon:kEpsilontNumber];
    NSArray *splinePoints = [_lineSmoother catmullRomSpline:generalizedPoints segments:kSegmentsNumber];
        
    [_drawHelper drawPath: _drawHelper.imageView WithPoints:splinePoints andColor:_currentColor];
    
    [_pointsList removeAllObjects];
    _pointsCount = [_pointsList count];
}

#pragma mark - Motion
#warning Use NSNotificationCenter!!!
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionEnded:motion withEvent:event];
    if (event.type == UIEventSubtypeMotionShake) {
        [_drawHelper clearView];
    }
}

#pragma mark - Action Buttons
-(void)penButtonDidPressed:(UIButton*)button
{
    [_drawHelper setWidth: kPenWidth];
}

-(void)crayonButtonDidPressed:(UIButton*)button
{
    [_drawHelper setWidth: kCrayonWidth];
}

-(void)eraseButtonDidPressed:(UIButton*)button
{
    _currentColor = whiteColor.CGColor;
}

-(void)greenColorButtonDidPassed:(UIButton*)button
{
    
}

#pragma mark - DoubleTap
-(void)showPalette:(UITapGestureRecognizer *)gestRecognizer
{
    CGPoint palletTap = [gestRecognizer locationInView:_paletteView];

    if (palletTap.x > 0 && palletTap.y > 0) {    
        return;
    }
    
    if (!_isPaletteOpened)
    {
        [UIView animateWithDuration:1 animations:^{
            [_paletteView setFrame:CGRectMake(_drawHelper.imageView.frame.size.width - kPaletteViewWidth,
                                              _paletteView.frame.origin.y,
                                              _paletteView.frame.size.width,
                                              _paletteView.frame.size.height)];
        }];
        _isPaletteOpened = YES;
    } else {
        [self hidePalette];
        _isPaletteOpened = NO;
    }
    [_pointsList removeAllObjects];
    _pointsCount = [_pointsList count];
}

-(void)hidePalette
{
    [UIView animateWithDuration:1 animations:^{
        [_paletteView setFrame:CGRectMake(_drawHelper.imageView.frame.size.width + kPaletteViewWidth,
                                          _paletteView.frame.origin.y,
                                          _paletteView.frame.size.width,
                                          _paletteView.frame.size.height)];
    }];
}
@end