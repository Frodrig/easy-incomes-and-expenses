//
//  IAEEmailSender.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailSender.h"
#import "IAEEmailRequest.h"
#import <AWSRuntime/AWSRuntime.h>

#pragma mark - Constants

static NSString * const kAWSAccessKeyId = @"AKIAJ7V3LH7KQC3WBXOQ";
static NSString * const kAWSSecretKey = @"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";

@interface IAEEmailSender()

@property (nonatomic, strong) AmazonSESClient *sesClient;

@end

@implementation IAEEmailSender

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static IAEEmailSender *sharedInstance = nil;
    static dispatch_once_t onceQueue;
    dispatch_once(&onceQueue, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Properties

- (AmazonSESClient *)sesClient
{
    if (!_sesClient) {
        _sesClient = [[AmazonSESClient alloc] initWithAccessKey:kAWSAccessKeyId withSecretKey:kAWSSecretKey];
        _sesClient.endpoint = [AmazonEndpoints snsEndpoint:EU_WEST_1];
    }
    
    return _sesClient;
}

#pragma mark - Actions

- (void)sendRecoveryPasswordEmail
{
    @try {
        
        SESContent *messageBody = [[SESContent alloc] init];
        messageBody.data = @"test";
        
        SESContent *subject = [[SESContent alloc] init];
        subject.data = @"test";
        
        SESBody *body = [[SESBody alloc] init];
        body.text = messageBody;
        
        SESMessage *message = [[SESMessage alloc] init];
        message.subject = subject;
        message.body    = body;
        
        SESDestination *destination = [[SESDestination alloc] init];
        [destination.toAddresses addObject:@"frodrig76@gmail.com"];
        
        SESSendEmailRequest *ser = [[SESSendEmailRequest alloc] init];
        ser.source      = @"easyincexp-noreply@frodrig.com";
        ser.destination = destination;
        ser.message     = message;
        
        SESSendEmailResponse *response = [self.sesClient sendEmail:ser];
        if(response.error != nil)
        {
            NSLog(@"Error: %@", response.error);
        }
        
        NSLog(@"Message sent, id %@", response.messageId);
         
        /*
        CFUUIDRef   uuidRef   = CFUUIDCreate(kCFAllocatorDefault);
        NSString    *uuid     = (__bridge_transfer  NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        CFRelease(uuidRef);
        
        NSDate* today = [[NSDate alloc] init];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        NSString* date =[dateFormatter stringFromDate:today];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableString *rawMime = [[NSMutableString alloc] init];
        [rawMime appendFormat:@"To: %@\n", @"frodrig76@gmail.com"];
        [rawMime appendFormat:@"From: \"name_from\" %@\n", @"easyincexp-noreply@frodrig.com"];
         [rawMime appendFormat:@"Subject: %@\n", @"test"];
         [rawMime appendFormat:@"Date: %@\n", [NSDate date]];
         [rawMime appendFormat:@"Message-ID: <%@@%@>\n", [(NSString *)uuid stringByReplacingOccurrencesOfString:@"-" withString:@""], @"IETF.CNR I.Reston.VA.US"];
         [rawMime appendString:@"Mime-Version: 1.0\n"];
         [rawMime appendString:@"Content-type: Multipart/Mixed; boundary=\"NextPart\"\n"];
         [rawMime appendString:@"\n"];
         [rawMime appendString:@"--NextPart\n"];
         
         //Here's come the body part
         [rawMime appendString:@"Content-type: text/plain; charset=\"UTF-8\"\n"];
         [rawMime appendString:@"\n"];
         [rawMime appendString:@"\n"];
         [rawMime appendString:@"--NextPart\n"];
         
        
         NSData        *rawMessageData = [rawMime dataUsingEncoding:NSUTF8StringEncoding];
        SESRawMessage *rawMessage = [[SESRawMessage alloc] init];
        rawMessage.data = rawMessageData;
        
        
        SESSendRawEmailRequest *request = [[SESSendRawEmailRequest alloc] init];
        request.source = @"easyincexp-noreply@frodrig.com";
        request.rawMessage = rawMessage;
        
        SESSendRawEmailResponse *response = [self.sesClient sendRawEmail:request];
         */
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    @finally {
        
    }
    
   
    

    /*
    @try
    {
        SESSendEmailResponse *response = [self.sesClient sendEmail:[IAEEmailRequest emailRequestWithType:RecoveryEmailRequest]];
        NSLog(@"%@", response);
    }
    @catch (NSException *theException)
    {
        NSLog(@"Exception: %@", theException);
    }
     */
}

- (void)sendConfirmationLinkedMailForRecoveryPasswordEmail
{
    @try
    {
        SESSendEmailResponse *response = [self.sesClient sendEmail:[IAEEmailRequest emailRequestWithType:RecoveryMailLinkedEmailRequest]];
        NSLog(@"%@", response);
    }
    @catch (NSException *theException)
    {
        NSLog(@"Exception: %@", theException);
    }

}

@end
