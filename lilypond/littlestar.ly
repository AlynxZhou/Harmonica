\version "2.19.82"

\paper {
	print-all-headers = ##t
}

\score {
	\header {
		title = "音阶"
	}
	{
		\clef "treble"
		\time 7/8
		\autoBeamOff
		c8 d8 e8 f8 g8 a8 b8
		c'8 d'8 e'8 f'8 g'8 a'8 b'8
		c''8 d''8 e''8 f''8 g''8 a''8 b''8
		c'''8 d'''8 e'''8 f'''8 g'''8 a'''8 b'''8
		c''''8 d''''8
		\autoBeamOn
	}
}

\score {
	\header {
		title = "小星星"
	}
	{
		\clef "treble"
		\time 2/4
		c'8 c'8 g'8 g'8 a'8 a'8 g'4
		f'8 f'8 e'8 e'8 d'8 d'8 c'4
		g'8 g'8 f'8 f'8 e'8 e'8 d'4 \break
		g'8 g'8 f'8 f'8 e'8 e'8 d'4
		c'8 c'8 g'8 g'8 a'8 a'8 g'4
		f'8 f'8 e'8 e'8 d'8 d'8 c'4
	}
}

\score {
	\header {
		title = "送别"
	}
	{
		\clef "treble"
		\time 4/4
		g''4 e''8( g''8) c'''2	a''4 c'''8( a''8) g''2	g''4 c''8( d''8) e''4 d''8( c''8)	d''2. r4
		g''4 e''8( g''8) c'''4. b''8	a''4 c'''4 g''2	g''4 d''8( e''8) f''4. b'8	c''2. r4 \break
		a''4 c'''4 c'''2	b''4 a''8( b''8) c'''2	a''8( b''8) c'''8( a''8) a''8( g''8) e''8( c''8)	d''2. r4
		g''4 e''8( g''8) c'''4. b''8	a''4 c'''4 g''2	g''4 d''8( e''8) f''4. b'8	c''2. r4 \break
	}
	\addlyrics {
		长 亭 外 古 道 边 芳 草 碧 连 天
		晚 风 拂 柳 笛 声 残 夕 阳 山 外 山
		天 之 涯 地 之 角 知 交 半 零 落
		一 杯 浊 酒 尽 余 欢 今 宵 别 梦 寒
	}
}

\score {
	\header {
		title = "Jingle Bell"
	}
	{
		\clef "treble"
		\time 2/4
		\repeat volta 2 {
			e''8 e''8 e''4 e''8 e''8 e''4 e''8 g''8 c''8. d''16 e''2
			f''8 f''8 f''8. f''16 f''8 e''8 e''4 e''8 d''8 d''8 c''8 d''4 g''4 \break
			e''8 e''8 e''4 e''8 e''8 e''4 e''8 g''8 c''8. d''16 e''2
			f''8 f''8 f''8. f''16 f''8 e''8 e''4 g''8 g''8 f''8 d''8 c''2 \bar "||" \break
			g'8 e''8 d''8 c''8 g'2 g'8 e''8 d''8 c''8 a'2
			a'8 f''8 e''8 d''8 b'4. g'8 g''8 g''8 f''8 d''8 e''4 c''4 \break
			g'8 e''8 d''8 c''8 g'2 g'8 e''8 d''8 c''8 a'2
			a'8 f''8 e''8 d''8 g''8 g''8 g''4 a''8 g''8 f''8 d''8 c''2 \break
		}
	}
}
