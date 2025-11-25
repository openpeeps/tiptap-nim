# TipTap - Schema Definition and Validator
# for TipTap Editor in Nim language
#
# (c) 2025 George Lemon | LGPL License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/tiptap-nim

import pkg/jsony

import ./tiptap/[content, validator]
export content, validator

type
  TipTap* = object
    content*: TipTapContent

proc initTipTap*(content: sink string): TipTap =
  ## Initializes a new TipTap document
  TipTap(content: fromJson(content, TipTapContent))