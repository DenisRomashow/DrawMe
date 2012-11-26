//
//  ViewController.h
//  DrawMe
//
//  Created by Денис Ромашов on 13.11.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Views/DrawView.h"


@interface RootViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *viewForDraw;

-(IBAction)test:(id)sender;
-(void)penButtonDidPressed:(UIButton*)button;
-(void)crayonButtonDidPressed:(UIButton*)button;
@end
