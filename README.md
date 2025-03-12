# Climora

# Problema y Solución

El principal desafío fue obtener datos climáticos de una API externa para las ciudades favoritas de los usuarios, y permitir que pudieran visualizar, agregar y eliminar estas ciudades según sus preferencias. Para resolverlo, se crearon componentes LiveView que permitían a los usuarios visualizar sus ciudades favoritas, añadir nuevas y eliminar las que ya no desearan. Además, se diseñó un cliente específico, **OpenWeatherClient**, que gestiona la consulta a la API para obtener la información climática de las ciudades seleccionadas. Las ciudades favoritas se almacenaron en tablas en la base de datos, permitiendo persistir las elecciones de los usuarios.

# Arquitectura Elegida

**Base de Datos:** Se crearon dos tablas principales:

- **locations:** Almacena información sobre cualquier tipo de ubicación (por ejemplo, ciudades), con la capacidad de añadir futuros tipos de locación (como regiones). Incluye un campo `type` para diferenciar el tipo de locación y un campo `metadata` para guardar información adicional personalizada.
- **user_favorite_locations:** Almacena las ciudades que los usuarios han marcado como favoritas.

**Módulo OpenWeatherClient:** Este módulo encapsula toda la lógica relacionada con la consulta de la API externa. Contiene configuraciones de las URLs de la API y la clave de acceso, lo que facilita el mantenimiento y las actualizaciones de la configuración.

**Módulos HomeLive y City:**

- **HomeLive:** Administra la lógica para mostrar las ciudades favoritas y permitir que los usuarios agreguen o eliminen ciudades.
- **CityLive:** Se encarga de mostrar la información detallada de cada ciudad, incluyendo la temperatura actual, las temperaturas mínimas y máximas para los próximos 7 días, y la temperatura por hora de las próximas 24 horas.

**Configuración de Entornos:**  
Para garantizar un entorno de pruebas adecuado y evitar hacer llamadas reales a la API externa durante los tests, se configuró un **MockOpenWeatherClient** en el entorno de pruebas. Este mock simula las respuestas de la API, permitiendo realizar pruebas controladas sin depender de la disponibilidad o la respuesta real de la API externa.

Por otro lado, en los entornos de desarrollo y producción, se utiliza el módulo **OpenWeatherClient** para realizar consultas reales a la API externa. 


# Trade-offs y Mejores Prácticas

**Trade-offs en la Implementación:**

- **Simplicidad vs. Flexibilidad:** La estructura de datos es relativamente simple, y los campos `metadata` y `type` en la tabla **locations** agregan flexibilidad para manejar diferentes tipos de ubicaciones. Sin embargo, aunque esta flexibilidad puede ser útil para futuros cambios o ampliaciones, también podría agregar complejidad a las consultas o inserciones en la tabla.

- **Complejidad de Configuración:** Para mantener un control más detallado sobre las configuraciones de la API, se configuraron entornos específicos para desarrollo y pruebas. Esto implica que añadir nuevas funcionalidades al cliente también requiere modificar el mock correspondiente. Además, es necesario tener un cuidado especial con las configuraciones específicas para cada entorno.


**Si tuviera más tiempo:**

- **Pruebas más robustas:** A pesar de haber escrito un módulo de pruebas (**HomeLiveTest**), creo que hay oportunidades para ampliar y mejorar el conjunto de pruebas. Podría incluir pruebas más exhaustivas, especialmente en las interacciones con la API, para garantizar que las respuestas de la API se manejen correctamente.
  
- **Manejo de errores más detallado:** Mejorar el manejo de errores tanto a nivel de la API como en la visualización para ofrecer una mejor experiencia al usuario en caso de fallos.

- **Creación de usuarios:** Se utilizó el sistema de autenticación generado por **phx.gen.auth**, el cual es bastante amigable en desarrollo. Sin embargo, sería posible implementar lógica personalizada para la creación de usuarios y para la personalización de sus perfiles.
