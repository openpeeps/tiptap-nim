import unittest, tiptap

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

test "basics":
  let tiptapEditor = initTipTap(content = sampleTiptapContent)
  assert tiptapEditor.content.validate()