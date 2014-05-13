//
//  IAEHelpSelectorTableViewCellDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 13/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEHelpThemeDefs.h"

@class IAEHelpSelectorTableViewCell;

@protocol IAEHelpSelectorTableViewCellDelegate <NSObject>

- (void)helpSelectorTableViewCell:(IAEHelpSelectorTableViewCell *)cell didChangeSelectorIndexToHelpThemeType:(IAEHelpThemeType)helpThemeType;

@end
