//
//  IAEFavoriteConceptsTableHeader.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 09/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEFavoriteConceptsTableHeader.h"
#import "IAEValueDecoratorView.h"

@interface IAEFavoriteConceptsTableHeader()

@property (nonatomic, weak) IBOutlet IAEValueDecoratorView *typeDecorator;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation IAEFavoriteConceptsTableHeader

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setDecoratorValueType:(EconomicValueType)decoratorValueType
{
    self.typeDecorator.economicValueType = decoratorValueType;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
