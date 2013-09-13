//
//  IAEEconomicValueUpdater.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEconomicValueUpdater.h"
#import "IAECurrencyManager.h"
#import "IAEEconomicValueTypeHelper.h"
#import "IAEColorHelper.h"

@interface IAEEconomicValueUpdater()

@property (nonatomic, strong) NSMutableArray *pendingLabelUpdates;
@property (nonatomic, strong) CADisplayLink  *displayLink;

@end

@implementation IAEEconomicValueUpdater


#pragma mark - Constants

static const CGFloat kRationOfDurationByUpdateProcessEconomicLabel = 0.1;

#pragma mark - Properties

- (NSMutableArray *)pendingLabelUpdates
{
    if (!_pendingLabelUpdates) {
        _pendingLabelUpdates = [NSMutableArray array];
    }
    
    return _pendingLabelUpdates;
}

- (CADisplayLink *)displayLink
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(processPendingLabels:)];
    }
    
    return _displayLink;
}

+ (IAEEconomicValueUpdater *)defaultEconomicValueUpdater
{
    static IAEEconomicValueUpdater *defaultEconomicValueUpdater = nil;
    if (!defaultEconomicValueUpdater) {
        defaultEconomicValueUpdater = [[IAEEconomicValueUpdater alloc] init];
    }
    
    return defaultEconomicValueUpdater;
}

- (void)processEconomicLabel:(UILabel *)label toValue:(NSDecimalNumber *)destinationValue withDuration:(CGFloat)duration
{
    if (![self isLabelCounterProcessingAnimation:label]) {
        [self createDisplayLinkRunLoopIfAppropiate];
        [self addNewEntryForEconomicLabel:label toValue:destinationValue withDuration:duration];
    } else {
        [self updateProcessEconomicLabel:label withValue:destinationValue andDuration:duration];
    }
}

- (void)createDisplayLinkRunLoopIfAppropiate
{
    if (self.pendingLabelUpdates.count == 0) {
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)addNewEntryForEconomicLabel:(UILabel *)label toValue:(NSDecimalNumber *)destinationValue withDuration:(CGFloat)duration
{
    NSDictionary *newLabelToUpdateEntry = [self makeDictionaryEntryForLabel:label destinationValue:destinationValue andDurationValue:duration];
    [self.pendingLabelUpdates addObject:newLabelToUpdateEntry];
}

- (NSMutableDictionary *)makeDictionaryEntryForLabel:(UILabel *)label
                                    destinationValue:(NSDecimalNumber *)destValue
                                    andDurationValue:(CGFloat)duration
{
    NSDecimalNumber *fromValue = [self extractDecimalNumberFromLabel:label];
    NSNumber *durationNumber = [NSNumber numberWithFloat:duration];
    NSNumber *startTimeNumber = [NSNumber numberWithDouble:CACurrentMediaTime()];
    
    NSArray *values = [NSArray arrayWithObjects:label, fromValue, [destValue copy], durationNumber, startTimeNumber, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"label", @"from", @"to", @"duration", @"startTime", nil];
    NSMutableDictionary *dictionaryEntry = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    
    return dictionaryEntry;
}

- (NSDecimalNumber *)extractDecimalNumberFromLabel:(UILabel *)label
{
    NSNumber *number = [[IAECurrencyManager sharedManager].currencyFormatter numberFromString:label.text];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:number.stringValue];

     return decimalNumber;
}

- (void)updateProcessEconomicLabel:(UILabel *)label withValue:(NSDecimalNumber *)destValue andDuration:(CGFloat)duration
{
    NSMutableDictionary *informationOfLabel = [self findInPendingLabelUpdatesInformationOfLabel:label];
    NSAssert(informationOfLabel, @"En este punto DEBERIA de existir entrada para el label");
    
    informationOfLabel[@"to"] = [destValue copy];
    NSNumber *actualDuration = [informationOfLabel objectForKey:@"duration"];
    CGFloat newDuration = actualDuration.floatValue + duration * kRationOfDurationByUpdateProcessEconomicLabel;
    informationOfLabel[@"duration"] = @(newDuration);
}

- (NSMutableDictionary *)findInPendingLabelUpdatesInformationOfLabel:(UILabel *)label
{
    NSMutableDictionary *information = nil;
    for (information in self.pendingLabelUpdates) {
        UILabel *labelIt = information[@"label"];
        if (label == labelIt) {
            break;
        }
    }
    
    return information;
}


- (BOOL)isLabelCounterProcessingAnimation:(UILabel *)label
{
    BOOL isProcessingAnimation = NO;
    for (NSDictionary *pendingUpdate in self.pendingLabelUpdates) {
        UILabel *labelIt = [pendingUpdate objectForKey:@"label"];
        isProcessingAnimation = labelIt == label;
        if (isProcessingAnimation) {
            break;
        }
    }
    
    return isProcessingAnimation;
}

- (void)processPendingLabels:(CADisplayLink *)link
{
    if (link == self.displayLink) {
        NSMutableArray *pendingLabelsProcessed = [NSMutableArray arrayWithCapacity:self.pendingLabelUpdates.count];
        for (NSDictionary *labelCounterData in self.pendingLabelUpdates) {
            NSDecimalNumber *newUpdateValueOfLabel = [self generateUpdatedLabelValueAdDecimalNumberFromPendingData:labelCounterData
                                                                                                   withDisplayLink:link];
            if ([[labelCounterData objectForKey:@"to"] compare:newUpdateValueOfLabel] == NSOrderedSame) {
                [pendingLabelsProcessed addObject:labelCounterData];
            }
            
            [self updatePendingLabelEntry:labelCounterData withValue:newUpdateValueOfLabel];
        }
        
        [self.pendingLabelUpdates removeObjectsInArray:pendingLabelsProcessed];
        
        [self destroyDisplayLinkRunLoopIfAppropiate];
    }
}

-(NSDecimalNumber *)generateUpdatedLabelValueAdDecimalNumberFromPendingData:(NSDictionary *)pendingLabelData withDisplayLink:(CADisplayLink *)link
{
    NSDecimalNumber *from = [pendingLabelData objectForKey:@"from"];
    NSDecimalNumber *to = [pendingLabelData objectForKey:@"to"];
    NSNumber *duration = [pendingLabelData objectForKey:@"duration"];
    NSNumber *startTime = [pendingLabelData objectForKey:@"startTime"];

    CGFloat dt = (link.timestamp - startTime.floatValue) / duration.doubleValue;
    
    NSDecimalNumber *updatedValue = nil;
    if (dt >= 1) {
        updatedValue = to;
    } else {
        NSDecimalNumber *decimalNumberWithDeltaTime = [[NSDecimalNumber alloc] initWithFloat:dt];
        if ([to compare:from] == NSOrderedDescending) {
            updatedValue = [to decimalNumberBySubtracting:from];
            updatedValue = [updatedValue decimalNumberByMultiplyingBy:decimalNumberWithDeltaTime];
            updatedValue = [updatedValue decimalNumberByAdding:from];
        } else {
            updatedValue = [from decimalNumberBySubtracting:to];
            updatedValue = [updatedValue decimalNumberByMultiplyingBy:decimalNumberWithDeltaTime];
            updatedValue = [from decimalNumberBySubtracting:updatedValue];
        }
    }
    
    return updatedValue;
}

- (void)updatePendingLabelEntry:(NSDictionary *)pendingLabelEntry withValue:(NSDecimalNumber *)value
{
    UILabel *label = [pendingLabelEntry objectForKey:@"label"];
    NSString *updatedString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:value];
    UIColor *updatedColor = [IAEColorHelper colorForEconomicValueType:[IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:value]];
    label.text = updatedString;
    label.textColor = updatedColor;
}

- (void)destroyDisplayLinkRunLoopIfAppropiate
{
    if (self.pendingLabelUpdates.count == 0) {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
}

@end
