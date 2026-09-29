<p align="center">
  Tiptap Content Validator for 👑 in Nim language
</p>

<p align="center">
  <code>clue install tiptap</code>
</p>

<p align="center">
  <a href="https://openpeeps.github.io/tiptap-nim/">API reference</a><br>
  <img src="https://github.com/openpeeps/tiptap-nim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/tiptap-nim/workflows/docs/badge.svg" alt="Github Actions">
</p>

## 😍 Key Features
- Fast and lightweight validation of [Tiptap](https://github.com/ueberdosis/tiptap) JSON content
- JSON parsing and serialization with [`openparser/json`](https://github.com/openpeeps/openparser)
- Easy to use API

> [!NOTE]
> This library only validates Tiptap JSON content structure. It does not render or manipulate the content.

## Install

```sh
clue install tiptap
```

For local development:

```sh
clue develop
```

## Test

```sh
clue test
```

## Examples

Runnable examples live in [`examples/`](examples/). Build and run one with `clue`:

```sh
clue build examples/basic.nim --out:/tmp/tiptap_basic
/tmp/tiptap_basic
```

### Parse and validate (`examples/basic.nim`)

```nim
import std/options
import tiptap

let raw = """{"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Hello, TipTap!"}]}]}"""

let editor = initTipTap(raw)
echo "doc type: ", editor.content.`type`
echo "valid: ", editor.content.validate()
echo "first paragraph text: ", editor.content.getFirstParagraph().get().content[0].text
echo "json: ", $editor.content
```

Expected output:

```text
doc type: doc
valid: true
first paragraph text: Hello, TipTap!
json: {"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Hello, TipTap!","marks":[],"attrs":{}}],"attrs":{}}]}
```

### Custom schemas (`examples/schema.nim`)

```nim
import tiptap

let raw = """{"type":"doc","content":[{"type":"heading","attrs":{"level":"1"},"content":[{"type":"text","text":"Title"}]},{"type":"paragraph","content":[{"type":"text","text":"Body","marks":[{"type":"bold"}]}]}]}"""

let doc = parseTipTapContent(raw)
echo "valid with default schema: ", doc.validate()

let ordered = TipTapSchema(layoutRules: @[ttHeading, ttParagraph])
echo "valid heading+paragraph order: ", doc.validate(ordered)

let swapped = TipTapSchema(layoutRules: @[ttParagraph, ttHeading])
echo "valid swapped order (should be false): ", doc.validate(swapped)

let imagesOnly = TipTapSchema(whitelist: {ttImage})
echo "valid images-only (should be false): ", doc.validate(imagesOnly)
```

Run it:

```sh
clue build examples/schema.nim --out:/tmp/tiptap_schema
/tmp/tiptap_schema
```

### Build docs programmatically (`examples/build.nim`)

```nim
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
```

Run it:

```sh
clue build examples/build.nim --out:/tmp/tiptap_build
/tmp/tiptap_build
```

More usage examples are covered in [`tests/test1.nim`](tests/test1.nim).


### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeeps/tiptap-nim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeeps/tiptap-nim/fork)

### 🎩 License
MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps).<br>
Copyright OpenPeeps & Contributors &mdash; All rights reserved.
