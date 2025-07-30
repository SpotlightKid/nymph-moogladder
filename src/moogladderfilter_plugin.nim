## A Mood ladder 12/24 dB low-/hi-/bandpass filter

import nymph

import moogladder
import paramsmooth


const PluginUri = "https://chrisarndt.de/plugins/moogladderfilter"

type
    SampleBuffer = UncheckedArray[cfloat]

    FilterMode* = enum
        fmLoPass12,
        fmLoPass24,
        fmHiPass12,
        fmHiPass24,
        fmBandPass12,
        fmBandPass24

    PluginPort {.pure.} = enum
        Input_1,
        Output_1,
        Cutoff,
        Resonance,
        Mode

    MoogLadderFilterPlugin = object
        input_1: ptr SampleBuffer
        output_1: ptr SampleBuffer
        mode: ptr cfloat
        cutoff: ptr cfloat
        resonance: ptr cfloat
        flt: MoogLadder
        smoothCutoff: ParamSmooth


proc instantiate(descriptor: ptr Lv2Descriptor; sampleRate: cdouble;
                 bundlePath: cstring; features: ptr UncheckedArray[ptr Lv2Feature]):
                 Lv2Handle {.cdecl.} =
    try:
        let plug = createShared(MoogLadderFilterPlugin)
        plug.flt = initMoogLadder(sampleRate)
        plug.smoothCutoff = initParamSmooth(20.0, sampleRate)
        return cast[Lv2handle](plug)
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
    of PluginPort.Cutoff:
        plug.cutoff = cast[ptr cfloat](dataLocation)
    of PluginPort.Resonance:
        plug.resonance = cast[ptr cfloat](dataLocation)
    of PluginPort.Mode:
        plug.mode = cast[ptr cfloat](dataLocation)


proc activate(instance: Lv2Handle) {.cdecl.} =
    let plug = cast[ptr MoogLadderFilterPlugin](instance)
    plug.flt.setCoefficients(makeLoPass12())
    plug.flt.setCutoff(20_000.0)
    plug.flt.setResonance(0.0)


proc run(instance: Lv2Handle; nSamples: cuint) {.cdecl.} =
    let plug = cast[ptr MoogLadderFilterPlugin](instance)
    let cutoff = plug.cutoff[].clamp(16.0, 20_000.0)
    plug.flt.setResonance(plug.resonance[].clamp(0.0, 0.95))

    let coeffs = case plug.mode[].clamp(0.0, 5.0).FilterMode:
      of fmLoPass12:
        makeLoPass12()
      of fmLoPass24:
        makeLoPass24()
      of fmHiPass12:
        makeHiPass24()
      of fmHiPass24:
        makeHiPass24()
      of fmBandPass12:
        makeBandPass12()
      of fmBandPass24:
        makeBandPass24()

    plug.flt.setCoefficients(coeffs)

    for pos in 0 ..< nSamples:
        plug.flt.setCutoff(plug.smoothCutoff.process(cutoff))
        plug.output_1[pos] = plug.flt.process(plug.input_1[pos])


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
