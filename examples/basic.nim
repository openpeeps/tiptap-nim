import std/options
import tiptap

let raw = """{"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Hello, TipTap!"}]}]}"""

let editor = initTipTap(raw)
echo "doc type: ", editor.content.`type`
echo "valid: ", editor.content.validate()
echo "first paragraph text: ", editor.content.getFirstParagraph().get().content[0].text
echo "json: ", $editor.content
