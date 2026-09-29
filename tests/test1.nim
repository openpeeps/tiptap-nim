import std/[unittest, tables, options, strutils]
import tiptap
import openparser/json

let sampleTiptapContent = """
{
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Hello, TipTap!"
        }
      ]
    }
  ]
}
"""

suite "parsing with openparser/json":
  test "basics":
    let tiptapEditor = initTipTap(content = sampleTiptapContent)
    check tiptapEditor.content.`type` == "doc"
    check tiptapEditor.content.content.len == 1
    check tiptapEditor.content.content[0].`type` == ttParagraph
    check tiptapEditor.content.validate()

  test "paragraph with text node fields":
    let doc = initTipTap(sampleTiptapContent).content
    let para = doc.content[0]
    check para.content.len == 1
    let textNode = para.content[0]
    check textNode.`type` == ttText
    check textNode.text == "Hello, TipTap!"

  test "heading with attrs":
    let raw = """{"type":"doc","content":[{"type":"heading","attrs":{"level":"1"},"content":[{"type":"text","text":"Hi"}]}]}"""
    let doc = initTipTap(raw).content
    check doc.content[0].`type` == ttHeading
    check doc.content[0].attrs["level"] == "1"
    check doc.content[0].content[0].text == "Hi"
    check doc.validate()

  test "text marks (bold, italic)":
    let raw = """{"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Hey","marks":[{"type":"bold"},{"type":"italic"}]}]}]}"""
    let doc = initTipTap(raw).content
    let textNode = doc.content[0].content[0]
    check textNode.marks.len == 2
    check textNode.marks[0].`type` == ttBold
    check textNode.marks[1].`type` == ttItalic
    check doc.validate()

  test "bullet list nesting":
    let raw = """{"type":"doc","content":[{"type":"bulletList","content":[{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"item"}]}]}]}]}"""
    let doc = initTipTap(raw).content
    check doc.content[0].`type` == ttBulletList
    check doc.content[0].content[0].`type` == ttListItem
    check doc.validate()

  test "image leaf node with attrs and no content":
    let raw = """{"type":"doc","content":[{"type":"image","attrs":{"src":"a.png","alt":"pic"}}]}"""
    let doc = initTipTap(raw).content
    check doc.content[0].`type` == ttImage
    check doc.content[0].attrs["src"] == "a.png"
    check doc.content[0].attrs["alt"] == "pic"
    check doc.validate()

  test "codeBlock and blockquote":
    let raw = """{"type":"doc","content":[{"type":"codeBlock","content":[{"type":"text","text":"let x = 1"}]},{"type":"blockquote","content":[{"type":"paragraph","content":[{"type":"text","text":"quote"}]}]}]}"""
    let doc = initTipTap(raw).content
    check doc.content[0].`type` == ttCodeBlock
    check doc.content[1].`type` == ttBlockquote
    check doc.validate()

suite "serialization round-trip":
  test "$ uses openparser toJson and parses back":
    let doc = initTipTap(sampleTiptapContent).content
    check doc.`type` == "doc"
    let s = $doc
    check s.len > 0
    check "paragraph" in s
    check "Hello, TipTap!" in s
    let doc2 = parseTipTapContent(s)
    check doc2.`type` == "doc"
    check doc2.content[0].`type` == ttParagraph
    check doc2.content[0].content[0].text == "Hello, TipTap!"
    check doc2.validate()

  test "toJson via openparser directly":
    let doc = initTipTap(sampleTiptapContent).content
    let s = toJson(doc)
    check "\"type\":\"doc\"" in s or "\"type\": \"doc\"" in s or "\"doc\"" in s

suite "builders and helpers":
  test "newTipTapNode + addChild + getFirstParagraph":
    var para = newTipTapNode(ttParagraph)
    para.content = @[]
    var textNode = newTipTapNode(ttText)
    textNode.text = "hi"
    para.addChild(textNode)
    check para.content.len == 1
    check para.content[0].text == "hi"
    let doc = TipTapContent(`type`: "doc", content: @[para])
    check doc.validate()
    let first = doc.getFirstParagraph()
    check first.isSome
    check first.get().`type` == ttParagraph

  test "getFirstParagraph returns none when absent":
    let doc = TipTapContent(`type`: "doc", content: @[newTipTapNode(ttImage)])
    check doc.getFirstParagraph().isNone

suite "validator":
  test "default schema rejects ttCustom node":
    var custom = newTipTapNode(ttCustom)
    custom.content = @[]
    let doc = TipTapContent(`type`: "doc", content: @[custom])
    check not doc.validate()

  test "custom whitelist accepts image only":
    let raw = """{"type":"doc","content":[{"type":"image","attrs":{"src":"a.png"}}]}"""
    let doc = initTipTap(raw).content
    check doc.validate(TipTapSchema(whitelist: {ttImage}))
    check not doc.validate(TipTapSchema(whitelist: {ttParagraph}))

  test "layoutRules enforce order":
    let raw = """{"type":"doc","content":[{"type":"heading","content":[{"type":"text","text":"t"}]},{"type":"paragraph","content":[{"type":"text","text":"b"}]}]}"""
    let doc = initTipTap(raw).content
    check doc.validate(TipTapSchema(layoutRules: @[ttHeading, ttParagraph]))
    check not doc.validate(TipTapSchema(layoutRules: @[ttParagraph, ttHeading]))

suite "errors":
  test "invalid JSON raises OpenParserJsonError":
    expect OpenParserJsonError:
      discard initTipTap("""{"type":"doc","content":[{broken}""")

  test "unknown node type raises OpenParserJsonError":
    expect ValueError:
      discard initTipTap("""{"type":"doc","content":[{"type":"nope"}]}""")
