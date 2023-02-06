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
  SQUARE_BLACK = '■'
  SQUARE_WHITE = '□'         ╵
  BLOCK_UPPER_HALF = '▀'   # ┼ ⊤  ⊥ ▀─▄ █ ▀ ▇ ▆
  BLOCK_LOWER_HALF = '▄'   # │╵┼╷─⊥⊤           ▀
  BLOCK_LOWER_Q3 = '▃'     # │     ⊤⊥
  BOX_HORIZ = '─'.freeze
  BOX_HORIZ_HEAVY = '━'
  BOX_HORIZ_VERT = '┼'
  BOX_VERT = WICK
  BLACK_SMALL_SQUARE='▪'
  WHITE_SMALL_SQUARE='▫'
  BLACK_RECTANGLE= '▬'
  WHITE_RECTANGLE= '▭'
  WHITE_MEDIUM_SMALL_SQUARE='◽'  	#U+25FD (alt-09725)
  BLACK_MEDIUM_SMALL_SQUARE='◾'  	#U+25FE (alt-09726)
  WHITE_MEDIUM_SQUARE='◻'  	#U+25FB (alt-09723)	 = always (modal operator)
  BLACK_MEDIUM_SQUARE='◼'  	#U+25FC (alt-09724)
  # Code 	Result 	Description
  # U+2580 	▀ 	Upper half block
  # U+2581 	▁ 	Lower one eighth block   ▁ ▂
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
