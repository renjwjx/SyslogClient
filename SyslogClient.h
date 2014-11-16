//
//  SyslogClient.h
//
//  Created by Chris DeSalvo on 10/22/2014
//

#import <Foundation/Foundation.h>

@interface SyslogClient : NSObject

+ (NSString *)allEntriesForApp;
+ (NSString *)allEntriesForProcess;

@end
