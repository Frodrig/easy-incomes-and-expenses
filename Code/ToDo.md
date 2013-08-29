# ToDo: Easy Incomes and Expenses.

* Ajuste de la cantidad
** -Repasar visualmente-

* Conceptos
** En modo anual y cuando tengamos el día activado, habrá que activar barras de scroll
** El último que no saque línea separadora
** La línea separadora no está correctamente centrada

* Contextos
** Transiciones al pulsar en un contexto
*** Al transicionar en conceptos, se ha perdido la transición con fade. Sin embargo, si lo que hay es un warning, sí que se produce esa transición.
**** Ya se realiza pero el código es MUY MEJORABLE Y OPTIMIZABLE habría que volver. Mirar el método updateContentInformationBasedInCurrentContext

* Selector de categorías

* Calculadora
** Hay que implementar arrastre. Cuando arrastramos hacia arriba el resto de elementos suben pero usando dynamics.

* Modo informe

* Transiciones modo edición - informe
** Hay que hacerlo más bonito.

* Settings
** Localizar.
** Enlace a web.
** Información sobre la siguiente versión

* Menú de texto
** Usar dynamics para desplazar la raya inferior con cierto rebote.

* Inicio e iconos
** Pantalla de inicio
** Icono

* Problemas conocidos
** He logrado, cambiando de mes rápidamente y en modo reporte, hacer desaparecer el cursor sobre el tipo de informe elegido y no poder cambiarlo.
** En modo anual, hay situaciones en donde no cabe el numero de conceptos asociados a un mes.

* Otros
** -Limpiar etiquetas no usadas-
** En todos los sitios donde vuelvo a recrear la fuente y su tamaño… simplemente cambiar el campo text para la label asociada. Esto es válido a no ser que tenga que poner kern.
*** En el caso de poner kern, la otra opción es obtener el diccionario de atributos, setear el kern y volver a recrear con esos atributos y el título que proceda.
** ¿Tiene sentido permitir pulsar en categorías cuando está la calculadora abierta? ¿y en año?
*** Probablemente no.
** El stroke hace alguna cosa rara aún: en el selector de categorías el view que contiene el label con el nombre hemos tenido que poner que haga clip de sus subviews y, además, al terminar de hacerse el stroke (esto para todos), se produce un pequeño glich que hace que se eleve un poco.
** Las properties readonly se pueden redefinir en .m para que sean readwrite. Hay casos en los que debería de hacerlo.
** En la calculadora, implementar la rejilla usando drawRect: en lugar de disponer de varias UIViews en el Xib

* Ideas
** Años
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
