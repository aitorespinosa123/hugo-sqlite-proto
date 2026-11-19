

# Hugo + SQLite (solo en build). Cada objetivo hace una cosa.
.DEFAULT_GOAL := help
.PHONY: index build serve serve-drafts check clean check-invites test migrar help

index:   ## Markdown → SQLite → static/search.json + data/tags.json
	python3 tools/index.py

build: index   ## Genera el sitio estático en public/ (esto es lo que se despliega)
	hugo --gc --minify

serve: index   ## Servidor local con recarga: http://localhost:1313/
	hugo server

# APORTACION PROPIA: incluir borradores en Hugo y en la búsqueda
serve-drafts:   ## Servidor local con borradores incluidos en SQLite
	python3 tools/index.py --drafts
	hugo server -D --bind 0.0.0.0 --port 1313

check: index   ## Valida que los JSON generados son JSON de verdad
	python3 -m json.tool static/search.json > /dev/null
	python3 -m json.tool data/tags.json > /dev/null
	@echo "check: OK"

clean:   ## Borra todo lo generado (public/, resources/, build/, JSON)
	rm -rf public resources build static/search.json data/tags.json .hugo_build.lock

# P1.2: pruebas de las funciones puras del script de migración
test:   ## Prueba las funciones puras de tools/migrar.py
	python3 -m unittest discover -s tools -v

# P1.2: migración de Hugo a Chyrp Lite con SQLite
migrar:   ## Markdown → SQLite de Chyrp Lite: make migrar DESTINO=/ruta/copia.sqlite [SIMULACRO=1]
	@test -n "$(DESTINO)" || { echo "Uso: make migrar DESTINO=/ruta/copia.sqlite [SIMULACRO=1]"; exit 1; }
	python3 tools/migrar.py --destino "$(DESTINO)" $(if $(SIMULACRO),--simulacro,)

check-invites:   ## [profesor] Lista invitaciones de colaborador pendientes (gh auth login)
	@gh api user/repository_invitations --jq '.[] | "\(.id)\t\(.repository.full_name)\tinvited_by=\(.invited_by.login)\t\(.created_at)"' \
		| { grep . || echo "Sin invitaciones pendientes."; }

help:   ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
