STATICS_RELEASE=8c5676a2-fbc3-45e2-ae45-36dbe4ca8da7

statics:
	mkdir statics
	wget https://github.com/r58Playz/FNA-WASM-Build/releases/download/$(STATICS_RELEASE)/FAudio.a -O statics/FAudio.a
	wget https://github.com/r58Playz/FNA-WASM-Build/releases/download/$(STATICS_RELEASE)/FNA3D.a -O statics/FNA3D.a
	wget https://github.com/r58Playz/FNA-WASM-Build/releases/download/$(STATICS_RELEASE)/libmojoshader.a -O statics/libmojoshader.a
	wget https://github.com/r58Playz/FNA-WASM-Build/releases/download/$(STATICS_RELEASE)/SDL3.a -O statics/SDL3.a
	wget https://github.com/r58Playz/FNA-WASM-Build/releases/download/$(STATICS_RELEASE)/liba.o -O statics/liba.o
	wget https://github.com/r58Playz/FNA-WASM-Build/releases/download/$(STATICS_RELEASE)/dotnet.zip -O statics/dotnet.zip

clean:
	rm -rv statics obj bin public/_framework nuget || true

build: statics
	pnpm i
	rm -rv public/_framework bin/Release/net9.0/publish/wwwroot/_framework || true
#
	NUGET_PACKAGES="$(realpath .)/nuget" dotnet restore
	unzip -o statics/dotnet.zip -d nuget/microsoft.netcore.app.runtime.mono.multithread.browser-wasm/9.0.1/
	NUGET_PACKAGES="$(realpath .)/nuget" dotnet publish -c Release -v diag
#
	cp -rv bin/Release/net9.0/publish/wwwroot/_framework public/
	# microsoft messed up
	sed -i 's/FS_createPath("\/","usr\/share",!0,!0)/FS_createPath("\/usr","share",!0,!0)/' public/_framework/dotnet.runtime.*.js
	# sdl messed up
	sed -i 's/!window.matchMedia/!self.matchMedia/' public/_framework/dotnet.native.*.js
	# emscripten sucks
	sed -i 's/var offscreenCanvases={};/var offscreenCanvases={};if(globalThis.window\&\&!window.TRANSFERRED_CANVAS){transferredCanvasNames=[".canvas"];window.TRANSFERRED_CANVAS=true;}/' public/_framework/dotnet.native.*.js

serve: build
	pnpm dev

publish: build
	pnpm build
