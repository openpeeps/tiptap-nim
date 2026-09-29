import std/tables
import tiptap

var para = newTipTapNode(ttParagraph)
para.content = @[]
para.attrs = initTable[string, string]()

var textNode = newTipTapNode(ttText)
textNode.text = "Built programmatically"
textNode.marks = @[newTipTapNode(ttBold)]
textNode.attrs = initTable[string, string]()

para.addChild(textNode)

var image = newTipTapNode(ttImage)
image.content = @[]
image.attrs = initTable[string, string]()
image.attrs["src"] = "cover.png"
image.attrs["alt"] = "cover"

let doc = TipTapContent(`type`: "doc", content: @[para, image])
echo "valid: ", doc.validate()
echo "json: ", $doc

let reparsed = parseTipTapContent($doc)
echo "round-trip valid: ", reparsed.validate()
echo "round-trip blocks: ", reparsed.content.len
