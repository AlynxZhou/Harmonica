\version "2.22.1"

\header {
  title = "Fairytale"
  composer = "Kajiura Yuki"
  % opus = "Op. 9"
}

main = {
  \new Staff {
    \set Staff.midiInstrument = #"harmonica"
    \tempo 4=85
    \clef "treble"
    %\key c \major
    \numericTimeSignature
    \time 4/4
    dis''8 d''8 c''4 g''4 g''4 | f''8 dis''8 d''8 dis''8 d''8 ais'8 ais'4 |
    dis''8 d''8 c''4 \acciaccatura {f''8} g''4 f''8 dis''8 | d''8 ais'8 c''8~ c''8~ c''2 |
    dis''8 d''8 c''4 g''4 g''4 | f''8 dis''8 d''8 dis''8 d''8 ais'8 ais'4 |
    dis''8 d''8 c''4 d''8 dis''8 f''4 | d''8 ais'8 c''4~ c''2 |
    f''4 f''8~ f''4 e''8 e''4~ | e''2~ e''4 r4 |

    f''8 g''8 gis''4 ais''8 c'''8 g''4~ | g''8 g''8 f''4 g''8 gis''8 dis''4 |
    r8 dis''8 cis''4 dis''8 f''8 g''4 | gis''8( ais''8) ais''4 ais''8( c'''8) c'''4 |
    r8 ais''8 gis''4 g''8 f''8 dis''4 | r8 gis''8 cis'''4 c'''8 ais''8 gis''4 |
    ais''8 c'''8 ais''8 r8 f''8 r8 f''8 r8 | ais''4 gis''4. g''8 g''4~ | g''2 r2 |

    g''4 c'''8 r8 g''4 f''8 dis''8 | d''8 ais'8 c''8 c''8 \acciaccatura {f''8} g''4. r8 |
    g''4 c'''8 r8 g''4 f''8 dis''8 | d''8 ais'8 c''4~ c''4. r8 |
    g''4 c'''8 r8 g''4 f''8 dis''8 | d''8 ais'8 c''8 c''8 \acciaccatura {f''8} g''4. r8 |
    g''4 c'''8 r8 g''4 f''8 dis''8 | d''8 ais'8 c''4~ c''8 r8 d''4~ | d''8 c''8 c''2~ c''4 | r1 |

    dis'8( d'8) c'4 g'4 g'4 |
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
