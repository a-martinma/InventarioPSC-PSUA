# Base de Datos para el Inventario Nacional de PSC/PSUA

## Descripción del Proyecto

Este proyecto tiene como objetivo el desarrollo de una base de datos basada en MongoDB para gestionar el **Inventario Nacional de Parientes Silvestres de los Cultivos (PSC)** y **Plantas Silvestres de Uso Alimentario (PSUA)** en España. 

La base de datos está diseñada para almacenar información relevante sobre las especies, poblaciones y registros de observaciones, permitiendo una gestión eficiente de los recursos fitogenéticos y potenciando su uso.

Estos scripts corresponden a mi trabajo de fin de grado presentado en Julio de 2024. [Consulta más información aquí](https://burjcdigital.urjc.es/items/556c92a0-9db2-4aa2-86a0-7e1ff501911d)

## Características Principales

1. **Estructuración de Datos:**
   - Se han implementado diferentes estructuras para organizar los datos según las necesidades del sistema a partir de tres datasets principales.

   - La estructura **ColeccionesSeparadas** fue seleccionada como la más eficiente debido a su rapidez en consultas, eliminación de redundancia y flexibilidad para análisis complejos.

2. **Optimización del Sistema:**
   - Los tiempos de lectura y escritura son óptimos.
   - El tamaño total de los datos en la base de datos es reducido, favoreciendo el rendimiento.
   - Todo el proceso de carga y almacenamiento de datos asegura la eliminación de información irrelevante.

3. **Cumplimiento del Modelo Conceptual:**
   - La estructura de datos se mantiene fiel al modelo conceptual inicial.
   - Se realizaron modificaciones específicas en ciertos atributos para aumentar la funcionalidad y permitir consultas avanzadas.

4. **Base de Datos MongoDB:**
   - Se utiliza como almacenamiento principal, permitiendo escalabilidad y manejo eficiente de grandes volúmenes de datos.
   - La organización garantiza que la información esté libre de redundancia y sea relevante para los objetivos del sistema.

5. **Criterios de Evaluación:** 
   - Se evaluó el rendimiento de cada estructura en términos de tiempo de consulta, escritura y lectura, así como el espacio ocupado en la base de datos.


## Licencia

Este trabajo está bajo la licencia [Creative Commons Atribución-CompartirIgual 4.0 Internacional](https://creativecommons.org/licenses/by-sa/4.0/).
