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
