//
//  ViewController.h
//  GeoExperiment
//
//  Created by Kevin Nelson on 4/29/13.
//  Copyright (c) 2013 rknLA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *beginSessionButton;
@property (strong, nonatomic) IBOutlet UISwitch *significantSwitch;

- (IBAction)newSessionPressed:(id)sender;

@end
