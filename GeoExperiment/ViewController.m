//
//  ViewController.m
//  GeoExperiment
//
//  Created by Kevin Nelson on 4/29/13.
//  Copyright (c) 2013 rknLA. All rights reserved.
//

#import "ViewController.h"
#import <Dropbox/Dropbox.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize trackSwitch;
@synthesize createSessionButton;

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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

- (IBAction)trackLocationToggled:(id)sender
{
  NSLog(@"TRACK SWITCH TOGGLED");
}

- (IBAction)newSessionPressed:(id)sender
{
  NSLog(@"New session, create a new dropbox file here");
}

@end
