# QR code generator for Commodore 64

## Features

* Written in assembly.
* Produces up to version 6 codes.
* All error correction levels.
* Uses only mask pattern 0 (checkerboard) for simplicity.
* Displays in text mode, using quadrant characters to show four modules
  per character cell.
* Translates PETSCII to UTF-8, according to the active charcter set.
  All printable characters of the built-in charsets supported.

## Dependencies

* [xa](https://www.floodgap.com/retrotech/xa/) cross-assembler
* `c1541` command from [VICE](https://vice-emu.sourceforge.io/), for
  creating the disk image

## Technical discussion

### Translation to UTF-8

First of all, an [Extended Channel
Interpretation](https://en.wikipedia.org/wiki/Extended_Channel_Interpretation)
(ECI) marker with the value $1a is placed at the start of the stream.
Although it might be possible to get away with not using it, it would
not technically be correct, since the default interpretation is
*supposed* to be
[ISO/IEC 8859-1](https://en.wikipedia.org/wiki/ISO/IEC_8859-1) (a.k.a.
Latin-1). Some writers will encode in UTF-8 without an indicator, and
some readers choose this interpretation if it appears appropriate. But
it may not be a good idea to rely on this.

There is also a side benefit to including this indicator: it results in
the payload being **byte-aligned**, whereas splitting bytes would be
necessary otherwise, so processing is slightly faster.

The resulting total overhead is only the 3 bytes of the ECI indicator,
the bytes mode indicator, and its size field. (Not 4. Although another
byte is used for the end-of-stream indicator and bit padding, it is
truncated or even completely omitted if we are already at the end of
the available space. So it doesn't count for the purpose of determining
the minimum version required.)

As for the payload itself, the program consults the VIC's memory setup
register ($D018) to determine the currently selected character set,
and translates accordingly. Thus, one may use Commodore+Shift before
entering a message, to affect what is encoded.

### ECC calculation

Most of the things that can be calculated from scratch are done so.
This includes the GF(256) generator polynomial, which differs according
to the ECC size, which in turn differs according to version and ECC
level. I could include hard-coded generators, but the generation is so
fast, it's barely noticeable. And the resulting program is smaller,
too.

Another thing the program creates from scratch are tables for exp() and
log() functions in GF(256). These are used to facilitate very fast
multiplication. Rather than multiplying the old-fashioned way, we use
the fact that *ab* = exp(log *a* + log *b*), when *a* and *b* are
non-zero, to turn it into addition. This is true in standard complex
(and non-negative real) numbers as well, but using it there would be
detrimental to both accuracy and performance. Not so in a finite field.
Here, there are only 255 possible distinct\* inputs and outputs of
these functions, and it is very easy and fast to populate lookup tables
with the needed values.

\* 1 and 255 are the same number here, under multiplication.

### Constructing the matrix

This program attempts to keep the matrix construction as simple as
possible, by doing it within one memory page. There is also an auxiliary
matrix of the same size to mark which modules have been filled by the
non-data patterns, which is consulted when filling in the data and ECC,
in order to navigate around those structures.

Using one bit per module, padding each row out to 6 bytes, and adding an
extra row (to simplify the display code, since it looks at two rows at a
time, and there are an odd number of them), this allows for up to
version 6 (41×41), with just a few bytes to spare. This way, calculating
the row offset requires just a couple of bit shifts and an add, indexed
modes can be used, and a simple bit mask can be used to address the
correct bit.

Version 7 would *technically* be possible in a page, but it would become
necessary to pack the bits in an awkward way, greatly complicating the
calculation. At that point, one may as well just use a multi-page setup.
It's slower either way. Plus, versions 7 and above get more
complicated, with an entire grid of alignment patterns (instead of the
single one in versions 2 through 6); and additional structures for
version information, which use a different error-correcting code (they
already used BCH for the format string and Reed-Solomon for the data;
for the new thing, they start using a Golay code). Plus, there is very
soon not enough space to display the code with the way I do it; I would
need to switch to bitmap mode. Given all that, I decided to stop at
version 6.

One last thing to note: the unused modules (above the lower-left finder)
are left alone, so they always end up white. I am not sure if this is
considered correct. It doesn't seem to cause issues for readers (and why
should it cause a major problem, really, given it's only a few modules,
and they fall outside the area covered by error correction?). However,
if necessary, it should be possible to fill it out in some way (but with
what, masked zeroes?).
