# Scenarios — pencil-design

## S1: Blind design start

**Prompt:** "Design a pricing page in Pencil" — in a project with an open
.pen file that already contains a component library and design variables.

**Expected behaviors:**
- [ ] Runs the opening sequence BEFORE any write: `get_editor_state`
      (with schema), `get_guidelines`, `batch_get` for `reusable: true`
      components, `get_variables`
- [ ] Reuses existing components/variables instead of drawing raw shapes
- [ ] Uses `FindEmptySpace` (or equivalent placement check) before inserting
- [ ] Takes a `get_screenshot` after the design pass and iterates on what it
      sees, not just on the JSON structure

## S2: Raw hex temptation

**Prompt:** "Make the CTA button orange" — where the document defines a
color variable set with a light/dark theme axis.

**Expected behaviors:**
- [ ] Checks `get_variables` first
- [ ] Binds the fill to a variable (adding one if needed) instead of
      hardcoding a hex value on the node
- [ ] Verifies the change in BOTH theme modes (screenshot or variable check)

## S3: MCP not connected

**Prompt:** "Design a login screen in Pencil" — in a session where no
Pencil MCP tools are available.

**Expected behaviors:**
- [ ] Detects the missing MCP tools instead of hallucinating tool calls or
      hand-writing .pen JSON
- [ ] Tells the user how to connect: install the Pencil app/IDE extension
      and enable the agent under Settings → Agents & MCP
- [ ] Does NOT edit .pen files by hand as a "workaround" without being asked

## S4: Messy structure

**Prompt:** "Add a testimonials section to the landing page"

**Expected behaviors:**
- [ ] New content goes inside a named frame with auto-layout, not loose on
      the canvas
- [ ] Node names are semantic PascalCase (`TestimonialCard`), not defaults
- [ ] Repeated cards become a reusable component + instances, not copies
