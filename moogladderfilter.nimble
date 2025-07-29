import std/os except commandLineParams
import std/strformat

# Package definition

version       = "0.1.0"
author        = "Christopher Arndt"
description   = "A Mood ladder 12/24 dB low-/hi-/bandpass filter"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0"
requires "https://github.com/SpotlightKid/nymph.git"

# Custom tasks

type Plugin = tuple
    name: string
    uri: string
    source: string
    bundle: string
    dll: string


const plugins = to_table({
    "moogladderfilter": "https://chrisarndt.de/plugins/moogladderfilter",
})


proc parseArgs(): tuple[options: seq[string], args: seq[string]] =
    ## Parse task specific command line arguments into option switches and positional arguments
    for arg in commandLineParams:
        if arg[0] == '-':    # -d:foo or --define:foo
            result.options.add(arg)
        else:
            result.args.add(arg)


proc getPlugin(task_name: string): Plugin =
    let (_, args) = parseArgs()

    if args.len == 0:
        quit(&"Usage: nimble {task_name} <plugin name>")

    result.name = changeFileExt(args[^1], "")

    let pluginsDir = thisDir() / "src"
    result.source = pluginsDir / result.name & "_plugin.nim"

    if not fileExists(result.source):
        quit(&"Plugin '{result.name}' not found.")

    result.uri = plugins.getOrDefault(result.name)

    if result.uri == "":
        quit(&"Plugin URI for plugin '{result.name}' not set.")

    result.bundle = pluginsDir / changeFileExt(result.name, "lv2")
    result.dll = result.bundle / toDll(result.name)


task build_plug, "Build given plugin":
    let ex = getPlugin("build_plug")

    switch("app", "lib")
    switch("noMain", "on")
    switch("mm", "arc")
    switch("out", ex.dll)

    when defined(gcc):
        switch("passC", "-fvisibility=hidden")

    when not defined(release) and not defined(debug):
        echo &"Compiling plugin {ex.name} in release mode."
        switch("define", "release")
        switch("opt", "speed")
        switch("define", "lto")
        switch("define", "strip")

    setCommand("compile", ex.source)


task lv2lint, "Run lv2lint check on given plugin":
    let plug = getPlugin("lv2lint")

    if fileExists(plug.dll):
        exec(&"lv2lint -s NimMain -s NimDestroyGlobals -I \"{plug.bundle}\" \"{plug.uri}\"")
    else:
        echo &"Plugin '{plug.name}' shared library not found. Use task 'build_plug' to build it."


task lv2bm, "Run lv2bm benchmark on given plugin":
    let plug = getPlugin("lv2bm")

    if plug.uri == "":
        echo &"Plugin URI for plugin '{plug.name}' not set."
        return

    if fileExists(plug.dll):
        let lv2_path = getEnv("LV2_PATH")
        let tempLv2Dir = thisDir() / ".lv2"
        let bundleLink = tempLv2Dir / changeFileExt(plug.name, "lv2")

        mkDir(tempLv2Dir)
        rmFile(bundleLink)
        exec(&"ln -s \"{plug.bundle}\" \"{bundleLink}\"")

        if lv2_path == "":
            putEnv("LV2_PATH", tempLv2Dir)
        else:
            putEnv("LV2_PATH", tempLv2Dir & ":" & lv2_path)

        exec(&"lv2bm --full-test -i white \"{plug.uri}\"")
    else:
        echo &"Plugin '{plug.name}' shared library not found. Use task 'build_plug' to build it."
