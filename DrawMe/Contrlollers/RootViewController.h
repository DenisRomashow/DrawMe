//
//  ViewController.h
//  DrawMe
//
//  Created by Денис Ромашов on 13.11.12.
//  Copyright (c) 2012 DenisRomashow Home Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *viewForDraw;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;

- (IBAction)tweetMessage:(id)sender;
- (IBAction)undoButtonDidPressed:(id)sender;
- (IBAction)redoButtonDidPressed:(id)sender;

@end
