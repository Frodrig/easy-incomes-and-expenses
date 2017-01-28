//
//  IAEEconomicValueUpdater.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAnimateValueUpdater.h"
#import "IAENumberFormatterManager.h"
#import "IAEEconomicValueTypeHelper.h"
#import "IAEColorHelper.h"

@interface IAEAnimateValueUpdater()

@property (nonatomic, strong) NSMutableArray *pendingLabelUpdates;
@property (nonatomic, strong) CADisplayLink  *displayLink;

@end

@implementation IAEAnimateValueUpdater

#pragma mark - Enumerators

typedef NS_ENUM(NSUInteger, ValueType)
{
    VT_ECONOMIC,
    VT_PERCENTAGE
};

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

+ (IAEAnimateValueUpdater *)defaultAnimateValueUpdater
{
    static IAEAnimateValueUpdater *defaultAnimateValueUpdater = nil;
    if (!defaultAnimateValueUpdater) {
        defaultAnimateValueUpdater = [[IAEAnimateValueUpdater alloc] init];
    }
    
    return defaultAnimateValueUpdater;
}

- (void)processEconomicLabel:(UILabel *)label toValue:(NSDecimalNumber *)destinationValue withDuration:(CGFloat)duration
{
    [self processLabel:label toValue:destinationValue withDuration:duration andValueType:VT_ECONOMIC];
}

- (void)processPercentageLabel:(UILabel *)label toValue:(NSDecimalNumber *)destinationValue withDuration:(CGFloat)duration
{
    [self processLabel:label toValue:destinationValue withDuration:duration andValueType:VT_PERCENTAGE];
}

- (void)processLabel:(UILabel *)label toValue:(NSDecimalNumber *)destinationValue withDuration:(CGFloat)duration andValueType:(ValueType)valueType
{
    if (![self isLabelCounterProcessingAnimation:label]) {
        [self createDisplayLinkRunLoopIfAppropiate];
        [self addNewEntryForLabel:label toValue:destinationValue withDuration:duration andValueType:valueType];
    } else {
        [self updateProcessLabel:label withValue:destinationValue andDuration:duration];
    }
}

- (void)createDisplayLinkRunLoopIfAppropiate
{
    if (self.pendingLabelUpdates.count == 0) {
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)addNewEntryForLabel:(UILabel *)label
                    toValue:(NSDecimalNumber *)destinationValue
               withDuration:(CGFloat)duration
               andValueType:(ValueType)valueType
{
    NSDictionary *newLabelToUpdateEntry = [self makeDictionaryEntryForLabel:label
                                                           destinationValue:destinationValue
                                                              durationValue:duration
                                                               andValueType:valueType];
    [self.pendingLabelUpdates addObject:newLabelToUpdateEntry];
}

- (NSMutableDictionary *)makeDictionaryEntryForLabel:(UILabel *)label
                                    destinationValue:(NSDecimalNumber *)destValue
                                       durationValue:(CGFloat)duration
                                        andValueType:(ValueType)valueType
{
    NSDecimalNumber *fromValue = [self extractDecimalNumberFromLabel:label withValueType:valueType];
    NSNumber *durationNumber = [NSNumber numberWithFloat:duration];
    NSNumber *startTimeNumber = [NSNumber numberWithDouble:CACurrentMediaTime()];
    
    NSArray *values = [NSArray arrayWithObjects:label, fromValue, [destValue copy], durationNumber, startTimeNumber, @(valueType), nil];
    NSArray *keys = [NSArray arrayWithObjects:@"label", @"from", @"to", @"duration", @"startTime", @"valueType", nil];
    NSMutableDictionary *dictionaryEntry = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    
    return dictionaryEntry;
}

- (NSDecimalNumber *)extractDecimalNumberFromLabel:(UILabel *)label withValueType:(ValueType)valueType
{
    NSString *stringNumberOfLabel = label.text;
    
    NSNumber *number = nil;
    if (valueType == VT_ECONOMIC) {
        number = [[IAENumberFormatterManager sharedManager].currencyFormatter numberFromString:stringNumberOfLabel];
    } else if (valueType == VT_PERCENTAGE) {
        number = [[IAENumberFormatterManager sharedManager].percentageFormatter numberFromString:stringNumberOfLabel];
    }
    
    if (!number) {
        // ToDo: Parche para evitar crash. Estaba devolviendo nil ¿por qué? al cambiar de año.
        number = [NSNumber numberWithInt:0];
    }
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:number.stringValue];

     return decimalNumber;
}

- (void)updateProcessLabel:(UILabel *)label withValue:(NSDecimalNumber *)destValue andDuration:(CGFloat)duration
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
            
            NSNumber *valueType = labelCounterData[@"valueType"];
            [self updatePendingLabelEntry:labelCounterData withValue:newUpdateValueOfLabel ofType:valueType.unsignedIntegerValue];
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

    float dt = (link.timestamp - startTime.floatValue) / duration.doubleValue;
    
    NSDecimalNumber *updatedValue = nil;
    if (dt >= 1) {
        updatedValue = to;
    } else {
        if ([to compare:from] == NSOrderedDescending) {
            updatedValue = [to decimalNumberBySubtracting:from];
            updatedValue = [updatedValue decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithFloat:dt]];
            updatedValue = [updatedValue decimalNumberByAdding:from];
        } else {
            updatedValue = [from decimalNumberBySubtracting:to];
            updatedValue = [updatedValue decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithFloat:dt]];
            updatedValue = [from decimalNumberBySubtracting:updatedValue];
        }
    }
    
    return updatedValue;
}

- (void)updatePendingLabelEntry:(NSDictionary *)pendingLabelEntry
                      withValue:(NSDecimalNumber *)value
                         ofType:(ValueType)valueType
{
    NSNumber *numberObject = [[NSNumber alloc] initWithFloat:value.floatValue];
    UILabel *label = [pendingLabelEntry objectForKey:@"label"];
    NSMutableDictionary *updatedAttributes = [[label.attributedText attributesAtIndex:0 effectiveRange:nil] mutableCopy];
    NSString *updatedString = nil;
    
    if (valueType == VT_ECONOMIC) {
        updatedString = [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:numberObject];
        UIColor *updatedColor = [IAEColorHelper colorForEconomicValueType:[IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:value]];
        [updatedAttributes setObject:updatedColor forKey:NSForegroundColorAttributeName];
    } else if (valueType == VT_PERCENTAGE) {
        updatedString = [[IAENumberFormatterManager sharedManager] convertNumberToDecoratePercentageString:numberObject];
    }
    
    NSAttributedString *updatedAttributedString = [[NSAttributedString alloc] initWithString:updatedString attributes:updatedAttributes];
    label.attributedText = updatedAttributedString;
}

- (void)destroyDisplayLinkRunLoopIfAppropiate
{
    if (self.pendingLabelUpdates.count == 0) {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
}

@end
