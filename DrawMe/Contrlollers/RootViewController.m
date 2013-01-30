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
#import "UndoManager.h"
#import "Social/Social.h"

#define blackColor  [UIColor blackColor]
#define redColor    [UIColor redColor]
#define yellowColor [UIColor yellowColor]
#define greenColor  [UIColor greenColor]
#define blueColor   [UIColor blueColor]
#define orangeColor [UIColor orangeColor]
#define purpleColor [UIColor purpleColor]

#define iPhone5PaletteCenter CGPointMake(630, 160)
#define iPhonePaletterCenter CGPointMake(540, 160)

#define paletteImage [UIImage imageNamed:@"paletteViewImage.png"]

static const CGFloat kPaletteViewWidth    = 120;
static const CGFloat kPaletteViewHeight   = 320;

static const CGFloat kPaletteButtonPosition = 10;
static const CGFloat kPaletteToolButtonPosition = 195;
static const CGFloat kPaletteButtonWidth  = 100;
static const CGFloat kPaletteButtonHeight = 31;

static const CGFloat kPenWidth    = 2;
static const CGFloat kCrayonWidth = 7;
static const CGFloat kUsualWidth  = 3;

static const CGFloat kTableHeight = 31;

static const int kEpsilontNumber = 2;
static const int kSegmentsNumber = 4;



@interface RootViewController ()
{
    DrawHelper *_drawHelper;
    LineSmoother *_lineSmoother;
    UndoManager *_undoManager;
    
    UIImageView *_paletteView;
    CGPoint _paletteCenter;
    
    UITableView *_colorsTableView;
    
    UIColor *_currentColor;
    
    NSArray *_textColorList;
    
    NSMutableArray *_pointsList;
    NSInteger _pointsCount;

    BOOL _isPaletteOpened;
    BOOL _isColorTableOpened;
}

-(void)loadPaletteViewItems;

-(void)penButtonDidPressed:(UIButton*)button;
-(void)crayonButtonDidPressed:(UIButton*)button;
-(void)eraseButtonDidPressed:(UIButton*)button;

-(void)showPalette:(UITapGestureRecognizer *)gestRecognizer;
-(void)hidePalette;
//-(void)hideRedoButton;

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
    _currentColor = blueColor;
    
    _drawHelper = [DrawHelper new];
    [_drawHelper setWidth:kUsualWidth];
    [_drawHelper setColor:_currentColor.CGColor];
    _drawHelper.imageView = self.viewForDraw;
    
    _lineSmoother = [LineSmoother new];
    _undoManager = [UndoManager new];

    _paletteView = [[UIImageView alloc] initWithFrame:CGRectMake(_drawHelper.imageView.frame.size.width + kPaletteButtonWidth * kCrayonWidth,
                                                                 0,
                                                                 kPaletteViewWidth,
                                                                 kPaletteViewHeight)];
    
    _colorsTableView = [[UITableView alloc] initWithFrame:CGRectMake(kPaletteButtonPosition-5,
                                                                     kPaletteButtonPosition,
                                                                     kPaletteButtonWidth,
                                                                     kPaletteButtonHeight*5)];
    [_colorsTableView setDelegate:self];
    [_colorsTableView setDataSource:self];
    
    _textColorList = [[NSArray alloc] initWithObjects:blackColor,redColor,greenColor,yellowColor,blueColor,orangeColor,purpleColor, nil];
    [self loadPaletteViewItems];
    
    _isPaletteOpened    = NO;
    _isColorTableOpened = NO;
    _pointsCount = [_pointsList count];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                               action:@selector(showPalette:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [_drawHelper.imageView addSubview:_paletteView];
    [_drawHelper.imageView addGestureRecognizer:doubleTap];
}


#pragma mark - addToViewDidLoad
-(void)loadPaletteViewItems
{
    UIView *colorView = [[UIView alloc]  initWithFrame:CGRectMake(kPaletteButtonPosition,
                                                                  kPaletteButtonPosition,
                                                                  kPaletteButtonWidth,
                                                                  kPaletteButtonHeight*5)];
    if (self.view.frame.size.height == 568) {
        _paletteCenter = iPhone5PaletteCenter;
    } else {
        _paletteCenter = iPhonePaletterCenter;
    }
    _paletteView.center = _paletteCenter;
    
    [_colorsTableView setShowsVerticalScrollIndicator:NO];
    [_colorsTableView setShowsHorizontalScrollIndicator:NO];
    
    _colorsTableView.rowHeight = kTableHeight;
    _colorsTableView.backgroundColor = [UIColor clearColor];
    _colorsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
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
    [eraseButton addTarget:self action:@selector(eraseButtonDidPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [_paletteView setImage:paletteImage];
    [_paletteView setUserInteractionEnabled:YES];
    
    [_paletteView addSubview:penButton];
    [_paletteView addSubview:crayonButton];
    [_paletteView addSubview:eraseButton];
    [colorView addSubview:_colorsTableView];

    [_paletteView addSubview:colorView];
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
        
    NSArray *generalizedPoints = [_lineSmoother douglasPeucker:_pointsList
                                                       epsilon:kEpsilontNumber];
    NSArray *splinePoints = [_lineSmoother catmullRomSpline:generalizedPoints
                                                   segments:kSegmentsNumber];
    [_undoManager addObject:splinePoints];
    [_drawHelper drawPath:_drawHelper.imageView
               WithPoints:splinePoints
                 andColor:_currentColor.CGColor];
    
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

#pragma mark - TableView 
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_textColorList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor  = [_textColorList objectAtIndex:[indexPath item]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(44, 5, 100, 100)];
    backgroundImage.image = [UIImage imageNamed:@"check.png"];
    
    [cell setSelected:YES animated:YES];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [cell.selectedBackgroundView addSubview:backgroundImage];

    _currentColor = [_textColorList objectAtIndex:[indexPath item]];
    [_drawHelper setColor:_currentColor.CGColor];
}

#pragma mark - Action Buttons

- (IBAction)redoButtonDidPressed:(id)sender
{
    [_drawHelper clearView];
    for (NSArray *array in [_undoManager redoObject]) {
        [_drawHelper drawPath:_drawHelper.imageView
                   WithPoints:array
                     andColor:_currentColor.CGColor];
        
    }
}

- (IBAction)tweetMessage:(id)sender {

    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultCancelled)
                NSLog(@"Cancelled");
            else NSLog(@"Done");
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        
        
        controller.completionHandler = myBlock;
        
        
        [controller setInitialText:@"I draw it with DrawMe"];
//        [controller addURL:[NSURL URLWithString:@"http://idev.by"]];
        [controller addImage:_drawHelper.imageView.image];
        
        
        [self presentViewController:controller animated:YES completion:Nil];
        
        
    } else NSLog(@"UnAvailable");
}

- (IBAction)undoButtonDidPressed:(id)sender
{
    [_drawHelper clearView];
    for (NSArray *array in [_undoManager undoObject]) {
        [_drawHelper drawPath:_drawHelper.imageView
                   WithPoints:array
                     andColor:_currentColor.CGColor];

    }
}

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
    [_undoManager clearManager];
    [_drawHelper clearView];
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
        _isPaletteOpened = YES;
        [UIView animateWithDuration:0.6 animations:^{

            _paletteCenter.x -= kPaletteViewWidth;
            _paletteView.center = _paletteCenter;
            _redoButton.alpha = !_isPaletteOpened;
            [[self viewForDraw] setUserInteractionEnabled:NO];
            
        } completion:^(BOOL finished){
            [[self viewForDraw] setUserInteractionEnabled:YES];
        }];
        
    } else {
         _isPaletteOpened = NO;
        [self hidePalette];
    }
    [_pointsList removeAllObjects];
    _pointsCount = [_pointsList count];
}

-(void)hidePalette
{
    [UIView animateWithDuration:0.6 animations:^{
        _paletteCenter.x += kPaletteViewWidth;
        _paletteView.center = _paletteCenter;
        _redoButton.alpha = !_isPaletteOpened;
        [[self viewForDraw] setUserInteractionEnabled:YES];
    }completion:^(BOOL finished){
        [[self viewForDraw] setUserInteractionEnabled:YES];
    }];
    
}

@end