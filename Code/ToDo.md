# ToDo: Easy Incomes and Expenses.

* Barra superior
** -Pensar en como indicar que es un botón el título central.-

* Contextos
** Cambiar de contexto A a contexto B y antes de que B esté en pantalla cambiar a A, hace doble carga sobre el contenido de A.

* Settings
** Si se compra dominio, poner el enlace definitivo.

* Cantidades
** -En selector de años y selector de categorías, de cero a nueve con letra y superiores con número.-

* Concepto
** El elemento seleccionado, hacer que tenga una animación muy breve

* Año
** -No aparece correctamente centrado el año abierto-
** -Valorar poner heder para cada opción pulsada-
*** -No, el segmented es suficientemente explicativo y restamos espacio para mostrar años-
** -Mejorar la localización de las opciones segmented-
** -Valorar migrar a TableView para conseguir animación de recarga-
*** -Sin tiempo para hacerlo: implementado fadein y fadeout-

* Categorías
** -Sin localizar textos del segmented-
** -Animación de fade al cambiar entre tipo de categoría-
** -Valorar poner header-
*** -Mejor no, pues taparía zona de trabajo. Cuantas más categorías se vean a la vez, mejor.-

* Segmented de cambio de modo
** -Sin localizar-

* Inicio e iconos
** A la espera de solucionar el bug de la pantalla de inicio.
** Icono

* Ayuda
** ¿Podemos meter algo?

* Refactorización
** En todos los sitios donde vuelvo a recrear la fuente y su tamaño… simplemente cambiar el campo text para la label asociada. Esto es válido a no ser que tenga que poner kern.
*** En el caso de poner kern, la otra opción es obtener el diccionario de atributos, setear el kern y volver a recrear con esos atributos y el título que proceda.
** Las properties readonly se pueden redefinir en .m para que sean readwrite. Hay casos en los que debería de hacerlo.
** En la calculadora, implementar la rejilla usando drawRect: en lugar de disponer de varias UIViews en el Xib
** Vigilar los ToDo del código en forma de comentario

* Funcionalidades seguras versión pro:
** Sincronización iCloud
** Impresión
** Contraseña

* Ideas
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

