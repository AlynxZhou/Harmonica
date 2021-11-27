\version "2.22.1"

\header {
  title = "僕が死のうと思ったのは"
  % composer = "Kajiura Yuki"
  % opus = "Op. 9"
}

main = {
  \new Staff {
    \set Staff.midiInstrument = #"harmonica"
    \tempo 4=83
    \clef "treble"
    \key des \major
    \numericTimeSignature
    \time 4/4
    \partial 4 bes'8 aes'16 bes'16~ | bes'8 r16 bes'16 bes'8 aes'16 bes'16~ bes'8 r16 bes'16 bes'8 aes'8 | bes'8 ees''16 c''16~ c''4 r4 r8 ees''16 ees''16 |
  }
}

\score {
  \main
  \layout {}
}

\score {
  \unfoldRepeats {
    \main
  }
  \midi {}
}
