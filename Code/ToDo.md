# ToDo: Easy Incomes and Expenses.

* Zona del mes y balance.
** Hay que sustituir el ScrollView por otro elemento en el que podamos hacer algún tipo de transición especial. Lo ideal para empezar sería una view con dos subviews a modo de contenedores dentro de las cuales hubiera una label para el mes y otra para el balance.

* Selector de categorías
** -Tenemos pequeño problema: hemos supuesto en la clase principal, IAEEasyIncomesAndExpensesViewController, que la selección de una categoría sucede solo cuando hemos pulsado sobre un concepto, pero también puede ocurrir cuando desplegamos el selector tras pulsar en el botón de categorías. En este último caso, lo que ha de suceder es entrar en modo edición o renombrado de la misma. Hay que generalizar todo este funcionamiento.-
** Reforzar de alguna manera adicional qué es una categoría general.
** -Al borrar, recarga solo de la celda vinculada y con efecto fade en desaparición.-
*** Fondo.
*** -Permitir los gestos de acciones como renombrar o borrar.-
*** Mostrar alertviews o similares que indiquen el motivo por el cual no se puede manipular una categoría general.
** Considerar volver a poner rallas separatorias entre categorías.
** -Eliminar cualquier rastro de menú contextual.- 
*** -Para borrar una categoría, implementar el gesto asociado a la eliminación de un concepto. Duda sobre si se debería de permitir el borrado en modo popover.-
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
** El color sigue siendo azul para los controles fundamentales.
** Considerar que los años que no tengan conceptos sean más pequeños como celda.
** Estudiar cuál será el color cuando el balance sea cero.
** Considerar un botón que cambie de orden los años de menor a mayor. Al menos, quizás, para cuando estamos en modo años con conceptos.
** Cuando se abra el modal, deberíamos de irnos a la sección que contenga el año y además mostrar la celda asociada en pantalla.

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

* Ideas
** Representar en modo reporte o informe una gráfica de puntos en la zona donde está el nombre del mes y el balance reflejando de manera diferenciada el mes en el que estamos. Esto serviría para contrastar el balance, el total de ingresos o el total de gastos del mes con respecto al resto.
