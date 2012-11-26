//
//  ViewController.m
//  DrawMe
//
//  Created by Денис Ромашов on 13.11.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import "RootViewController.h"
#import "DrawView.h"

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


@interface RootViewController ()
{
    DrawView *_drawView;
    UIImageView *_paletteView;
    UIImage *_paletteImage;
    UIImage *_cleanImage;
    
    CGColorRef _currentColor;
    
    NSMutableArray *_pointsList;
    NSInteger pointsCount;

    BOOL isPaletteOpend;
    BOOL isOneFingerTal;
}
@end


@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.viewForDraw setUserInteractionEnabled:YES];
    _pointsList = [NSMutableArray array];
    _currentColor = [UIColor blueColor].CGColor;
    
    _drawView = [DrawView new];
    [_drawView setWidth:kUsualWidth];
    [_drawView setColor:_currentColor];
    
    _drawView.imageView = self.viewForDraw;
    
    _paletteView = [[UIImageView alloc] initWithFrame:CGRectMake(_drawView.imageView.frame.size.width + kPaletteButtonWidth*6, 0, kPaletteViewWidth, kPaletteViewHeight)];

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
    [crayonButton setFrame:CGRectMake(kPaletteButtonPosition, kPaletteToolButtonPosition+40, kPaletteButtonWidth,kPaletteButtonHeight)];
    [crayonButton setTitle:@"Crayon" forState:UIControlStateNormal];
    [crayonButton addTarget:self action:@selector(crayonButtonDidPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *eraseButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [eraseButton setFrame:CGRectMake(kPaletteButtonPosition, kPaletteToolButtonPosition+80, kPaletteButtonWidth,kPaletteButtonHeight)];
    [eraseButton setTitle:@"Erase" forState:UIControlStateNormal];
    [eraseButton addTarget:self action:@selector(eraseButtonDidPressed:) forControlEvents:UIControlStateNormal];
    
    _paletteView.image = _paletteImage;
    
    [_paletteView addSubview:colorButton];
    [_paletteView addSubview:penButton];
    [_paletteView addSubview:crayonButton];
    [_paletteView addSubview:eraseButton];
    _paletteView.userInteractionEnabled = YES;
    
    
    [_drawView.imageView addSubview:_paletteView];
    
    

    isPaletteOpend = NO;
    
    pointsCount = [_pointsList count];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                               action:@selector(showPalette)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
}

#pragma mark - Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    [self touchPosition:touches];
    
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
        if (!pointsCount) {
            pointsCount = 0;
        }

    [self touchPosition:touches];
    [_drawView drawLineFromPoint:[[_pointsList objectAtIndex:pointsCount] CGPointValue]
                             toPoint:[[_pointsList objectAtIndex:pointsCount+1] CGPointValue]];
    pointsCount++;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];

    [self touchPosition:touches];
    
    NSArray *generalizedPoints = [self douglasPeucker:_pointsList epsilon:2];
    NSArray *splinePoints = [self catmullRomSpline:generalizedPoints segments:4];
    
    [_drawView drawPath: _drawView.imageView WithPoints:splinePoints andColor:_currentColor];
   
    [_pointsList removeAllObjects];
    pointsCount = [_pointsList count];

}

#pragma mark - Motion
#warning Use NSNotificationCenter!!!

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionEnded:motion withEvent:event];
    
    if (event.type == UIEventSubtypeMotionShake) {
        [_drawView clearView];
       
    }
     NSLog(@"sheake!");
}

#pragma mark - Get current position

-(void)touchPosition:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.viewForDraw];
    [_pointsList addObject:[NSValue valueWithCGPoint:point]];
}

#pragma mark - Action Buttons
-(IBAction)test:(id)sender {
    [_pointsList removeAllObjects];
    pointsCount = [_pointsList count];
    [_drawView clearView];
}

-(void)penButtonDidPressed:(UIButton*)button
{
    [_drawView setWidth: kPenWidth];
}
-(void)crayonButtonDidPressed:(UIButton*)button
{
    [_drawView setWidth: kCrayonWidth];
}
-(void)eraseButtonDidPressed:(UIButton*)button
{
    _currentColor = whiteColor.CGColor;
}
-(void)greenColorButtonDidPassed:(UIButton*)button
{
    
}
#pragma mark - Drawing Smooth
- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon
{
    int count = [points count];
    if(count < 3) {
        return points;
    }
    
    //Find the point with the maximum distance
    float dmax = 0;
    int index = 0;
    for(int i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        float d = [self perpendicularDistance:point lineA:lineA lineB:lineB];
        if(d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    //If max distance is greater than epsilon, recursively simplify
    NSArray *resultList;
    if(dmax > epsilon) {
        NSArray *recResults1 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)] epsilon:epsilon];
        
        NSArray *recResults2 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)] epsilon:epsilon];
        
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:recResults1];
        [tmpList removeLastObject];
        [tmpList addObjectsFromArray:recResults2];
        resultList = tmpList;
    } else {
        resultList = [NSArray arrayWithObjects:[points objectAtIndex:0], [points objectAtIndex:count - 1],nil];
    }
    
    return resultList;
}

- (float)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB
{
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}

- (NSArray *)catmullRomSpline:(NSArray *)points segments:(int)segments
{
    int count = [points count];
    if(count < 4) {
        return points;
    }
    
    float b[segments][4];
    {
        // precompute interpolation parameters
        float t = 0.0f;
        float dt = 1.0f/(float)segments;
        for (int i = 0; i < segments; i++, t+=dt) {
            float tt = t*t;
            float ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    {
        int i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    for (int i = 1; i < count-2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    {
        int i = count-2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]];
    
    return resultArray;
}


#pragma mark - DoubleTap

-(void)showPalette
{
    if (!isPaletteOpend) {
        [UIView animateWithDuration:1 animations:^{
            [_paletteView setFrame:CGRectMake(_drawView.imageView.frame.size.width - _paletteView.frame.size.width,
                                              _paletteView.frame.origin.y,
                                              _paletteView.frame.size.width,
                                              _paletteView.frame.size.height)];

        }];
        isPaletteOpend = YES;
    }
    
    else {
        [self hidePalette];
        isPaletteOpend = NO;
    }
    
    [_pointsList removeAllObjects];
    pointsCount = [_pointsList count];

}

-(void)hidePalette
{
    [UIView animateWithDuration:1 animations:^{
        [_paletteView setFrame:CGRectMake(_drawView.imageView.frame.size.width + _paletteView.frame.size.width,
                                          _paletteView.frame.origin.y,
                                          _paletteView.frame.size.width,
                                          _paletteView.frame.size.height)];
    }];
}
@end