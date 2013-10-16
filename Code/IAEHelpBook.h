//
//  IAEHelpBook.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//
// Instrucciones
// La informacion se obtiene de las etiquetas de texto respetando una nomenclatura
// - LTEXT_HELPCONTENT_1 ... LTEXT_HELPCONTENT_N para indicar la cantidad de entradas en la ayuda
// - LTEXT_HELPCONTENT_X_Y_Z donde X indica la entrada en la ayuda, Y indica la página y Z la etiqueta de texto y su orden a mostrar en la pagina

#import <Foundation/Foundation.h>

@interface IAEHelpBook : NSObject

@property (nonatomic, strong, readonly) NSArray *themes;

+ (instancetype)sharedHelpBook;

- (instancetype)init;

- (void)description;

@end
