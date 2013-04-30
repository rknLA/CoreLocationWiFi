//
//  ViewController.m
//  GeoExperiment
//
//  Created by Kevin Nelson on 4/29/13.
//  Copyright (c) 2013 rknLA. All rights reserved.
//

#import "ViewController.h"
#import "DropboxGeoLogger.h"

@interface ViewController () {
  BOOL _tracking;
}

@end

@implementation ViewController

@synthesize beginSessionButton;
@synthesize significantSwitch;

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  _tracking = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
  if (![[DBAccountManager sharedManager] linkedAccount]) {
    [[DBAccountManager sharedManager] linkFromController:self];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)newSessionPressed:(id)sender
{
  NSLog(@"New session, create a new dropbox file here");
  if (_tracking) {
    [[DropboxGeoLogger sharedLogger] stopLogging];
    _tracking = NO;
    self.significantSwitch.enabled = YES;
    [self.beginSessionButton setTitle:@"Begin GeoTracking Session" forState:UIControlStateNormal];
  } else {
    self.significantSwitch.enabled = NO;
    [self.beginSessionButton setTitle:@"Stop Session" forState:UIControlStateNormal];
    _tracking = YES;
    [[DropboxGeoLogger sharedLogger] startLoggingWithSignificantChanges:self.significantSwitch.on];
  }
}

@end
