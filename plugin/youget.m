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
@property (weak) IBOutlet NSTextField *paramField;
@property (weak) IBOutlet NSTextField *exeField;

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
        //path = [path stringByAppendingString:@"/Contents/MacOS/you-get"];
        
        NSString *execPath = [[self getExec] stringByReplacingOccurrencesOfString:@"{BundlePath}" withString:path];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:execPath]){
            return [NSString stringWithFormat:@"You-Get 可执行文件不存在，请检查设置是否正确：\n%@",execPath];
        }
        
        NSPipe *newPipe = [NSPipe pipe];
        NSFileHandle *readHandle = [newPipe fileHandleForReading];
        NSData *inData = nil;
        NSString* returnStr = [[NSString alloc] init];
        
        NSTask * unixTask = [[NSTask alloc] init];
        [unixTask setStandardOutput:newPipe];
        [unixTask setStandardError:newPipe];
        [unixTask setLaunchPath:execPath];
        [unixTask setArguments:[self getParam:eventData]];
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
        [self.exeField setStringValue:[self getExec]];
        
        NSUserDefaults *settingsController = [NSUserDefaults standardUserDefaults];
        NSString *param = [settingsController objectForKey:@"youget_param"];
        if(param && [param length] > 0){
            [self.paramField setStringValue:param];
        }
    });
    return;
}

- (IBAction)saveSettings:(id)sender {
    NSUserDefaults *settingsController = [NSUserDefaults standardUserDefaults];
    NSString *param = self.paramField.stringValue;
    NSString *exe = self.exeField.stringValue;
    if(exe && [exe length] > 4){
        [settingsController setValue:exe forKey:@"youget_exec"];
    }
    if(param && [param length] > 0){
        [settingsController setValue:param forKey:@"youget_param"];
    }
    [settingsPanel close];
}

- (NSString *)getExec{
    NSUserDefaults *settingsController = [NSUserDefaults standardUserDefaults];
    NSString *exe = [settingsController objectForKey:@"youget_exec"];
    if(exe && [exe length] > 4){
        return exe;
    }else{
        return @"{BundlePath}/Contents/MacOS/you-get";
    }
}

- (NSArray *)getParam:(NSString *)url{
    url = [url stringByReplacingOccurrencesOfString:@"acfun.tudou.com" withString:@"www.acfun.tv"];
    NSUserDefaults *settingsController = [NSUserDefaults standardUserDefaults];
    NSString *prm = [settingsController objectForKey:@"youget_param"];
    if(prm && [prm length] > 0){
        NSMutableArray *params = [[prm componentsSeparatedByString:@" "] mutableCopy];
        [params insertObject:@"-u" atIndex:0];
        [params addObject:url];
        return params;
    }else{
        return [NSArray arrayWithObjects:@"-u", url , nil];
    }
}

@end