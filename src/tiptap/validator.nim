# TipTap - Schema Definition and Validator
# for TipTap Editor in Nim language
#
# (c) 2025 George Lemon | LGPL License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/tiptap-nim

import std/[sets, json]
import pkg/jsony

import ./content

type
  TipTapSchema* = object
    whitelist*: set[TipTapNodeType] = {ttParagraph..ttBlockquote}
      ## A set of allowed node types in the TipTap content
    layoutRules*: seq[TipTapNodeType]
      ## A sequence defining allowed layout rules for nodes.
      ## 
      ## If empty, no layout rules are enforced, otherwise nodes must
      ## follow the specified order.
      ## 
      ## (e.g., [ttHeading, ttParagraph, ttImage])

const defaultTipTapSchema* = TipTapSchema()

proc validate*(content: TipTapContent,
      schema: TipTapSchema = defaultTipTapSchema): bool =
  ## Validates the TipTap content structure
  ## using the provided JSON schema. If no schema is provided,
  ## it uses the default schema.
  if schema.layoutRules.len > 0:
    for i, node in content.content:
      if not schema.whitelist.contains(node.`type`):
        return # node type not allowed
      if schema.layoutRules[i] != node.`type`:
        return # layout rule violated
  else:
    for node in content.content:
      if not schema.whitelist.contains(node.`type`):
        return # node type not allowed
  result = true