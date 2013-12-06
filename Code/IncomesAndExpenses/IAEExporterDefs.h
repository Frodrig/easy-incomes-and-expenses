//
//  IAEExporterDefs.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 06/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#ifndef IncomesAndExpenses_IAEExporterDefs_h
#define IncomesAndExpenses_IAEExporterDefs_h

static NSString * const kExportCSVFileNameWithExtension = @"export.csv";
static NSString * const kExportPDFVFileNameWithExtension = @"export.pdf";

static NSString * const kPDFExportTitle = @"";
static NSString * const KPDFExportName = @"";

static NSString * const kKeyWhereCSV = @"where_csv";
static NSString * const kKeyWherePDF = @"where_pdf";
static NSString * const kKeyWherePrint = @"where_print";
static NSString * const kKeyWhatOptions = @"what_options";
static NSString * const kKeyMonthSelected = @"month_selected";

static NSString * const kValueWhatOptionGlobalsReport = @"globals_report";
static NSString * const kValueWhatOptionMonthsReport = @"months_report";
static NSString * const kValueWhatOptionConceptsReport = @"concepts_report";

static NSString * const kKeyExportedDataSelectedMonths = @"selectedMonths";
static NSString * const kKeyExportedDataTotals = @"totals";
static NSString * const kKeyExportedDataBalance = @"balance";
static NSString * const kKeyExportedDataIncomes = @"expenses";
static NSString * const kKeyExportedDataExpenses = @"incomes";
static NSString * const kKeyExportedDataSelfMonth = @"self";
static NSString * const kKeyExportedDataIncomeCategories = @"incomesByCategory";
static NSString * const kKeyExportedDataExpenseCategories = @"expenseByCategory";
static NSString * const kKeyExportedDataTotalsByMonths = @"totalsByMonth";
static NSString * const kKeyExportedDataIncomeCategoriesByMonth = @"incomesByMonthAndCategories";
static NSString * const kKeyExportedDataExpenseCategoriesByMonth = @"expensesByMonthAndCategories";
static NSString * const kKeyExportedDataConceptsByMonth = @"conceptsBytMonth";
static NSString * const kKeyExportedDataConcepts = @"concepts";

#endif
