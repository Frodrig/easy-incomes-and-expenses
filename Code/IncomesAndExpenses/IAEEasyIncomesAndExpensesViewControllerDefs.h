//
//  IAEEasyIncomesAndExpensesViewControllerDefs.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#ifndef IncomesAndExpenses_IAEEasyIncomesAndExpensesViewControllerDefs_h
#define IncomesAndExpenses_IAEEasyIncomesAndExpensesViewControllerDefs_h

typedef NS_ENUM(NSUInteger, MonthSelectorPurpose) {
    MonthSelectorPurposeCopy,
    MonthSelectorPurposeMove,
};

extern const CGFloat kSelectorContextViewYOutsideMargin;

extern const CGFloat kDurationInitializationAnimationNavigationFadeIn;
extern const CGFloat kDurationInitializationAnimationContextAndModesFadeIn;
extern const CGFloat kDurationInitializationAnimationTraslantionFadeIn;

extern NSString * const kLTextNavigationBarTitle;
extern NSString * const kLTextSettingsBarButtonTitle;
extern NSString * const kLTextYearsBarButtonTitle;
extern NSString * const kLTextCategoriesBarButtonTitle;
extern NSString * const kLTextFavoritesBarButtonTitle;

extern NSString * const kUserDefaultsDayModeActive;

extern NSString * const kNotificationDayModeOnName;
extern NSString * const kNotificationDayModeOffName;
extern NSString * const kNotificationInitialMonthChanged;
extern NSString * const kNotificationMainLabelTitleTouched;
extern NSString * const kNotificationKeyboardResignFromEditingConceptsNotes;
extern NSString * const kNotificationKeyboardSignForEditingConceptsNotes;
extern NSString * const kNotificationEndEditingNoteForModeConceptCollectionViewCell ;

extern NSString * const kLTextModeSegmentedControlEditMode;
extern NSString * const kLTextModeSegmentedControlReportMode;

extern const NSUInteger kGlobalIndexForYearInContextScrollView;

extern NSString * const kNibConceptCellName;
extern NSString * const kIdConceptCellName;

extern NSString * const kNibConceptCellHeaderInYearModeName;
extern NSString * const kCollectionViewHeaderIdentifier;

extern const NSUInteger kSegmentedControlIndexEditMode;
extern const NSUInteger kSegmentedControlIndexReportMode;

extern const NSUInteger kReportMenuIndexOfBalancesOption;
extern const NSUInteger kReportMenuIndexOfIncomesOption;
extern const NSUInteger kReportMenuIndexOfExpensesOption;

extern const CGFloat kDurationStrokeAnimationForConcepts;
extern const CGFloat kColorWhiteComponentForStrokeAnimationForConcepts;
extern const CGFloat kColorWhiteAlphaComponentForStrokeAnimationForConcepts;
extern const NSInteger kTypeStrokeAnimationForConcepts;
extern const CGFloat kDelayToExecuteRemoveConceptCell;

extern const CGFloat KDurationOfAnimationUpdateForEntryInstantIndex;

extern const CGFloat kDurationOfEditConceptCollectionViewTransition;

extern NSString * const kXibWithoutConceptsWarningInEditModeViewName;
extern NSString * const kXibWithoutConceptsWarningInReportModeViewName;
extern const CGFloat kDurationOfWithoutConceptsWarningVieTransition;

extern const NSInteger kInvalidOptionIndex;

extern const CGFloat kFrecuencyForContainerFXAttachBehavior;
extern const CGFloat kDampingForContainerFXAttachBehavior;

extern const CGFloat kDurationModeFadeOut;
extern const CGFloat kDurationModeFadeIn;

extern const CGFloat kXMarginBaseForConceptCellPopover;
extern const CGFloat kYMarginBaseForConceptCellPopover;

extern const NSUInteger kNumberOfMonths;

extern const NSUInteger kAlertViewButtonCancelIndex;
extern const NSUInteger kAltertViewButtonConfirmationIndex;

extern const CGFloat kAnimationForReloadDataAfterRemoveAllConcepts;

#endif
