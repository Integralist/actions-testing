.PHONY: bin-viceroy
bin-viceroy:
	@arch=$$(uname -m); \
	echo $$arch; \
	os=$$(uname -s | tr '[:upper:]' '[:lower:]'); \
	echo $$os; \
	url=$$(curl -s https://api.github.com/repos/fastly/viceroy/releases/latest | jq --arg arch $$arch --arg os $$os -r '.assets[] | select((.name | contains($$arch)) and (.name | contains($$os))) | .browser_download_url'); \
	echo $$url; \
	filename=$$(basename $$url); \
	echo $$filename

.PHONY: all clean test
