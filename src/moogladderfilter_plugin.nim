## A Mood ladder 12/24 dB low-/hi-/bandpass filter

import std/math
import nymph

const PluginUri = "https://chrisarndt.de/plugins/moogladderfilter"

type
    SampleBuffer = UncheckedArray[cfloat]

    PluginPort {.pure.} = enum
        Input_1,

        Output_1,

        Gain

    MoogLadderFilterPlugin = object
        input_1: ptr SampleBuffer

        output_1: ptr SampleBuffer

        gain: ptr cfloat


template db2coeff(db: cfloat): cfloat =
    pow(10.0, db / 20.0)


proc instantiate(descriptor: ptr Lv2Descriptor; sampleRate: cdouble;
                 bundlePath: cstring; features: ptr UncheckedArray[ptr Lv2Feature]):
                 Lv2Handle {.cdecl.} =
    try:
        return createShared(MoogLadderFilterPlugin)
    except OutOfMemDefect:
        return nil


proc connectPort(instance: Lv2Handle; port: cuint;
                 dataLocation: pointer) {.cdecl.} =
    let plug = cast[ptr MoogLadderFilterPlugin](instance)
    case cast[PluginPort](port)
    of PluginPort.Input_1:
        plug.input_1 = cast[ptr SampleBuffer](dataLocation)

    of PluginPort.Output_1:
        plug.output_1 = cast[ptr SampleBuffer](dataLocation)

    of PluginPort.Gain:
        plug.gain = cast[ptr cfloat](dataLocation)


proc activate(instance: Lv2Handle) {.cdecl.} =
    discard


proc run(instance: Lv2Handle; nSamples: cuint) {.cdecl.} =
    let plug = cast[ptr MoogLadderFilterPlugin](instance)
    for pos in 0 ..< nSamples:
        plug.output_1[pos] = plug.input_1[pos] * db2coeff(plug.gain[])


proc deactivate(instance: Lv2Handle) {.cdecl.} =
    discard


proc cleanup(instance: Lv2Handle) {.cdecl.} =
    freeShared(cast[ptr MoogLadderFilterPlugin](instance))


proc extensionData(uri: cstring): pointer {.cdecl.} =
    return nil


proc NimMain() {.cdecl, importc.}


proc lv2Descriptor(index: cuint): ptr Lv2Descriptor {.
                   cdecl, exportc, dynlib, extern: "lv2_descriptor".} =
    NimMain()

    if index == 0:
        result = createShared(Lv2Descriptor)
        result.uri = cstring(PluginUri)
        result.instantiate = instantiate
        result.connectPort = connectPort
        result.activate = activate
        result.run = run
        result.deactivate = deactivate
        result.cleanup = cleanup
        result.extensionData = extensionData
