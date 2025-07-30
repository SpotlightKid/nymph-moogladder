# Nymph Moog Ladder Filter

A Moog ladder multi-mode filter [LV2](https://lv2plug.in) plugin serving as an
example for the [nymph](https://github.com/SpotlightKid/nymph) library.

The filter has the following modes:

* 12 dB low-pass ([audio demo](https://0x20.eu/nc/s/WCmjQnAMNRp7xXa))
* 24 dB low-pass ([audio demo](https://0x20.eu/nc/s/tMWy9ije9cwyZ3T))
* 12 dB high-pass ([audio demo](https://0x20.eu/nc/s/pFEXw8EzLrNFPBd))
* 24 dB high-pass ([audio demo](https://0x20.eu/nc/s/kQrcEoGbWi9MoQc))
* 12 dB band-pass ([audio demo](https://0x20.eu/nc/s/fFJrkeeR3BRYj7x))
* 24 dB band-pass ([audio demo](https://0x20.eu/nc/s/tm5Yw6PiSff8rR9))

Audio demos: two detuned sawtooth waves from TAL NoiseMaker into the filter,
sweeping the cutoff frequency from 16 Hz to 10 kHz and back down, with
resonance set to 0.75 and some delay and reverb added after the filter.

## Installation

Build the plugin with [nimble](https://github.com/nim-lang/nimble):

```con
git clone https://github.com/SpotlightKid/nymph-moogladder.git
cd nymph-moogladder
nimble build_plug moogladderfilter
mkdir -p ~/.lv2/
cp -a src/moogladderfilter.lv2 ~/.lv2/
```

## Authors

- Christopher Arndt [@SpotlightKid](https://www.github.com/SpotlightKid)
- Mila Philipsen & Daan Schrier (original C++
  [filter implementation](https://github.com/DaanKS/OpenLadderFilter))


## License

This project is released under the [MIT](https://choosealicense.com/licenses/mit/) license.
Please see the [LICENSE](./LICENSE.md) file for details.

