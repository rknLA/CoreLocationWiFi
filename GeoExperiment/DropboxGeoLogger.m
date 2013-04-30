//
//  DropboxGeoLogger.m
//  GeoExperiment
//
//  Created by Kevin Nelson on 4/29/13.
//  Copyright (c) 2013 rknLA. All rights reserved.
//

#import "DropboxGeoLogger.h"

static DropboxGeoLogger *_sharedInstance = nil;

typedef enum {
  NotLoggingState = 0,
  LoggingPreciseState,
  LoggingSignificantChangesState
} LoggingState;

@interface DropboxGeoLogger(){
  CLLocationManager *_locationManager;
  LoggingState _loggingState;
  DBFile *_outputFile;
  NSMutableDictionary *_outputDict;
}

@end

@implementation DropboxGeoLogger

+ (DropboxGeoLogger *)sharedLogger
{
  if (_sharedInstance == nil) {
    _sharedInstance = [[DropboxGeoLogger alloc] init];
  }
  
  return _sharedInstance;
}

- (DropboxGeoLogger *)init
{
  self = [super init];
  if (self) {
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    _loggingState = NotLoggingState;
    _outputFile = nil;
    
    [self useNewOutputFile];
  }
  return self;
}

- (void)useNewOutputFile
{
  // write and close output file if it exists
  if (_outputFile) {
    [_outputFile writeData:[NSJSONSerialization dataWithJSONObject:_outputDict
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil]
                     error:nil];
    [_outputFile close];
  }
  
  // create new output file based on current time.
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
  NSString *nowString = [dateFormatter stringFromDate:now];
  nowString = [NSString stringWithFormat:@"%@.json", nowString];
  DBPath *newFilePath = [[DBPath root] childPath:nowString];
  _outputFile = [[DBFilesystem sharedFilesystem] createFile:newFilePath error:nil];
  
  // reset output dict
  _outputDict = [[NSMutableDictionary alloc] init];
  [_outputDict setObject:@[] forKey:@"locations"];
}

- (void)startLoggingWithSignificantChanges:(BOOL)significant
{
  if (significant) {
    [_locationManager startMonitoringSignificantLocationChanges];
    _loggingState = LoggingSignificantChangesState;
  } else {
    [_locationManager startUpdatingLocation];
    _loggingState = LoggingPreciseState;
  }
}

- (void)stopLogging
{
  if (_loggingState == LoggingPreciseState) {
    [_locationManager stopUpdatingLocation];
  } else if (_loggingState == LoggingSignificantChangesState) {
    [_locationManager stopMonitoringSignificantLocationChanges];
  }
}

# pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  // ignore this for now. since this is an experiment, we'll assume the best.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  NSLog(@"Locations updated! %@", locations);
  
  if (_loggingState != NotLoggingState) {
    // write them to dropbox!
    NSArray *existingLocations = [_outputDict objectForKey:@"locations"];
    NSArray *newLocations = [existingLocations arrayByAddingObjectsFromArray:locations];
    [_outputDict setObject:newLocations forKey:@"locations"];
  }
}

@end
