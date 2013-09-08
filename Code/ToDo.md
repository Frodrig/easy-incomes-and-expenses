# ToDo: Easy Incomes and Expenses.

* Settings
** Si se compra dominio, poner el enlace definitivo.

* Inicio e iconos
** A la espera de solucionar el bug de la pantalla de inicio.

* Web
** General
*** Presentación
*** Soporte
*** Acerca de
*** Versión Pro
** Localización

* En años, al vaciar el único año que haya en "años con conceptos" debemos de pasar a Todos los años automáticamente. De hecho, deberíamos de deshabitar en ese caso esa pestaña

* Iconos más pequeños de tamaño (29 y 40)

* Refactorización
** En todos los sitios donde vuelvo a recrear la fuente y su tamaño… simplemente cambiar el campo text para la label asociada. Esto es válido a no ser que tenga que poner kern.
*** En el caso de poner kern, la otra opción es obtener el diccionario de atributos, setear el kern y volver a recrear con esos atributos y el título que proceda.
** Las properties readonly se pueden redefinir en .m para que sean readwrite. Hay casos en los que debería de hacerlo.
** En la calculadora, implementar la rejilla usando drawRect: en lugar de disponer de varias UIViews en el Xib
** La gestión de los conceptos ha de pasar por Fecther para no cargar todo a la vez.
** OpenYear NO debería de crear todo en memoria, usar algún cacheado con el fin de que saber el numero de conceptos de un año y balance no fuera tan costoso y se usara un plist y punto.

* Funcionalidades seguras versión pro:
** Sincronización iCloud
** Impresión
** Contraseña

* Ideas
** Conceptos
*** Poder manipularlos desde la pestaña global
** Calculadora:
*** Tachar supondría no dibujar la raya y si enviar lejos la cantidad
** Mes actual
** Si estamos con el año actual abierto, mostramos algún indicativo sobre el mes actual.
** Años
*** Considerar un color diferente en el menú de contexto
*** Considerar alguna animación característica al cambiar en el menú de contexto.
*** Que se pueda deshablitar acceso a meses aún no disponibles.
*** Que se pueda deshabilitar el tener en cuenta valores económicos de meses no cumplidos.
*** Considerar que los años que no tengan conceptos sean más pequeños como celda.
*** Considerar que cuando nos ponemos sobre la celda de año actual, las entradas sean muy pequeñas para poder ver más elementos
*** Considerar un botón que cambie de orden los años de menor a mayor. Al menos, quizás, para cuando estamos en modo años con conceptos.
** Informes
*** Cuando haya scroll posible, mostrar indicadores en los laterales.
*** Representar en modo reporte o informe una gráfica de puntos en la zona donde está el nombre del mes y el balance reflejando de manera diferenciada el mes en el que estamos. Esto serviría para contrastar el balance, el total de ingresos o el total de gastos del mes con respecto al resto.
*** Poder variar la cantidad de elementos mostrados a la vez en pantalla evitando scroll.
*** Posibilidad de mostrar la información usando diferentes parámetros (orden alfabético en lugar de tamaño)
** Selector de categorías
*** Incluir la posibilidad de trabajar con TableView indexada.
** Contextos:
*** En versión pro, considerar el permitir cambiar de año deslizando sobre el panel de contexto.
** Conceptos
*** En el anual introducción de un índice para ir rápido.
*** En la zona de conceptos anuales, permitir contraer o desplegar los meses a fin de ver su contenido. Bastaría con pulsar en el header.

