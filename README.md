# Nymph Moog Ladder Filter

A Moog ladder multi-mode filter [LV2](https://lv2plug.in) plugin serving as an
example for the [nymph](https://github.com/SpotlightKid/nymph) library.

The filter has the following modes:

* 12 dB low-pass
* 24 dB low-pass
* 12 dB high-pass
* 24 dB high-pass
* 12 dB band-pass
* 24 dB band-pass

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

