\version "2.18.2"
melody = \relative c'' {
	\clef "treble"
	\key d \major
	\time 4/4
	\tempo 4 = 130
	\partial 2
	\compressFullBarRests
	r8 cis d e fis g a d,~ d e a cis~ cis r4 d8~ d2
	r8 d, d d cis d r d d d cis d r d e d cis4 d8 a~ a d e d cis4 d8 a~ a2
	r8 d d d cis d r d d d cis d r d e d r d e d r d e d r d e d r d e fis~ fis4 r4 r2 R1*28

}

\score {
	\new Staff \melody
	\layout { }
	\midi { }
}
