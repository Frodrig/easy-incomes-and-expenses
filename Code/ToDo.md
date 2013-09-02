# ToDo: Easy Incomes and Expenses.

* Contextos
** Transiciones al pulsar en un contexto
*** Que sea suave la carga de conceptos
*** Al transicionar en conceptos, se ha perdido la transición con fade. Sin embargo, si lo que hay es un warning, sí que se produce esa transición.
**** Ya se realiza pero el código es MUY MEJORABLE Y OPTIMIZABLE habría que volver. Mirar el método updateContentInformationBasedInCurrentContext

* Barra superior
** Pensar en como indicar que es un botón el título central.

* Conceptos
** Al borrar, a veces, se produce salto a la hora de recargar el contenido. No he encontrado el patrón claro.

* Transiciones modo edición - informe
** Testear correcto funcionamiento

* Settings
** Si se compra dominio, poner el enlace definitivo.

* Gestión entrada y salida de la aplicación.
** Código relacionado.

* Año abierto
** Al salir de la aplicación recordamos el año abierto y mes en el que nos encontrábamos. Al volver de la aplicación, si ha pasado más de un día desde que saliéramos, cargamos el año actual y nos ponemos sobre el mes actual.
** Considerar un color diferente en el menú de contexto
** Considerar alguna animación característica al cambiar en el menú de contexto.

* Selección fecha
** -En inglés parece que está todo descolocado en un día. En español funciona bien.-

* Inicio e iconos
** Pantalla de inicio
** Icono

* Localización
** -Meses-
** -Categorías generales-

* Calculadora
** Estando en ingreso o gasto puedo elegir categorías del otro tipo. Si lo hago, debería de cambiar en la calculadora el tipo también de forma visual. Logicamente sí se introduce el concepto como la categoría que es.
** -Se ha quedado el tachado en rojo-
** -Se permite tachar aunque no haya valor alguno-

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
** Calculadora:
*** Tachar supondría no dibujar la raya y si enviar lejos la cantidad
** Mes actual
** Si estamos con el año actual abierto, mostramos algún indicativo sobre el mes actual.
** Años
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

