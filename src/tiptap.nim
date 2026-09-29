# TipTap - Schema Definition and Validator
# for TipTap Editor in Nim language
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/tiptap-nim

import ./tiptap/[content, validator]
export content, validator

type
  TipTap* = object
    content*: TipTapContent

proc initTipTap*(content: sink string): TipTap =
  ## Initializes a new TipTap document from a JSON string
  ## using `openparser/json` (via `parseTipTapContent`)
  TipTap(content: parseTipTapContent(content))
