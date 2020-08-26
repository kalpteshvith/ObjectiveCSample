//
//  ViewController.m
//  ObjectiveC Sample
//
//  Created by Kalpesh Panchasara on 26/08/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonCrypto.h>

NSString *  accessKey=@"YEQNNHPDTCAWU4TDN2KP";
NSString *  secretKey=@"d5bn7ih0rJUbange7Kx0B5jXWiVdYJPHpYLxV384IG0";

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self PutSensorDatatoServer];
    [super viewDidLoad];
}

#pragma mark : Method to Send Data to Server
-(void)PutSensorDatatoServer
{
    NSString * serviceUrl=@"https://hiw-stylus-mobile-sensor-uploads.nyc3.digitaloceanspaces.com/20200505-1588817811-789101112.json";
    NSString * bucket=@"hiw-stylus-mobile-sensor-uploads";

    NSURLSession *delegateFreeSession=[NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] delegate: nil delegateQueue: [NSOperationQueue mainQueue]];

    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serviceUrl]];
    mutableRequest.HTTPMethod = @"PUT";
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *canonicalDate=[self amzDate];
    [mutableRequest setValue:canonicalDate forHTTPHeaderField:@"X-Amz-Date"];

    NSMutableString *relativePath=[NSMutableString new];
    [relativePath appendString:@"/"];
    [relativePath appendString:bucket];
    [relativePath appendString:@"/"];

    NSString *authorization=[self signWithDate:canonicalDate name:relativePath];
    [mutableRequest setValue:authorization forHTTPHeaderField:@"Authorization"];

    NSURLSessionDataTask *dataTask = [delegateFreeSession dataTaskWithRequest:mutableRequest
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        NSLog(@"%@", error);
      } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        NSLog(@"HTTPResponse=%@",httpResponse);
      }
    }];
    [dataTask resume];
}




#pragma mark : Method to Get Date Formatted
- (NSString *) amzDate
{
    static NSDateFormatter *dateFormatter=nil;
    if(dateFormatter==nil)
    {
        dateFormatter=[NSDateFormatter new];
        dateFormatter.dateFormat=@"E',' dd MMM yyyy HH':'mm':'ss ZZZ";
        dateFormatter.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    NSString *dateString=[dateFormatter stringFromDate:[NSDate date] ];
    return dateString;
}


#pragma mark : Method to Get Signature with Date

- (NSString *) signWithDate:(NSString *)dateString name:(NSString *)name
{
    NSString *authorization=[[@"AWS " stringByAppendingString:accessKey] stringByAppendingString:@":"];
    NSString *stringToSign=[[[@"PUT\n\ntext/plain\n" stringByAppendingString:dateString] stringByAppendingString:@"\n"] stringByAppendingString:name];
    NSString * new=[self HMACSign:[stringToSign dataUsingEncoding:NSUTF8StringEncoding] withKey:secretKey usingAlgorithm:kCCHmacAlgSHA1];
    return [authorization stringByAppendingString:new];
}



#pragma mark : Method to Get HMAC Sign String

- (NSString *)HMACSign:(NSData *)data withKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm
{
    CCHmacContext context;
    const char *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];

    CCHmacInit(&context, algorithm, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [data bytes], [data length]);

    unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];

    NSInteger digestLength =CC_SHA1_DIGEST_LENGTH;

    CCHmacFinal(&context, digestRaw);

    NSData *digestData = [NSData dataWithBytes:digestRaw length:digestLength];

    return [digestData base64EncodedStringWithOptions:kNilOptions];
}

@end
