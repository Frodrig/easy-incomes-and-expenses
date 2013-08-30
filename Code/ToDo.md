# ToDo: Easy Incomes and Expenses.

* Contextos
** -Se ubica de forma incorrecta los items al pulsarse en el menú.-
** Transiciones al pulsar en un contexto
*** Que sea suave la carga de conceptos
*** Al transicionar en conceptos, se ha perdido la transición con fade. Sin embargo, si lo que hay es un warning, sí que se produce esa transición.
**** Ya se realiza pero el código es MUY MEJORABLE Y OPTIMIZABLE habría que volver. Mirar el método updateContentInformationBasedInCurrentContext

* Barra superior
** -Localizar botones-
** -Quitar botón de gear-
** -Cambiar fuente botón settings-
** Pensar en como indicar que es un botón el título central.

* Modo Reporte
** -Al cambiar al modo reporte sale mal posicionado en la zona inferior.-

* Conceptos
** -Al borrar la última entrada no se borra la línea separadora de la celda en la entrada anterior-
** Al borrar, a veces, se produce salto a la hora de recargar el contenido. No he encontrado el patrón claro.

* Calculadora
** -Hay que implementar arrastre. Cuando arrastramos hacia arriba el resto de elementos suben pero usando dynamics.-

* Transiciones modo edición - informe
** -Hay que hacerlo más bonito.-
** Testear correcto funcionamiento

* Settings
** Si se compra dominio, poner el enlace definitivo.

* Abrir año
** -Si abrimos un año y nos situamos en un mes con contenido ocurre que, si venimos de otro que NO tenía contenido, no se quita el cartel de que NO hay conceptos.-

* Año abierto
** Recordarlo al salir de la aplicación y entrar de nuevo si y sólo sí tiene al menos un concepto. En caso contrario, iremos al año más reciente. 
** Considerar un color diferente en el menú de contexto
** Considerar alguna animación característica al cambiar en el menú de contexto.

* Inicio e iconos
** Pantalla de inicio
** Icono

* Problemas conocidos
** Al pasar de un mes sin conceptos en modo informe en la sección balance a otro adyacente con conceptos, no se cargo el informe de balance. Tuve que dar más saltos por la aplicación para que saliera. Lo he conseguido reproducir con relativa facilidad una vez visto.

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
*** En la zona de conceptos anuales, permitir contraer o desplegar los meses a fin de ver su contenido. Bastaría con pulsar en el header.

