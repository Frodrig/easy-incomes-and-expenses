//
//  IAEEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailRequest.h"
#import "IAERecoveryEmailRequest.h"
#import "IAERecoveryMailLinkedEmailRequest.h"
#import "IAEPasswordChangedEmailRequest.h"
#import "IAEPasswordDisabledEmailRequest.h"
#import "IAEPasswordEnabledEmailRequest.h"
#import "NSUserDefaults+EasyIncAndExp.h"

#pragma mark - Constantes

static NSString * const kDefaultSourceEmail = @"easyincomesandexpenses@frodrig.com";
static NSString * const kDefaultNameForSourceEmail = @"Easy Incomes and Expenses";

@implementation IAEEmailRequest

#pragma mark - Class

+ (id)emailRequestWithType:(IAEEmailRequestType)type
{
    IAEEmailRequest *retRequest = nil;
    switch (type) {
        case RecoveryEmailRequest:
            retRequest = [[IAERecoveryEmailRequest alloc] init];
            break;
            
        case RecoveryMailLinkedEmailRequest:
            retRequest = [[IAERecoveryMailLinkedEmailRequest alloc] init];
            break;
            
        case PasswordChangedEmailRequest:
            retRequest = [[IAEPasswordChangedEmailRequest alloc] init];
            break;
            
        case PasswordDisabledEmailRequest:
            retRequest = [[IAEPasswordDisabledEmailRequest alloc] init];
            break;
            
        case PasswordEnabledEmailRequest:
            retRequest = [[IAEPasswordEnabledEmailRequest alloc] init];
            break;
            
        default:
            break;
    }
    
    return retRequest;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepareRequest];
    }
    
    return self;
}

- (void)prepareRequest
{
    self.fromAddress = [self findSourceEmail];
    self.nameForFromAddress =[self findNameForSourceEmail];
    self.subject = [self findSubjectText];
    [self.toAddresses addObject:[self findDestinationEmail]];
    [self setBody:[self findMessageText] isHTML:NO];
}

#pragma mark - Metodos a sobreescribir

- (NSString *)findSourceEmail
{
    return kDefaultSourceEmail;
}

- (NSString *)findNameForSourceEmail
{
    return kDefaultNameForSourceEmail;
}

- (NSString *)findDestinationEmail
{
    return [[NSUserDefaults standardUserDefaults] findPasswordRecoveryEmail];
}

- (NSString *)findSubjectText
{
    NSAssert(NO, @"Se debe sobreescribir en la clase derivada");
    return nil;
}

- (NSString *)findMessageText
{
    NSAssert(NO, @"Se debe sobreescribir en la clase derivada");
    return nil;
}

@end
