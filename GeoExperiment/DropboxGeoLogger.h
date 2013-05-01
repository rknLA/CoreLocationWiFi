//
//  DropboxGeoLogger.h
//  GeoExperiment
//
//  Created by Kevin Nelson on 4/29/13.
//  Copyright (c) 2013 rknLA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Dropbox/Dropbox.h>

@interface DropboxGeoLogger : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocation *lastLocation;

+ (DropboxGeoLogger *)sharedLogger;

- (void)useNewOutputFile;

- (void)startLoggingWithSignificantChanges:(BOOL)significant;
- (void)stopLogging;

@end
