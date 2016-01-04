//
//  vp-youget.m
//  vp-youget
//
//  Created by TYPCN on 2015/9/20.
//  Copyright © 2015 TYPCN. All rights reserved.
//

#import "youget.h"

@interface youget ()

@property (strong) NSWindowController* settingsPanel;

@end

@implementation youget

@synthesize settingsPanel;

- (bool)load:(int)version{
    
    NSLog(@"VP-youget is loaded");
    
    return true;
}


- (bool)unload{
    
    return true;
}


- (bool)canHandleEvent:(NSString *)eventName{
    // Eventname format is pluginName-str
    if([eventName isEqualToString:@"youget-playvideo"]){
        return true;
    }
    return false;
}

- (NSString *)processEvent:(NSString *)eventName :(NSString *)eventData{
    
    if([eventName isEqualToString:@"youget-resolveAddr"]){
        
        NSString *path = [[NSBundle bundleForClass:[self class]]
                          pathForResource:@"you-get" ofType:@"bundle"];
        path = [path stringByAppendingString:@"/Contents/MacOS/you-get"];
        
        NSPipe *newPipe = [NSPipe pipe];
        NSFileHandle *readHandle = [newPipe fileHandleForReading];
        NSData *inData = nil;
        NSString* returnStr = [[NSString alloc] init];
        
        NSTask * unixTask = [[NSTask alloc] init];
        [unixTask setStandardOutput:newPipe];
        [unixTask setStandardError:newPipe];
        [unixTask setLaunchPath:path];
        [unixTask setArguments:[NSArray arrayWithObjects:@"-u", eventData , nil]];
        [unixTask launch];
        NSDate *terminateDate = [[NSDate date] dateByAddingTimeInterval:15.0];
        while ((unixTask != nil) && ([unixTask isRunning]))   {
            if ([[NSDate date] compare:(id)terminateDate] == NSOrderedDescending)   {
                NSLog(@"Error: terminating task, timeout was reached.");
                [unixTask terminate];
                return @"You-Get timeout";
            }
            [NSThread sleepForTimeInterval:1.0];
        }

        
        while ((inData = [readHandle availableData]) && [inData length]) {
            
            NSString *str = [[NSString alloc]
                          initWithData:inData encoding:NSUTF8StringEncoding];
            
            returnStr = [returnStr stringByAppendingString:str];
            //returnValue = [returnValue substringToIndex:[returnValue length]-1];
        }
        
        return returnStr;
    }
    
    return NULL; // return video url to play
}

- (void)openSettings{
    NSLog(@"Show youget settings");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        NSString *path = [[NSBundle bundleForClass:[self class]]
                          pathForResource:@"Settings" ofType:@"nib"];
        settingsPanel =[[NSWindowController alloc] initWithWindowNibPath:path owner:self];
        [settingsPanel showWindow:self];
    });
    return;
}
@end