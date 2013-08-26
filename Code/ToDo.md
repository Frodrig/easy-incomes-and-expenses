# ToDo: Easy Incomes and Expenses.

* Transiciones al pulsar en un contexto
** Al transicionar en conceptos, se ha perdido la transición con fade. Sin embargo, si lo que hay es un warning, sí que se produce esa transición.
*** Ya se realiza pero el código es MUY MEJORABLE Y OPTIMIZABLE habría que volver. Mirar el método updateContentInformationBasedInCurrentContext

* Selector de categorías
** Reforzar de alguna manera adicional qué es una categoría general.
** Mostrar alertviews o similares que indiquen el motivo por el cual no se puede manipular una categoría general.
** Considerar volver a poner rallas separatorias entre categorías.

* Calculadora
** Hay que implementar arrastre. Cuando arrastramos hacia arriba el resto de elementos suben pero usando dynamics.
** Hay que mejorar el aspecto visual del teclado.
*** Incorporar una rejilla
*** Color diferenciador quizás
*** Considerar que el display se tinte dependiendo de si estamos en modo ingreso o en modo gasto.
** Intentar ganar dos píxeles de alto para dárselos a los botones de categoría y día y pasen de ser de 43 a 44.
** Considerar usar símbolo ^ e inverso en el panel de draga que cambie a medida que hacemos el arrastre. Considerar si, entonces, tiene sentido poner "Inserción".

* Modo informe
** Al ir haciendo scroll, ir haciendo desaparecer lo que queda más fuera de la pantalla.
** Cuando pasamos a este modo, animación haciendo crecer las barras y/o números asociados. Esto lo haríamos en TODAS las barras, independientemente de si están en pantalla o no.
*** Considerar que las esquinas superiores derecha estén redondeadas en las gráficas.

* Settings
** Localizar.
** Enlace a web.
** Información sobre la siguiente versión

* Menú de texto
** Usar dynamics para desplazar la raya inferior con cierto rebote.

* Inicio e iconos
** Pantalla de inicio
** Icono

* Otros
** En todos los sitios donde vuelvo a recrear la fuente y su tamaño… simplemente cambiar el campo text para la label asociada. Esto es válido a no ser que tenga que poner kern.
** ¿Tiene sentido permitir pulsar en categorías cuando está la calculadora abierta?
** El stroke hace alguna cosa rara aún: en el selector de categorías el view que contiene el label con el nombre hemos tenido que poner que haga clip de sus subviews y, además, al terminar de hacerse el stroke (esto para todos), se produce un pequeño glich que hace que se eleve un poco.

* Problemas conocidos
** Al ir a insertar un concepto habiendo cambiado de año, éste no aparecía en el panel de conceptos hasta que cambiaba de mes y volvía.
** Al abrir un año, no recargamos el menú de texto inferior.

* Ideas
** Años
*** Considerar que los años que no tengan conceptos sean más pequeños como celda.
*** Considerar un botón que cambie de orden los años de menor a mayor. Al menos, quizás, para cuando estamos en modo años con conceptos.
** Informes
*** Representar en modo reporte o informe una gráfica de puntos en la zona donde está el nombre del mes y el balance reflejando de manera diferenciada el mes en el que estamos. Esto serviría para contrastar el balance, el total de ingresos o el total de gastos del mes con respecto al resto.
