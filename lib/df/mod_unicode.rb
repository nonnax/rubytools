#!/usr/bin/env ruby
# Id$ nonnax 2022-12-23 17:47:27

module Unicode
  # Chart characters
  # https://www.compart.com/en/unicode/category/So
  # https://www.vertex42.com/ExcelTips/unicode-symbols.html#block
  # https://gist.github.com/ivandrofly/0fe20773bd712b303f78
  BODY = "┃"
  BOTTOM = "╿"
  HALF_BODY_BOTTOM = "╻"
  HALF_BODY_TOP = "╹"
  FILL = "┃"
  TOP = "╽"
  VOID = " "
  WICK = "│"
  WICK_LOWER = "╵"
  WICK_UPPER = "╷"
  TEE_UP = "⊥"
  TEE_DOWN = "⊤"
  TICK_LEFT='╼'
  TICK_RIGHT='╾'
  MIN_DIFF_THRESHOLD = 0.25
  MAX_DIFF_THRESHOLD = 0.75
  DENSITY_SIGNS = ['#', '░', '▒', '▓', '█'].freeze
  SQUARE_SIGNS = ['🟨', '🟫','🟥' ].freeze
  SQUARE_WITH_FILL = %w[■ □ ▢ ▣ ▤ ▥ ▧ ▨ ▩].freeze
# ■  	U+25A0 (alt-09632)	BLACK SQUARE = moding mark (in ideographic text)
# □  	U+25A1 (alt-09633)	WHITE SQUARE = quadrature = alchemical symbol for salt
# ▢  	U+25A2 (alt-09634)	WHITE SQUARE WITH ROUNDED CORNERS
# ▣  	U+25A3 (alt-09635)	WHITE SQUARE CONTAINING BLACK SMALL SQUARE
# ▤  	U+25A4 (alt-09636)	SQUARE WITH HORIZONTAL FILL
# ▥  	U+25A5 (alt-09637)	SQUARE WITH VERTICAL FILL
# ▦  	U+25A6 (alt-09638)	SQUARE WITH ORTHOGONAL CROSSHATCH FILL
# ▧  	U+25A7 (alt-09639)	SQUARE WITH UPPER LEFT TO LOWER RIGHT FILL
# ▨  	U+25A8 (alt-09640)	SQUARE WITH UPPER RIGHT TO LOWER LEFT FILL
# ▩  	U+25A9 (alt-09641)	SQUARE WITH DIAGONAL CROSSHATCH FILL
  SQUARE_BLACK = '■'
  SQUARE_WHITE = '□'
  SQUARES = %w[□ ■]

  BLOCK_UPPER_HALF = '▀'   # ┼ ⊤  ⊥ ▀━▄ █ ▀ ▇ ▆
  BLOCK_LOWER_HALF = '▄'   # │╵┼╷─⊥⊤           ▀
  BLOCK_LOWER_Q3 = '▃'     # │     ⊤⊥
  BOX_HORIZ = '─'.freeze
  BOX_HORIZ_HEAVY = '━'
  BOX_HORIZ_VERT = '┼'
  BOX_VERT = WICK
  BLACK_SMALL_SQUARE='▪'
  WHITE_SMALL_SQUARE='▫'
  BLACK_RECTANGLE ='▬'  	#U+25AC (alt-09644)
  WHITE_RECTANGLE = '▭'  	#U+25AD (alt-09645)
  RECTANGLES = %w[▭ ▬]  	#U+25AD (alt-09645)
  WHITE_MEDIUM_SMALL_SQUARE='◽'  	#U+25FD (alt-09725)
  BLACK_MEDIUM_SMALL_SQUARE='◾'  	#U+25FE (alt-09726)
  WHITE_MEDIUM_SQUARE='◻'  	#U+25FB (alt-09723)	 = always (modal operator)
  BLACK_MEDIUM_SQUARE='◼'  	#U+25FC (alt-09724)
  BLACK_VERTICAL_RECTANGLE ='▮'  #	U+25AE (alt-09646)
  WHITE_VERTICAL_RECTANGLE= '▯'  #	U+25AF (alt-09647)
  VERTICAL_RECTANGLES = %w[▯ ▮]
  SQUARE_BRACKET_EXTENSIONS = %w[⎢ ⎥]  	#U+23A2 (alt-09122)
  TACKS = %w[⊢ ⊣]
  LOW_LINE = '_'
# ⊢  	U+22A2 (alt-08866)	RIGHT TACK = turnstile = proves, implies, yields = reducible
# ⊣  	U+22A3 (alt-08867)	LEFT TACK = reverse turnstile = non-theorem, does not yield
  # Code 	Result 	Description

  # U+2580 	▀ 	Upper half block

  # U+2581 	▁ 	Lower one eighth block   ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▀ ▔━▁

  # U+2582 	▂ 	Lower one quarter block

  # U+2583 	▃ 	Lower three eighths block

  # U+2584 	▄ 	Lower half block

  # U+2585 	▅ 	Lower five eighths block

  # U+2586 	▆ 	Lower three quarters block

  # U+2587 	▇ 	Lower seven eighths block

  # U+2588 	█ 	Full block

  # U+2589 	▉ 	Left seven eighths block

  # U+258A 	▊ 	Left three quarters block

  # U+258B 	▋ 	Left five eighths block

  # U+258C 	▌ 	Left half block

  # U+258D 	▍ 	Left three eighths block

  # U+258E 	▎ 	Left one quarter block

  # U+258F 	▏ 	Left one eighth block

  # U+2590 	▐ 	Right half block

  # U+2591 	░ 	Light shade

  # U+2592 	▒ 	Medium shade

  # U+2593 	▓ 	Dark shade

  # U+2594 	▔ 	Upper one eighth block

  # U+2595 	▕ 	Right one eighth block

  # U+2596 	▖ 	Quadrant lower left

  # U+2597 	▗ 	Quadrant lower right

  # U+2598 	▘ 	Quadrant upper left

  # U+2599 	▙ 	Quadrant upper left and lower left and lower right

  # U+259A 	▚ 	Quadrant upper left and lower right

  # U+259B 	▛ 	Quadrant upper left and upper right and lower left

  # U+259C 	▜ 	Quadrant upper left and upper right and lower right

  # U+259D 	▝ 	Quadrant upper right

  # U+259E 	▞ 	Quadrant upper right and lower left

  # U+259F 	▟ 	Quadrant upper right and lower left and lower right

end

#
# Block elements
# ▀
# U+2580
# ▁
# U+2581
# ▂
# U+2582
# ▃
# U+2583
# ▄
# U+2584
# ▅
# U+2585
# ▆
# U+2586
# ▇
# U+2587
# █
# U+2588
# ▉
# U+2589
# ▊
# U+258A
# ▋
# U+258B
# ▌
# U+258C
# ▍
# U+258D
# ▎
# U+258E
# ▏
# U+258F
# ▐
# U+2590
#
#
# Shade characters
# ░
# U+2591
# ▒
# U+2592
# ▓
# U+2593
#
#
# Block elements
# ▔
# U+2594
# ▕
# U+2595
#
#
# Terminal graphic characters
# ▖
# U+2596
# ▗
# U+2597
# ▘
# U+2598
# ▙
# U+2599
# ▚
# U+259A
# ▛
# U+259B
# ▜
# U+259C
# ▝
# U+259D
# ▞
# U+259E
# ▟
# U+259F
