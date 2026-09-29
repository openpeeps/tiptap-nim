# TipTap - Schema Definition and Validator
# for TipTap Editor in Nim language
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/tiptap-nim

import std/[tables, options, strutils]
import openparser/json

type
  TipTapNodeType* = enum
    ## Enumeration of allowed node types in the TipTap editor. This includes basic
    ## text formatting nodes, structural nodes like paragraphs and headings, and
    ## media nodes like images. Custom node types can also be added as needed
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
    ttCode = "code",
    ttBlockquote = "blockquote",
    ttHighlight = "highlight"

  TipTapNode* {.acyclic.} = ref object
    ## Represents a node in the TipTap document structure.
    ## This can be a text node, paragraph, heading, etc.
    case `type`*: TipTapNodeType ## The type of the node, e.g., "paragraph", "text", etc.
    of ttText:
      text*: string
        ## The actual text content for text nodes
      marks*: seq[TipTapNode]
        ## Marks applied to the node, such as "bold", "italic", etc.
    else:
      content*: seq[TipTapNode]
        ## The content of the node, which can be a sequence of `TipTapNode`
    attrs*: Table[string, string]
      ## Attributes of the node, such as "bold", "italic", etc.

  TipTapContent* = object
    ## Represents the entire TipTap document structure
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

proc jsonValueToString*(n: JsonNode): string =
  ## Converts a JSON value to its string representation for `attrs` storage
  case n.kind
  of JString: result = n.getStr
  of JInt: result = $n.getInt
  of JFloat: result = $n.getFloat
  of JBool: result = $n.getBool
  of JNull: result = ""
  of JObject, JArray: result = toJson(n)

proc toTipTapAttrs*(n: JsonNode): Table[string, string] =
  ## Converts a JSON object into an attrs table. Non-string scalars
  ## are stringified so `{"level": 1}` becomes `{"level": "1"}`
  result = initTable[string, string]()
  if n == nil or n.kind != JObject:
    return
  for k, v in n.pairs:
    result[k] = jsonValueToString(v)

proc toTipTapNode*(n: JsonNode): TipTapNode =
  ## Converts a `JsonNode` into a `TipTapNode`. Raises `ValueError`
  ## for unknown node types (via `parseEnum`)
  let t = parseEnum[TipTapNodeType](n["type"].getStr)
  case t
  of ttText:
    result = TipTapNode(`type`: ttText)
    result.text =
      if n.hasKey("text"): n["text"].getStr("")
      else: ""
    result.marks = @[]
    if n.hasKey("marks") and n["marks"].kind == JArray:
      for m in n["marks"].elems:
        result.marks.add(toTipTapNode(m))
  else:
    result = TipTapNode(`type`: t)
    result.content = @[]
    if n.hasKey("content") and n["content"].kind == JArray:
      for c in n["content"].elems:
        result.content.add(toTipTapNode(c))
  result.attrs = initTable[string, string]()
  if n.hasKey("attrs") and n["attrs"].kind == JObject:
    result.attrs = toTipTapAttrs(n["attrs"])

proc toTipTapContent*(n: JsonNode): TipTapContent =
  ## Converts a `JsonNode` (parsed with `openparser/json`) into
  ## a `TipTapContent` document
  result.`type` = n["type"].getStr
  result.content = @[]
  if n.hasKey("content") and n["content"].kind == JArray:
    for c in n["content"].elems:
      result.content.add(toTipTapNode(c))

proc parseTipTapContent*(s: string): TipTapContent =
  ## Parses a TipTap JSON string into a `TipTapContent` document
  ## using `openparser/json` via a `JsonNode` intermediate.
  ##
  ## Note: we parse via `JsonNode` instead of `fromJson(s, TipTapContent)`
  ## because `openparser`'s compile-time fast path does not handle
  ## the backticked `type` field on non-variant objects.
  let n: JsonNode = fromJson(s)
  toTipTapContent(n)

proc `$`*(tt: TipTapContent): string =
  ## Converts the TipTap document to a JSON string
  ## representation using `openparser/json`
  toJson(tt)