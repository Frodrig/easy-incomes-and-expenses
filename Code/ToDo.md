# ToDo: Easy Incomes and Expenses.

* Zona del mes y balance.
** Hay que sustituir el ScrollView por otro elemento en el que podamos hacer algún tipo de transición especial. Lo ideal para empezar sería una view con dos subviews a modo de contenedores dentro de las cuales hubiera una label para el mes y otra para el balance.

* Selector de categorías
** Reforzar de alguna manera adicional qué es una categoría general.
** Mostrar alertviews o similares que indiquen el motivo por el cual no se puede manipular una categoría general.
** Considerar volver a poner rallas separatorias entre categorías.
** -Meter el número de conceptos asociados a la categoría de forma global (para todos los años).-
** -El stroke al borrar debería de tener márgenes al empezar y finalizar.-
** -Tenemos pequeño problema: hemos supuesto en la clase principal, IAEEasyIncomesAndExpensesViewController, que la selección de una categoría sucede solo cuando hemos pulsado sobre un concepto, pero también puede ocurrir cuando desplegamos el selector tras pulsar en el botón de categorías. En este último caso, lo que ha de suceder es entrar en modo edición o renombrado de la misma. Hay que generalizar todo este funcionamiento.-
** -Al borrar, recarga solo de la celda vinculada y con efecto fade en desaparición.-
** -Permitir los gestos de acciones como renombrar o borrar.-
** -Eliminar cualquier rastro de menú contextual.- 
** -Para borrar una categoría, implementar el gesto asociado a la eliminación de un concepto. Duda sobre si se debería de permitir el borrado en modo popover.-
*** -Para seleccionar una categoría para renombrar, simplemente selección de la celda.-

* Calculadora
** Hay que implementar arrastre. Cuando arrastramos hacia arriba el resto de elementos suben pero usando dynamics.
** Las categorías están condenadas a que no se vean enteras. Considerar meter el label en un scrollview y poder hacer pan para verla en su totalidad.
** Gesto de borrado sobre la cantidad económica para borrarla completamente.
** Comprobar que aguantamos las cantidades numéricas máximas que aguantábamos en la versión previa.
** Hay que mejorar el aspecto visual del teclado. Hay que estudiar que usemos un color uniforme, rejilla y similares.
** Considerar que el display se tinte dependiendo de si estamos en modo ingreso o en modo gasto.
** Intentar ganar dos píxeles de alto para dárselos a los botones de categoría y día y pasen de ser de 43 a 44.
** Considerar usar símbolo ^ e inverso en el panel de draga que cambie a medida que hacemos el arrastre. Considerar si, entonces, tiene sentido poner "Inserción".
** Cuando estemos en modo NO día deberíamos de aprovechar la zona destinada para mostrar el mes y día de la semana para indicar el mes y el número de concepto que vamos a introducir. Del mismo modo, valorar incluir en ese punto el año en el que nos encontramos.

* Años
** -Cuando cambio de sección, siempre me posiciono donde se halle el año abierto.-
** -Quitar el menú contextual para ir a un año-
*** -El año se abre pulsando en la celda-
*** -Implementar el borrado o vaciado del año mediante gesto-
** -El color sigue siendo azul para los controles fundamentales.-
** -Definir cuál será el color cuando el balance sea cero.-
** -Hay que incluir el número de conceptos que tiene el año.-
** -Cuando se abra el modal, deberíamos de irnos a la sección que contenga el año y además mostrar la celda asociada en pantalla. Probar qué ocurre cuando abrimos el modal desde un año sin conceptos y con conceptos. Probarlo con el cuadro de diálogo con información que rebase el área de visión y viceversa.-

* Modo informe
** Al ir haciendo scroll, ir haciendo desaparecer lo que queda más fuera de la pantalla.
** Cuando pasamos a este modo, animación haciendo crecer las barras y/o números asociados. Esto lo haríamos en TODAS las barras, independientemente de si están en pantalla o no.
*** Considerar que las esquinas superiores derecha estén redondeadas en las gráficas.

* Settings
** Localizar.
** Enlace a web.

* Menú de texto
** Usar dynamics para desplazar la raya inferior con cierto rebote.

* Otros
** Comprar los nuevos glyphs e introducirlos.
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
