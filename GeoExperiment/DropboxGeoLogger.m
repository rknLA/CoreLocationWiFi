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
  NSMutableDictionary * __strong _outputDict;
}

@end

@implementation DropboxGeoLogger

@synthesize lastLocation = _lastLocation;

- (void)setLastLocation:(CLLocation *)lastLocation
{
  _lastLocation = lastLocation;
}

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
  }
  return self;
}

- (void)useNewOutputFile
{  
  // create new output file based on current time.
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
  NSString *nowString = [dateFormatter stringFromDate:now];
  nowString = [NSString stringWithFormat:@"%@.json", nowString];
  DBPath *newFilePath = [[DBPath root] childPath:nowString];
  DBError *err;
  _outputFile = [[DBFilesystem sharedFilesystem] createFile:newFilePath error:&err];
  
  // reset output dict
  _outputDict = [[NSMutableDictionary alloc] init];
  [_outputDict setObject:@[] forKey:@"locations"];
}

- (void)startLoggingWithSignificantChanges:(BOOL)significant
{
  [self useNewOutputFile];
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
  
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_outputDict
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:nil];
  [_outputFile writeData:jsonData
                   error:nil];
  [_outputFile close];
  _outputFile = nil;
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
    
    //update the output dictionary
    [self setLastLocation:[locations objectAtIndex:([locations count] -1)]];
    
    // write them to dropbox!
    NSArray *existingLocations = [_outputDict objectForKey:@"locations"];
    NSMutableArray *newLocations = [NSMutableArray arrayWithCapacity:20];
    for (CLLocation *location in locations) {
      NSDictionary *loc = @{
                             @"latitude": [NSNumber numberWithDouble:[location coordinate].latitude],
                             @"longitude": [NSNumber numberWithDouble:[location coordinate].longitude],
                             @"horizontal accuracy": [NSNumber numberWithDouble:[location horizontalAccuracy]],
                             @"vertical accuracy": [NSNumber numberWithDouble:[location verticalAccuracy]],
                             @"altitude": [NSNumber numberWithDouble:[location altitude]],
                             @"timestamp": [[location timestamp] description],
                             @"speed": [NSNumber numberWithDouble:[location speed]],
                             @"course": [NSNumber numberWithDouble:[location course]]};
      [newLocations addObject:loc];
    }
    
    NSArray *concatenatedLocations = [existingLocations arrayByAddingObjectsFromArray:newLocations];
    [_outputDict setObject:concatenatedLocations forKey:@"locations"];
    
    // actuall write the file
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_outputDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    [_outputFile writeData:jsonData
                     error:nil];
  }
}

@end
