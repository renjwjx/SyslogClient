//
//  SyslogClient.m
//
//  Created by Chris DeSalvo on 10/22/2014.
//

#import "SyslogClient.h"

#import <asl.h>

@implementation SyslogClient

+ (NSString *)allEntriesForProcess
{
    NSProcessInfo   *p = [NSProcessInfo processInfo];
    NSString        *pidStr = [NSString stringWithFormat:@"%d", [p processIdentifier]];
    const char      *pid = [pidStr UTF8String];
    aslmsg          query = asl_new(ASL_TYPE_QUERY);

    asl_set_query(query, ASL_KEY_PID, pid, ASL_QUERY_OP_EQUAL);

    return [SyslogClient runQuery:query];
}

+ (NSString *)allEntriesForApp
{
    NSString    *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *) kCFBundleNameKey];
    aslmsg      query = asl_new(ASL_TYPE_QUERY);

    asl_set_query(query, ASL_KEY_SENDER, [appName UTF8String], ASL_QUERY_OP_EQUAL);

    return [SyslogClient runQuery:query];
}

+ (NSString *)runQuery:(aslmsg)query
{
    //  Create a US-styled date formatter regardless of what locale we're in
    NSLocale        *american = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString        *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMM dd, hh:mm:ss" options:0 locale:american];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone      *gmt = [NSTimeZone timeZoneWithName:@"GMT"];

    [formatter setDateFormat:formatString];
    [formatter setTimeZone:gmt];

    NSMutableString *builder = [NSMutableString stringWithString:@"All timestamps are GMT.\n\n"];
    aslresponse     response = asl_search(NULL, query);

    for (aslmsg entry = aslresponse_next(response); entry; entry = aslresponse_next(response))
    {
        const char  *timestamp = asl_get(entry, ASL_KEY_TIME);
        const char  *logline = asl_get(entry, ASL_KEY_MSG);
        double      seconds = atof(timestamp);
        NSDate      *date = [NSDate dateWithTimeIntervalSince1970:seconds];

        [builder appendFormat:@"[%@] %s\n", [formatter stringFromDate:date], logline];
    }

    aslresponse_free(response);

    return [NSString stringWithString:builder];
}

@end
