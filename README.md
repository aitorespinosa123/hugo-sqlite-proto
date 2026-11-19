# hugo-sqlite-proto

Prototipo didáctico: **Hugo** genera HTML estático desde Markdown y **SQLite** trabaja
**solo en tiempo de build** (indexar y agregar). En producción: ficheros estáticos, nada más.

Continuación de la práctica
[P1.2 — Tu mini sitio web con Hugo](https://www.librebits.info/2asir/iaw/mini-sitio-web-con-hugo/).

**Demo en vivo:** [fp-bits.github.io/hugo-sqlite-proto](https://fp-bits.github.io/hugo-sqlite-proto/)

## Hugo build 
El generador de sitios web estático [Hugo](https://gohugo.io/documentation) construye 'las páginas web html (+ css, +javascript)' cuando ejecutas 'hugo serve' desde la terminal.
Ese comando detecta cambios en `content/` y `layouts/` y reconstruye el sitio automáticamente, sin que tengas que parar y volver a arrancar nada.
 
## Idea ([Unix](https://es.wikipedia.org/wiki/Unix): cada pieza hace una cosa, se unen con ficheros, a modo 'tuberías')

```
content/*.md --> tools/index.py --> build/site.db --+--> static/search.json --> navegador (search.js)
 (Markdown)       (parsea + INSERT)   (SQLite, local) +--> data/tags.json -----> Hugo (layouts/index.html)

                                     hugo --> public/   <- lo único que se despliega
```

`build/`, `static/search.json` y `data/tags.json` están en `.gitignore`: se **regeneran** en cada build.

## Requisitos

- [Hugo](https://gohugo.io/installation/) (versión estándar, no hace falta *extended*)
- Python 3.8+ (solo biblioteca estándar: [`sqlite3`](https://docs.python.org/3/library/sqlite3.html), `json`, `re`)
- `make`

## Uso

```bash
make            # == make help
make serve    # índice + servidor local en http://localhost:1313/
make build    # índice + hugo --gc --minify  → public/
make check    # valida que los JSON generados son JSON válido
make clean
make check-invites   # [profesor] invitaciones de colaborador pendientes (gh CLI)
```

## Estructura

```
content/            Markdown con front matter YAML (el borrador no se indexa ni se publica)
layouts/            Plantillas Hugo: baseof, single, list, index + parciales header/footer
static/search.js    Búsqueda en el navegador: vainilla ES6+, estilo funcional
static/style.css    CSS3 con variables y modo oscuro
tools/index.py      Markdown → SQLite → JSON (funciones puras + efectos al final)
Makefile            index · build · serve · check · clean
```

## Dónde mirar

- **SQL como generador de JSON**: `Q_SEARCH` y `Q_TAGS` en `tools/index.py`
  ([JSON1](https://www.sqlite.org/json1.html), `GROUP BY`, `COUNT`).
- **Datos de build en plantillas**: `hugo.Data.tags` en `layouts/index.html`
  ([Hugo data](https://gohugo.io/content-management/data-sources/)).
- **Búsqueda sin servidor**: `static/search.js` ([`fetch`](https://developer.mozilla.org/es/docs/Web/API/Fetch_API),
  [`filter`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/filter),
  [`normalize`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/String/normalize)).

## Ejercicios

1. Añade un post con `tags: [sql]` y comprueba cómo cambia el conteo de etiquetas en la home (`make serve`).
2. `hugo server -D` muestra el borrador, pero la búsqueda no lo encuentra. ¿Por qué? Añade un
   flag `--drafts` a `tools/index.py` para que coincidan.
3. Añade una tabla `words(url, n)` con el número de palabras de cada post y muestra el total en el pie.
4. Cambia la búsqueda para ordenar los resultados por número de coincidencias (sigue siendo una función pura).
5. Despliega `public/` con `rsync` a tu VPS o con GitHub Pages. ¿Qué proceso corre en el servidor? (Ninguno de tuyos.)

## Límites a propósito (KISS)

`tools/index.py` entiende front matter YAML simple (`clave: valor` y `tags: [a, b]`); no TOML ni listas
multilínea. Para algo más serio, usa una biblioteca de YAML: aquí lo importante es el *flujo*.

## Entregable

Haz un **fork** (o clona y crea tu propio repo) de este proyecto, resuelve los `Ejercicios` que quieras
de los de arriba (no hace falta hacerlos todos) y haz **varios commits** a medida que avanzas.

La práctica se considera entregada en el momento en que **invitas al profesor** (usuario de GitHub
`fenix011`) **como colaborador** de tu repositorio. Sigue estos pasos de la documentación oficial de
GitHub en español:
[Invitar a colaboradores a un repositorio personal](https://docs.github.com/es/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/inviting-collaborators-to-a-personal-repository).

No hace falta sFTP ni capturas: con la invitación aceptada, el profesor ya puede clonar tu repo y revisarlo.

---

# RUBRICA DE CALIFICACIÓN
## Criterios de contenido (10 puntos)

### Implementación técnica — 7 puntos

| **Criterio** | **Peso** | **Qué se valora** |
|:---|:---:|:---|
| **Entorno funcionando** | 1p | `make serve`, `make build` y `make check` corren sin errores sobre tu fork/copia |
| **Ejercicios resueltos** | 3p | Al menos 2 de los 5 `Ejercicios` propuestos, funcionando de verdad (no hace falta hacer los 5) |
| **Comprensión del flujo** | 2p | Se entiende cómo encajan `tools/index.py` → SQLite → JSON → Hugo en los cambios hechos (visible en el código o explicado en el README) |
| **Calidad del código añadido** | 1p | Estilo coherente con el proyecto (funciones puras donde aplica, nombres claros) |

### Más allá de lo técnico — 3 puntos

| **Criterio** | **Peso** | **Qué se valora** |
|:---|:---:|:---|
| **Aportación propia** | 1p | Algo más allá del mínimo pedido en los ejercicios elegidos |
| **Documentación del cambio** | 1p | El README (o un commit) explica qué se ha hecho y por qué |
| **Entregable completo y verificable** | 1p | Invitación a `fenix011` aceptada, repo clonable, commits reales |

## Convención en vivo vs. online, con matiz de `git log`

Esta práctica se entrega vía repositorio GitHub: 
- **10/10** — demo en vivo (en el aula) **y** `git log` con trabajo real incremental (varios commits, marcas de
  tiempo realmente separadas, mensajes no genéricos. Es decir, decriptivos de los cambios realizados!).
- **Intermedio (hasta 9/10)** — sin demo en vivo, pero con esa misma evidencia en el `git log`.
- **Tope 7/10** — sin demo en vivo y sin evidencia en el `git log` (un commit, mensajes genéricos o
  timestamps agrupados).

## Escala orientativa

- **Excelente (9-10):** varios ejercicios resueltos y funcionando, código claro, demo en vivo y/o
  `git log` con evidencia real.
- **Notable (7-8.9):** 2+ ejercicios resueltos y funcionando, algún detalle menor.
- **Suficiente (5-6.9):** el entorno corre pero los ejercicios resueltos son mínimos o tienen fallos.
- **Insuficiente (<5):** el entorno no llega a funcionar (`make build` falla) o no hay ningún ejercicio
  resuelto.

## Lista de comprobación rápida (para nosotros, el profesorado :-)

```bash
git clone https://github.com/<alumno>/<repo>.git && cd <repo>
make check && make build
git log --format='%h %ad %s' --date=iso | head -20
```

## Plantilla de feedback

```
## Feedback
- Qué ha ido bien: …
- A mejorar: …
- ¿Has pensado en usar `git` desde la terminal para hacer los cambios... a lo Pro? ;-)
```

"Recuerda ... KISS!" :-)



---

## Trabajo realizado - Aitor Espinosa (2º ASIR)

### Preparación del entorno

He utilizado Ubuntu con Python 3.8 y Hugo 0.68.3.

Para que el proyecto funcionara con mi versión de Hugo,
he renombrado hugo.toml a config.toml y he adaptado
la plantilla layouts/index.html para utilizar .Site.Data.tags.

He comprobado que make check, make build y make serve
funcionan correctamente.

### Ejercicio 1 - Nueva publicación con SQL

He creado el archivo content/posts/sql-en-mi-web.md
con la etiqueta tags: [sql].

Al ejecutar make check, el indexador pasó de 4 a 5
páginas. También comprobé que apareció la etiqueta
sql con contador 1 en la página principal.

Esto demuestra que las etiquetas se actualizan
automáticamente al generar el índice.

### Ejercicio 2 - Incluir borradores en la búsqueda

He modificado tools/index.py para añadir la opción
--drafts.

Antes, el indexador excluía siempre los borradores.
Ahora podemos elegir si queremos incluirlos.

Comprobaciones realizadas:

- python3 tools/index.py: 5 páginas indexadas.
- python3 tools/index.py --drafts: 6 páginas indexadas.

Para comprobarlo en el navegador, ejecuté el
indexador con --drafts y después hugo server -D.

Al buscar "secreto" apareció la publicación
"Esto es un borrador".

Normalmente los borradores siguen excluidos.
La opción --drafts permite incluirlos cuando
necesitamos probarlos.

### Funcionamiento de Hugo y SQLite

El proceso funciona de la siguiente manera:

1. Los contenidos se escriben en archivos Markdown.
2. tools/index.py lee los archivos y sus etiquetas.
3. SQLite organiza la información y cuenta las etiquetas.
4. Se generan static/search.json y data/tags.json.
5. Hugo utiliza esos datos para construir la web.
6. El navegador realiza las búsquedas utilizando JavaScript.

SQLite solo se utiliza durante la construcción.
La web final funciona con archivos estáticos,
sin necesidad de una base de datos en el servidor.




### Aportación propia - Comando serve-drafts

He añadido un nuevo comando al Makefile para facilitar las pruebas con borradores:

```bash
make serve-drafts
```

Este comando ejecuta automáticamente dos operaciones:

1. `python3 tools/index.py --drafts`: incluye los borradores en el índice de SQLite.
2. `hugo server -D --bind 0.0.0.0 --port 1313`: inicia Hugo mostrando también los borradores.

De esta forma puedo comprobar los borradores y buscarlos desde el navegador utilizando un único comando.

He probado su funcionamiento buscando "secreto" y comprobando que aparece la publicación "Esto es un borrador".

Para generar la web definitiva se sigue utilizando `make build`, que excluye los borradores.

## P1.2 - Migracion de Hugo a Chyrp Lite

En la rama chyrp-lite se realiza una migracion de las entradas Markdown
de Hugo a una base de datos SQLite de Chyrp Lite.

### Archivos principales

- tools/migrar.py: script de migracion.
- tools/test_migrar.py: pruebas automaticas.
- tools/migrar_experimento.py: experimento con transaccion y rollback.
- tools/migrar_sin_transaccion.py: experimento sin transaccion.
- Makefile: comandos de ejecucion.

### Como ejecutar

Pruebas automaticas: make test

Simulacro: make migrar DESTINO=/ruta/copia.sqlite SIMULACRO=1

Migracion real: make migrar DESTINO=/ruta/copia.sqlite

El destino debe ser una copia de una base de datos SQLite ya inicializada
por Chyrp Lite. La migracion evita duplicar las entradas existentes.

### Comprobaciones

- Simulacro, migracion real y repeticion sin duplicados.
- Verificacion de entradas, borradores y etiquetas en SQLite y navegador.
- Comparacion de transacciones con rollback y sin transaccion.
- Correccion de etiquetas numericas.
- Las 12 pruebas automaticas terminan correctamente.

El informe de la practica se encuentra en P1.2-Espinosa.md.

