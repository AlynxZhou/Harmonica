\version "2.18.2"
melody = \relative c'' {
	\clef "treble"
	\key a \major
	\time 4/4
	%{ \tempo 4 = 130 %}
	\partial 2
	\compressFullBarRests

}

\score {
	\new Staff \melody
	\layout { }
	\midi { }
}
