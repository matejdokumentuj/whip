.PHONY: build install dmg clean run

build:
	@bash Scripts/build.sh

install: build
	@cp -r build/Whip.app /Applications/
	@echo "✅ Installed to /Applications/Whip.app"

run: build
	@open build/Whip.app

dmg: build
	@bash Scripts/create-dmg.sh

clean:
	@rm -rf build
	@echo "🧹 Cleaned"
