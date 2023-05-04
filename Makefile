.EXPORT_ALL_VARIABLES:

ZSH := $(shell command -v zsh 2> /dev/null) -ilc
SRC := share/{'git-process-output','rpm2cpio'}.zsh zinit{'','-additional','-autoload','-install','-side'}.zsh
DOC_SRC := $(foreach wrd,$(SRC),../$(wrd))

.PHONY: all clean container doc doc/container tags tags/emacs tags/vim test zwc

clean:
	rm -rvf *.zwc doc/zsdoc/zinit{'','-additional','-autoload','-install','-side'}.zsh.adoc doc/zsdoc/data/
	$(ZSH) 'zi delete --yes zdharma-continuum/zshelldoc; exit'

container:
	docker build --tag=ghcr.io/zdharma-continuum/zinit:latest --file=docker/Dockerfile .

deps:
	$(ZSH) "zi for make'PREFIX=$${ZPFX} install' nocompile zdharma-continuum/zshelldoc"

doc: deps
	cd doc; $(ZSH) -df "zsd -v --scomm --cignore '(\#*FUNCTION:[[:space:]][\~\-\:\+\@\__\-a-zA-Z0-9]*[\[]*|}[[:space:]]\#[[:space:]][\]]*)' $(DOC_SRC); make -C ./zsdoc pdf"

doc/container: container
	./scripts/docker-run.sh --docs --debug

test:
	zunit run

zwc:
	$(ZSH) 'for f in *.zsh; do zcompile -R -- $$f.zwc $$f || exit; done'
