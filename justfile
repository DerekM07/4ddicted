set dotenv-load

# default to steam default game dir
DEFAULT_GAME_DIR    := join("C:\\", "Program Files (x86)", "Steam", "steamapps", "common", "Cyberpunk 2077")
# default to CI RED cli path
DEFAULT_RED_CLI     := join(".", "redscript-cli.exe")
# default to local WolvenKit cli path
DEFAULT_WK_CLI      := join(".", "WolvenKit.CLI.exe")

mod_name            := 'Addicted'

# installation dir for Cyberpunk 2077, e.g. Steam
game_dir            := env_var_or_default("GAME_DIR", DEFAULT_GAME_DIR)
bundle_dir          := mod_name
alt_game_dir        := '../../../Program Files (x86)/Steam/steamapps/common/Cyberpunk 2077'

# codebase (outside of game files)
cet_repo_dir        := join("mods", mod_name)
red_repo_dir        := join("scripts", mod_name)
tweak_repo_dir      := join("tweaks", mod_name)
archive_repo_dir    := join("archive", "packed")
sounds_repo_dir     := join("archive", "source", "customSounds")
resources_repo_dir  := join("archive", "source", "resources")

# game files
cet_game_dir        := join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", mod_name)
red_game_dir        := join(game_dir, "r6", "scripts", mod_name)
tweak_game_dir      := join(game_dir, "r6", "tweaks", mod_name)
archive_game_dir    := join(game_dir, "archive", "pc", "mod")
redmod_game_dir     := join(game_dir, "mods", mod_name)
red_cache_dir       := join(game_dir, "r6", "cache")

# bundle files for release
cet_bundle_dir      := join(bundle_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", mod_name)
red_bundle_dir      := join(bundle_dir, "r6", "scripts", mod_name)
tweak_bundle_dir    := join(bundle_dir, "r6", "tweaks", mod_name)
archive_bundle_dir  := join(bundle_dir, "archive", "pc", "mod")
redmod_bundle_dir   := join(bundle_dir, "mods", mod_name)

latest_release      := env_var_or_default("LATEST_RELEASE", "")
latest_version      := env_var_or_default("LATEST_VERSION", "")
latest_artifact_windows := mod_name + '-windows-latest-{{latest_version}}.zip'
latest_artifact_linux   := mod_name + "-ubuntu-latest-{{latest_version}}.zip"

# path to REDscript CLI
red_cli             := env_var_or_default("RED_CLI", DEFAULT_RED_CLI)

# path to RED cache bundle file in game files
red_cache_bundle    := join(red_cache_dir, "final.redscripts")

# path to WolvenKit CLI
wk_cli              := env_var_or_default("WK_CLI", DEFAULT_WK_CLI)

red4ext_logs        := join(game_dir, "red4ext", "logs", "red4ext.log")
redscript_logs      := join(game_dir, "r6", "logs", "redscript_rCURRENT.log")
cet_logs            := join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log")
archivexl_logs      := join(game_dir, "red4ext", "plugins", "ArchiveXL", "ArchiveXL.log")
tweakxl_logs        := join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log")
mod_settings_logs   := join(game_dir, "red4ext", "logs", "mod_settings.log")
mod_logs            := join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log")

# list all commands
default:
  @just --list --unsorted
  @echo "⚠️ on Windows, paths defined in .env must be double-escaped:"
  @echo 'e.g. RED_CLI=C:\\\\somewhere\\\\on\\\\my\\\\computer\\\\redscript-cli.exe'

# 📁 run once to create mod folders (if not exist) in game files
setup:
    mkdir -p '{{cet_game_dir}}'
    mkdir -p '{{red_game_dir}}'

# 🎨 lint code
lint:
    '{{red_cli}}' lint -s 'scripts' -b '{{red_cache_bundle}}'

# 🔛 just compile to check (without building)
compile:
    '{{red_cli}}' compile -s 'scripts' -b '{{red_cache_bundle}}' -o "dump.redscripts"

# ➡️  copy codebase files to game files, including archive
build: rebuild
    cp -r '{{archive_repo_dir}}'/. '{{game_dir}}'
    mkdir -p '{{ join(redmod_game_dir, "customSounds") }}'
    @just copy_recursive '{{sounds_repo_dir}}' en-us wav '{{ join(redmod_game_dir, "customSounds") }}'
    @just copy_recursive '{{sounds_repo_dir}}' vanilla Wav '{{ join(redmod_game_dir, "customSounds") }}'
    cp '{{ join(resources_repo_dir, "info.json") }}' '{{ join(redmod_game_dir, "info.json") }}'

deploy:
    cd '{{ join(game_dir, "tools", "redmod", "bin") }}' && \
    ./redMod.exe deploy -root="{{game_dir}}"

# see WolvenKit archive Hot Reload (with Red Hot Tools)
# ↪️  copy codebase files to game files, excluding archive (when game is running)
rebuild:
    cp -r '{{cet_repo_dir}}'/. '{{cet_game_dir}}'
    cp -r '{{red_repo_dir}}'/. '{{red_game_dir}}'
    cp -r '{{tweak_repo_dir}}'/. '{{tweak_game_dir}}'

# 🧾 show logs from CET and RED
logs:
    @[ -f '{{red4ext_logs}}' ]       && cat '{{red4ext_logs}}'
    @[ -f '{{redscript_logs}}' ]     && cat '{{redscript_logs}}'
    @[ -f '{{cet_logs}}' ]           && cat '{{cet_logs}}'
    @[ -f '{{archivexl_logs}}' ]     && cat '{{archivexl_logs}}'
    @[ -f '{{tweakxl_logs}}' ]       && cat '{{tweakxl_logs}}'
    @[ -f '{{mod_settings_logs}}' ]  && cat '{{mod_settings_logs}}'
    @[ -f '{{mod_logs}}' ]           && cat '{{mod_logs}}'

# 🧹 clear current cache (r6/cache is not used, only r6/cache/modded matters)
clear:
    @if [[ -f "{{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}" ]]; then \
        echo "replacing {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }} with {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}"; \
        cp -f '{{ join(red_cache_dir, "modded", "final.redscripts.bk") }}' '{{ join(red_cache_dir, "modded", "final.redscripts") }}'; \
        rm -f '{{ join(red_cache_dir, "modded", "final.redscripts.bk") }}'; \
    else \
        echo "missing {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}"; \
    fi

# 💾 store (or overwrite) logs in latest.log
store:
    (just logs)  > 'latest.log'

alias forget := erase

# 🗑️🧾 clear out logs
erase: clear
    rm -f '{{ join(game_dir, "red4ext", "logs", "red4ext.log") }}' \
    '{{ join(game_dir, "red4ext", "logs", "mod_settings.log") }}' \
    '{{ join(game_dir, "red4ext", "plugins", "ArchiveXL", "ArchiveXL.log") }}' \
    '{{ join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log") }}' \
    '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}' \
    '{{ join(game_dir, "r6", "logs", "redscript_rCURRENT.log") }}' \
    '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}'

# check if given env vars exists
check-env NAME:
    [[ "{{ env_var_or_default(NAME, '') }}" != "" ]] || {{ error('please set env var: ' + NAME) }};

# 💠 direct install on Windows from repository (use `just --shell powershell.exe --shell-arg -c install`)
[windows]
install: (check-env 'LATEST_RELEASE') (check-env 'LATEST_VERSION')
    New-Item -ItemType Directory -Force -Path ".installation"
    C:\msys64\usr\bin\wget.exe "https://github.com/cyb3rpsych0s1s/4ddicted/releases/download/{{latest_release}}/{{latest_artifact_windows}}" -P ".installation"
    7z x '${{ join(".installation", latest_artifact_windows) }}' -o ".installation"
    rm -Force "${{latest_artifact_windows}}"
    Get-ChildItem -Path ".installation" | Copy-Item -Destination "${{game_dir}}" -Recurse -Container
    rm -r -Force ".installation"
    start "${{game_dir}}"

# 🐧 direct install on Linux from repository (use `just install`)
[linux]
install: (check-env 'LATEST_RELEASE') (check-env 'LATEST_VERSION')
    mkdir -p ".installation"
    wget "https://github.com/cyb3rpsych0s1s/4ddicted/releases/download/{{latest_release}}/{{latest_artifact_linux}}" -P ".installation"
    7z x '${{ join(".installation", latest_artifact_linux) }}' -o ".installation"
    rm -f '${{ join(".installation", latest_artifact_linux) }}'
    mv ".installation"/. "${{game_dir}}"
    rm -rf ".installation"
    open "${{game_dir}}"

#  Cyberpunk 2077 is not available on MacOS
[macos]
install:
    @echo '🚫 Cyberpunk 2077 is not available on MacOS'

# 📖 read book directly
read:
    mdbook build --open

# 🖊️  book with live hot reload
draft:
    mdbook watch --open

# 📕 assemble book (for release in CI)
assemble:
    mdbook build

# 📦 bundle mod files (for release in CI)
bundle:
    mkdir -p '{{archive_repo_dir}}'
    mv archive.archive '{{ join(archive_repo_dir, "Addicted.archive") }}'
    cp '{{ join("archive", "source", "resources", "Addicted.archive.xl") }}' '{{ join(archive_repo_dir, "Addicted.archive.xl") }}'

    mkdir -p '{{archive_bundle_dir}}'
    mkdir -p '{{cet_bundle_dir}}'
    mkdir -p '{{red_bundle_dir}}'
    mkdir -p '{{tweak_bundle_dir}}'
    mkdir -p '{{ join(redmod_bundle_dir, "customSounds") }}'
    cp -r '{{archive_repo_dir}}'/. '{{archive_bundle_dir}}'
    cp -r '{{cet_repo_dir}}'/. '{{cet_bundle_dir}}'
    cp -r '{{red_repo_dir}}'/. '{{red_bundle_dir}}'
    cp -r '{{tweak_repo_dir}}'/. '{{tweak_bundle_dir}}'
    @just bundle_lang

bundle_lang CODE='en-us' FILE='info.json':
    mkdir -p '{{ join(redmod_bundle_dir, "customSounds") }}'
    @just copy_recursive '{{sounds_repo_dir}}' {{CODE}} wav '{{ join(`pwd`, redmod_bundle_dir, "customSounds") }}' 'true'
    @just copy_recursive '{{sounds_repo_dir}}' vanilla/{{CODE}} Wav '{{ join(`pwd`, redmod_bundle_dir, "customSounds") }}' 'false'
    cp '{{ join(resources_repo_dir, FILE) }}' '{{ join(redmod_bundle_dir, "info.json") }}'

[private]
[windows]
copy_recursive IN SUB EXT OUT NESTED='false':
    cd '{{IN}}' && cp -r --parents {{SUB}}/**/*.{{EXT}} '{{OUT}}'

[private]
[linux]
copy_recursive IN SUB EXT OUT NESTED='false':
    rsync -R {{ join(IN, SUB, if NESTED == "false" { "" } else { "**" }, "*." + EXT) }} {{OUT}}

[private]
[macos]
copy_recursive IN SUB EXT OUT NESTED='false':
    cd '{{IN}}' && rsync -Rr {{ join(SUB, if NESTED == "false" { "" } else { "**" }, "*." + EXT) }} {{OUT}}

# 🗑️🎭⚙️ 🧧🗜️  clear out all mod files in game files
uninstall: uninstall-archive uninstall-cet uninstall-red uninstall-tweak uninstall-redmod

# 🗑️🎭  clear out mod archive files in game files
uninstall-archive:
    rm -f '{{archive_game_dir}}'/Addicted.archive
    rm -f '{{archive_game_dir}}'/Addicted.archive.xl

# 🗑️⚙️   clear out mod CET files in game files
uninstall-cet:
    rm -rf '{{cet_game_dir}}'

# 🗑️🧧  clear out mod REDscript files in game files
uninstall-red:
    rm -rf '{{red_game_dir}}'

# 🗑️🗜️   clear out mod tweaks files in game files
uninstall-tweak:
    rm -rf '{{tweak_game_dir}}'

# 🗑️⚙️   clear out mod REDmod files in game files
uninstall-redmod:
    rm -rf '{{redmod_game_dir}}'

alias nuke := nuclear

# 🧨 nuke your game files as a last resort (vanilla reset)
nuclear:
    rm -rf '{{ join(game_dir, "mods") }}'
    rm -rf '{{ join(game_dir, "plugins") }}'
    rm -rf '{{ join(game_dir, "engine") }}'
    rm -rf '{{ join(game_dir, "r6") }}'
    rm -rf '{{ join(game_dir, "red4ext") }}'
    rm -rf '{{ join(game_dir, "archive", "pc", "mod") }}'

# ↘️  extract audios (add .wem to WolvenKit project, then point to this directory and specify where to export)
extract IN OUT:
    mkdir -p '{{OUT}}'
    '{{wk_cli}}' export '{{IN}}' -o '{{OUT}}'

# encode .mp3 back into .wav
encode OVERWRITE='false':
  for file in `ls ./archive/source/customSounds`; do \
    if [[ ('{{OVERWRITE}}' != 'false' || ! -f ./archive/source/customSounds/${file%.mp3}.wav) && $file == *.mp3 ]]; then \
        ffmpeg -i ./archive/source/customSounds/$file -ar 44100 -sample_fmt s16 -y ./archive/source/customSounds/${file%.mp3}.wav; \
    fi \
  done

# analyze given file audio settings (please install ffprobe manually)
analyze FILE:
  ffprobe -i '{{FILE}}' -show_format -probesize 50000000 -analyzeduration 500
