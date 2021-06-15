# grain128
Hardware implementation of the Grain_128AEAD stream cipher


## Status
Just started. Not completed. Does not work.
**Do. Not. Use.**


## Introduction
This is an implementation of the [Grain_128AEAD stream cipher](https://csrc.nist.gov/CSRC/media/Projects/Lightweight-Cryptography/documents/round-1/spec-doc/Grain_128AEAD-spec.pdf).

The Grain_128AEAD is a stream cipher that is one of the NIST lightweight
cipher finalists. The cipher is a continuation of the Grain and
Grain128a ciphers. The design makes for efficient implementation in
hardware and is quite different in comparison to other finalists.


## Implementation notes
The core has been developed using the [Grain_128AEAD C reference implementation](https://github.com/Noxet/Grain-128AEAD).


## Implementation results
