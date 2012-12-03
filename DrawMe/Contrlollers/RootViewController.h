//
//  ViewController.h
//  DrawMe
//
//  Created by Денис Ромашов on 13.11.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DrawView.h"


@interface RootViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *viewForDraw;

-(void)penButtonDidPressed:(UIButton*)button;
-(void)crayonButtonDidPressed:(UIButton*)button;

@end
