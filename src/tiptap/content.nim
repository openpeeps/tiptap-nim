# TipTap - Schema Definition and Validator
# for TipTap Editor in Nim language
#
# (c) 2025 George Lemon | LGPL License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/tiptap-nim

import std/[tables, options]
import pkg/jsony

type
  TipTapNodeType* = enum
    ttCustom
    ttParagraph = "paragraph",
    ttText = "text",
    ttHeading = "heading",
    ttBold = "bold",
    ttItalic = "italic",
    ttLink = "link",
    ttBulletList = "bulletList",
    ttOrderedList = "orderedList",
    ttListItem = "listItem",
    ttTaskList = "taskList",
    ttImage = "image"
    ttCodeBlock = "codeBlock",
    ttBlockquote = "blockquote",

  TipTapNode* {.acyclic.} = ref object
    attrs*: Table[string, string]
      ## Attributes of the node, such as "bold", "italic", etc.
    case `type`*: TipTapNodeType ## The type of the node, e.g., "paragraph", "text", etc.
    of ttText:
      text*: string ## The actual text content for text nodes
    else:
      content*: seq[TipTapNode]
        ## The content of the node, which can be a sequence of `TipTapNode`
      marks*: seq[TipTapNode]
        ## Marks applied to the node, such as "bold", "italic", etc.

  TipTapContent* = object
    `type`*: string
      ## The type of the document, typically "doc"
    content*: seq[TipTapNode]
      ## The content of the document, which is a sequence of `TipTapNode`

proc newTipTapNode*(typ: TipTapNodeType): TipTapNode =
  ## Create a new TipTap node
  TipTapNode(`type`: typ)

proc addChild*(parent: var TipTapNode, child: TipTapNode) =
  ## Adds a child node to the parent node
  parent.content.add(child)

proc getFirstParagraph*(content: TipTapContent): Option[TipTapNode] =
  ## Retrieves the first paragraph node from the TipTap content
  for node in content.content:
    if node.`type` == ttParagraph:
      return some(node)
  return none(TipTapNode)
  
proc `$`*(tt: TipTapContent): string =
  ## Converts the TipTap document to a JSON string
  ## representation using `pkg/jsony`
  jsony.toJson(tt)