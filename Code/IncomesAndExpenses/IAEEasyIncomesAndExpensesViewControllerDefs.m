//
//  IAEEasyIncomesAndExpensesViewControllerDefs.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#ifndef IncomesAndExpenses_IAEEasyIncomesAndExpensesViewControllerDefs_h
#define IncomesAndExpenses_IAEEasyIncomesAndExpensesViewControllerDefs_h

#import "IAEEasyIncomesAndExpensesViewControllerDefs.h"
#import "IAEStrokeAnimatableLineViewDefs.h"

const CGFloat kSelectorContextViewYOutsideMargin = 100;

const CGFloat kDurationInitializationAnimationNavigationFadeIn = 0.75;
const CGFloat kDurationInitializationAnimationContextAndModesFadeIn = 1;
const CGFloat kDurationInitializationAnimationTraslantionFadeIn = 1.25;

NSString * const kLTextNavigationBarTitle = @"LTEXT_NAVIGATIONBAR_TITLE";
NSString * const kLTextSettingsBarButtonTitle = @"LTEXT_BARBUTTON_SETTINGS_TITLE";
NSString * const kLTextYearsBarButtonTitle = @"LTEXT_BARBUTTON_YEARS_TITLE";
NSString * const kLTextCategoriesBarButtonTitle = @"LTEXT_BARBUTTON_CATEGORIES_TITLE";
NSString * const kLTextFavoritesBarButtonTitle = @"LTEXT_BARBUTTON_FAVORITES_TITLE";

NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

NSString * const kNotificationDayModeOnName = @"dayModeToOn";
NSString * const kNotificationDayModeOffName = @"dayModeToOff";
NSString * const kNotificationInitialMonthChanged = @"initialMonthChange";
NSString * const kNotificationMainLabelTitleTouched = @"mainLabelTitleTouched";
NSString * const kNotificationKeyboardResignFromEditingConceptsNotes = @"KeyboardResignFromEditingConceptsNotes";
NSString * const kNotificationKeyboardSignForEditingConceptsNotes = @"KeyboardSignForEditingConceptsNotes";
NSString * const kNotificationEndEditingNoteForModeConceptCollectionViewCell = @"EndEditingNoteForModeConceptCollectionViewCell";

NSString * const kLTextModeSegmentedControlEditMode = @"LTEXT_MODESEGMENTEDCONTROL_EDITMODE";
NSString * const kLTextModeSegmentedControlReportMode = @"LTEXT_MODESEGMENTEDCONTROL_REPORTMODE";

const NSUInteger kGlobalIndexForYearInContextScrollView = 0;

NSString * const kNibConceptCellName = @"IAEEditModeConceptCollectionViewCell";
NSString * const kIdConceptCellName = @"EditModeConceptCell";

NSString * const kNibConceptCellHeaderInYearModeName = @"IAEEditModeConceptCollectionViewHeader";
NSString * const kCollectionViewHeaderIdentifier = @"EditModeConceptHeader";

const NSUInteger kSegmentedControlIndexEditMode = 0;
const NSUInteger kSegmentedControlIndexReportMode = 1;

const NSUInteger kReportMenuIndexOfBalancesOption = 0;
const NSUInteger kReportMenuIndexOfIncomesOption = 1;
const NSUInteger kReportMenuIndexOfExpensesOption = 2;

const CGFloat kDurationStrokeAnimationForConcepts = 0.25;
const CGFloat kColorWhiteComponentForStrokeAnimationForConcepts = 0.8;
const CGFloat kColorWhiteAlphaComponentForStrokeAnimationForConcepts = 1.0;
const NSInteger kTypeStrokeAnimationForConcepts = STROKEANIMATABLE_TYPE_THIN;
const CGFloat kDelayToExecuteRemoveConceptCell = 0.2;

const CGFloat KDurationOfAnimationUpdateForEntryInstantIndex = 0.5;

const CGFloat kDurationOfEditConceptCollectionViewTransition = 0.5;

NSString * const kXibWithoutConceptsWarningInEditModeViewName = @"IAEWithoutConceptsTextWarning";
NSString * const kXibWithoutConceptsWarningInReportModeViewName = @"IAEWithoutConceptsTextWarningReportMode";
const CGFloat kDurationOfWithoutConceptsWarningVieTransition = 0.5;

const NSInteger kInvalidOptionIndex = -1;

const CGFloat kFrecuencyForContainerFXAttachBehavior = 1;
const CGFloat kDampingForContainerFXAttachBehavior = 0.5;

const CGFloat kDurationModeFadeOut = 0.35;
const CGFloat kDurationModeFadeIn = 0.75;

const CGFloat kXMarginBaseForConceptCellPopover = 40.0;
const CGFloat kYMarginBaseForConceptCellPopover = 10.0;

const NSUInteger kNumberOfMonths = 12;

const NSUInteger kAlertViewButtonCancelIndex = 0;
const NSUInteger kAltertViewButtonConfirmationIndex = 1;

const CGFloat kAnimationForReloadDataAfterRemoveAllConcepts = 0.3;


#endif
