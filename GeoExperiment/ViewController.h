//
//  ViewController.h
//  GeoExperiment
//
//  Created by Kevin Nelson on 4/29/13.
//  Copyright (c) 2013 rknLA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *trackSwitch;
@property (strong, nonatomic) IBOutlet UIButton *createSessionButton;

- (IBAction)trackLocationToggled:(id)sender;
- (IBAction)newSessionPressed:(id)sender;

@end
