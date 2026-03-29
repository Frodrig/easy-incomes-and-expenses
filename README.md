# Easy Incomes and Expenses

A smart and simple personal finance app for iPad.

https://frodrig.github.io/easy-incomes-and-expenses/

Easy Incomes and Expenses lets you monitor your incomes and expenses easily. A ledger for each year, organised by month, where you can log every operation with categories that help you understand where your money goes. No unnecessary features. A simple application that looks nice and elegant.

It was available on the App Store as a paid app with in-app purchases for the Pro version. It reached the top 10 finance apps in the Spanish App Store and top 3 for one week. Built in 2013, no longer maintained. This is an archived release.

![screenshot]("Art/ScreenShots/V3 - Pro/EN - UK/01ENUK.png")

## Features

Income and expense tracking organised by year and month, user-defined categories, balance summaries, CSV export via email, in-app purchases for Pro features, gesture-based calculator interface and English and Spanish localisation.

## Code

Written in Objective-C for iPad only, targeting iOS 5 and later. Uses UIKit, Core Data for persistence, StoreKit for in-app purchases and MessageUI for CSV export.

The architecture follows MVC with a Core Data model of four entities (Year, Month, Concept, Category), singleton managers for data and formatting, and extensive use of delegate protocols. Financial calculations use NSDecimalNumber throughout to avoid floating point rounding errors.

265 source files, around 22,000 lines of code. The main view controller is very large (over 3,000 lines) which was a common pattern in iOS apps of that era. The code is production-tested and was sold on the App Store.

## How to run

Open the Xcode project inside the Code folder. The project targets iOS 5 and was last built against an older Xcode version so there will be warnings with modern tooling. It is provided as a historical reference, not as a starting point for new development.

## Web

The original product website is in the Web folder. It was built with iWeb in 2013.

## Built by

Fernando Rodríguez Martínez. frodrig76@gmail.com
