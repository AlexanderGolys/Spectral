-- m2-ls: disable E19
-- -*- coding: utf-8 -*-
newPackage(
	"Spectral",
	Version => "0.4.0",
	Date => "November 20, 2026",
	Headline => "drawing values as structured, typed trees",
	PackageImports => {"Complexes", "Varieties", "Text"},
	Authors => {{
		Name => "Alexander Golys",
		Email => "alexandergolys@gmail.com",
		HomePage => "https://eigenflux.dev"
	}},
	HomePage => "https://github.com/AlexanderGolys/Spectral",
	Keywords => {"Interfaces"},
	AuxiliaryFiles => true,
	DebuggingMode => false
)

export {
	"Rod",
	"rod",
	"rod'",
	"specType",
	"specType'",
	"speek",
	"speek'",
	"formatted",
	"atom",
	"row",
	"joined",
	"listed",
	"script",
	"fence",
	"parenthesized",
	"grid",
	"labelled",
	"drawsAs",
	"Highlight",
	"Reach",
	"Target",
	"Tex",
	"UnderExpression",
	"AlignedExpression",
	"typeDepth",
	"valueDepth",
	"typeset",
	"typesetOperands",
	"typewriter",
	"highlightGroup",
	"keepNames"
}

-- A drawing, the format string a value is shown by: the expression it lays out
-- as a tree of shaped nodes, as TeX lays out a formula, each part keeping how it
-- is drawn (its colour, whether it is typeset, its own TeX), in named fields
-- that serialise as they are; Spectral/Rod.m2 lists the shapes.
-- rod(1/2) is Rod{Shape => "Fraction", Numerator => rod 1, …}, printed as 1/2.
Rod = new Type of HashTable

-- The public drawing, what the shell shows a value as. Install rod for a
-- class to draw its values differently, or formatted for an expression class to
-- lay its expressions out differently.
-- rod x: x drawn from its expression, each part laid out by its class.
rod = method(Dispatch => Thing, TypicalValue => Rod)
-- rod'(depth, x): rod x unfolding `depth` levels of its notation, in place of
-- x's class's valueDepth.
rod' = method(TypicalValue => Rod)
-- specType x: the type annotation shown beside x, as detailed as its class's
-- typeDepth: 1/2 is QQ, and R^2, a module of typeDepth 2, is Module[R].
specType = method(Dispatch => Thing, TypicalValue => Rod)
-- specType'(depth, x): specType x at an explicit depth.
specType' = method(TypicalValue => Rod)
-- speek x: x inspected as peek inspects it, drawn: its class and what it holds,
-- each part drawn as itself. speek{1/2} reads List{1/2}, and speek of a ring
-- its class with the pairs of its table.
speek = method(Dispatch => Thing, TypicalValue => Rod)
-- speek'(depth, x): speek x unfolding `depth` levels of containers, as peek'.
speek' = method(TypicalValue => Rod)
-- formatted e: an expression laid out as its class lays it out, before it is
-- marked with that class.
formatted = method(Dispatch => Thing, TypicalValue => Rod)

-- The shapes a drawing is built from, one constructor each.
-- atom(text, class): text coloured as `class` is, a type or the name of a
-- colour such as "Operator": atom("+", "Operator").
atom = method(TypicalValue => Rod)
-- row items: the drawings set side by side.
row = method(TypicalValue => Rod)
-- joined(items, separator, class): the drawings with an atom of `separator`
-- between each two: joined({x, y}, ", ", "Delimiter") reads x, y.
joined = method(TypicalValue => Rod)
-- listed(items, left, right): the values drawn, joined by commas and fenced:
-- listed({1, 2}, "{", "}") reads {1, 2}.
listed = method(TypicalValue => Rod)
-- script(base, sub, sup): base with a subscript, a superscript or both, the
-- one absent null: script(x, 2, 2) reads x_2^2.
script = method(TypicalValue => Rod)
-- fraction(numerator, denominator) extends Core's fraction to drawings.
-- fence(left, right, body): the body between a pair of delimiters.
fence = method(TypicalValue => Rod)
-- parenthesized body: the body in parentheses.
parenthesized = method(TypicalValue => Rod)
-- grid(rows, align): rows of cells, a list of lists of drawings, aligned as
-- "Matrix", "Bare", "LeftAligned" or "Aligned" (see Spectral/Rod.m2).
grid = method(TypicalValue => Rod)
-- labelled(shape, base, label): the label "Over" or "Under" the base.
labelled = method(TypicalValue => Rod)
-- drawsAs(drawn, type): whether a drawing is laid out as `type` or a class
-- derived from it: drawsAs(rod(x + 1), Sum) is true.
drawsAs = method(TypicalValue => Boolean)

-- The drawing's own machinery, used by the methods of every class.
-- parts drawn extends Core's parts to drawings: the drawings a node is built
-- from, in the order they are read.
-- nested value: the drawings in a field's value, a drawing or lists of them.
nested = method(Dispatch => Thing, TypicalValue => List)
-- changedIn(value, change): a field's value with each drawing in it changed.
changedIn = method()
-- partsChanged(drawn, change): the drawing with each part passed through
-- change(field, part), `field` naming where the part sits.
partsChanged = method(TypicalValue => Rod)
-- transmitted drawn: the drawing as the shell is sent it, every atom and
-- highlight named by the highlight group it is coloured as.
-- transmitted(draw, x, fallback): draw x so, typeset where it should be, or
-- the fallback drawn opaque when drawing throws.
transmitted = method(TypicalValue => Rod)
-- tabulated table: the pairs of a hash table stacked between braces, keys,
-- arrows and values aligned; tabulated pairs does so for pairs already drawn.
tabulated = method(Dispatch => Thing, TypicalValue => Rod)
-- opaque x: x as an atom of its own class, spelled by its text (see spelling).
-- Used for values whose expression holds nothing but themselves.
opaque = method(Dispatch => Thing, TypicalValue => Rod)
-- spelling x: the text an opaque atom of x shows, toString x by default.
spelling = method(Dispatch => Thing, TypicalValue => String)
-- contentsOf(container, draw): a container drawn by the function `draw`, at the
-- container's own depth; a container already being drawn, which holds itself,
-- is drawn opaque rather than endlessly.
contentsOf = method(TypicalValue => Rod)
-- unfolding(x, shape): x drawn from its expression `shape`, its parameters
-- drawn as themselves; inside another drawing, x drawn by its name when it has
-- one (see keepNames).
-- drawnWithin(depth, x, draw): draw() run inside the drawing of x, unfolding
-- `depth` levels; a drawing inside none is the drawing of x, the one value
-- spelled out from its definition rather than by its name.
drawnWithin = method()
unfolding = method(TypicalValue => Rod)
-- typesetMarked(drawn, forced): the drawing with every atom marked whether it
-- is typeset maths, by the typeset, typesetOperands and typewriter settings;
-- `forced` when a typeset value holds the drawing.
typesetMarked = method(TypicalValue => Rod)
-- operand(part, loose): an operand drawn, parenthesized when it is laid out as
-- one of the classes in `loose`.
operand = method(TypicalValue => Rod)
-- stacked rows: rows of drawings one under another, left-aligned in braces, as
-- a vertical list and a hash table are drawn.
stacked = method(TypicalValue => Rod)
-- arranged(e, straight): the diagram of a ComplexMapExpression e, its target
-- under its source by degree, or shifted under the components when straight.
arranged = method(TypicalValue => Rod)

-- Settings: what a class says of how its values are drawn, each a method of the
-- class itself returning a constant, found up the class's ancestry as any
-- method is: install `highlightGroup Gene := class' -> "Keyword"` to change one.
-- typeDepth T: how many levels of a T's type its annotation shows.
typeDepth = method(Dispatch => Type, TypicalValue => ZZ)
-- valueDepth T: how many levels of its own notation a T unfolds: a complex
-- names its modules C_i and differentials d_i until it unfolds more than one.
valueDepth = method(Dispatch => Type, TypicalValue => ZZ)
-- typeset T: whether a T is set as typeset maths.
typeset = method(Dispatch => Type, TypicalValue => Boolean)
-- typesetOperands T: whether a T, an operator, sets its operands as maths.
typesetOperands = method(Dispatch => Type, TypicalValue => Boolean)
-- typewriter T: whether a T keeps a typewriter face even as an operand.
typewriter = method(Dispatch => Type, TypicalValue => Boolean)
-- typedByParameters T: whether a T's type lists the values it is built over
-- rather than the parts of its expression.
typedByParameters = method(Dispatch => Type, TypicalValue => Boolean)
-- highlightGroup T: the shell's highlight group a T is coloured as.
highlightGroup = method(Dispatch => Type, TypicalValue => String)

-- keepNames T: a T assigned to a global name is from then on drawn by that
-- name inside other values, as M2 spells a ring: after keepNames Ideal and
-- I = ideal(x^2), S/I is drawn as S/I, while J := ideal(x^2) leaves S/J
-- drawn as S/(x^2). A drawing of I itself still spells it out.
keepNames = method(TypicalValue => Nothing)
-- globalName x: the name a kept x was last assigned to, null when none.
globalName = method(Dispatch => Thing)

-- Hooks a class's block installs to say how its values are drawn.
-- definition x: the expression x stands for, spelled out though x has a name:
-- QQ[x] for R = QQ[x], whose expression is R. The value a drawing is of is
-- drawn from its definition, everything inside it from its expression.
definition = method(Dispatch => Thing)
-- optionsDropped e: the expression without the options its arrays list, each
-- a `=>` operation: QQ[x, Degrees => {1}] is QQ[x].
optionsDropped = method(Dispatch => Thing)
-- parameters x: the values x is built over, which its expression spells in
-- place and a typedByParameters type lists: a module's is {its ring}.
parameters = method(Dispatch => Thing, TypicalValue => List)
-- spelledShape(x, shape): the expression x is drawn from, given its expression
-- `shape`: a module drops the `^1` M2 spells rank one with.
spelledShape = method()
-- optionKey key: the key before `=>`, coloured as an option's name when it is
-- spelled by a symbol or a string.
optionKey = method(Dispatch => Thing, TypicalValue => Rod)

-- Links: what a source position or a documentation page points to.
-- named x: whether x is the value of the global name it spells: sin is, an
-- anonymous x -> x is not.
named = method(Dispatch => Thing, TypicalValue => Boolean)
-- sourceLines position: the lines of code at a source position, as code shows
-- them; null when they are nowhere to be read.
sourceLines = method(Dispatch => Thing)
-- lined(lines, class): the lines one under another, each an atom of `class`.
lined = method(TypicalValue => Rod)
-- sourceTarget position: the file:// URL of a FilePosition, its file found on
-- the load path; null when the file cannot be found.
sourceTarget = method(Dispatch => Thing)
-- foldedPath path: a path cut to its file and one directory above it:
-- "/a/b/c/file.m2" is "[...]/c/file.m2".
foldedPath = method()
-- documentationTags page: the nodes a documentation page links to, each TO,
-- TO2 and TOH target once.
documentationTags = method(Dispatch => Thing)
-- attributeText text: the text escaped to sit in a quoted HTML attribute.
attributeText = method()

-- How a value is drawn, class by class: each class's settings and methods stand
-- together in one block, in the file of its subject.
load "./Spectral/Rod.m2"
load "./Spectral/expressions.m2"
load "./Spectral/containers.m2"
load "./Spectral/language.m2"
load "./Spectral/algebra.m2"
load "./Spectral/complexes.m2"
load "./Spectral/varieties.m2"
load "./Spectral/hypertext.m2"

-- Drawing fields are keys, never values: their symbols stay unset.
scan(values currentPackage#"private dictionary", key ->
		if isMutable key and value key === key then
		protect key)

beginDocumentation()
load "./Spectral/documentation.m2"
end--
