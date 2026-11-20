-- m2-ls: disable E19
-- -*- coding: utf-8 -*-
newPackage(
	"Spectral",
	Version => "0.5.0",
	Date => "November 20, 2026",
	Headline => "drawing values as structured, typed trees",
	PackageImports => { "Complexes", "Varieties", "Text" },
	Authors => { {
		Name => "Alexander Golys",
		Email => "alexandergolys@gmail.com",
		HomePage => "https://eigenflux.dev"
	} },
	HomePage => "https://github.com/AlexanderGolys/Spectral",
	Keywords => { "Interfaces" },
	AuxiliaryFiles => true,
	DebuggingMode => false
)

-- The highlight groups a drawing is coloured with, those of the shell's that
-- code and its values can be; the shell colours nothing a drawing names
-- otherwise.
highlightGroups = {"Text", "Muted", "Canvas", "Keyword", "Operator", "Delimiter",
	"Punctuation", "Comment", "String", "Number", "Boolean", "Builtin", "Variable",
	"Type", "Function", "Macro", "Option", "Package", "MapArrow", "MarkupLink"}

export {
	"Rod",
	"rod",
	"rod'",
	"specType",
	"specType'",
	"speek",
	"speek'",
	"formatted",
	"drawsAs",
	"HLG",
	"UnderExpression",
	"OverExpression",
	"AlignedExpression",
	"DiagramExpression",
	"TreeExpression",
	"typeDepth",
	"valueDepth",
	"typeset",
	"typesetOperands",
	"typewriter",
	"highlightGroup",
	"keepNames"
}


-- The fields a drawing's meta may name: Class, the type it is drawn as; a
-- Highlight colouring it and its parts, reaching Reach levels below it; the
-- Target it links to; an atom's own Tex; the Type of the value it stands for;
-- whether an atom is Typeset; and, for a value drawn whole, its Fallback text,
-- its Code, a documentation page's Html, the TypeNames the page resolves and
-- the ExampleWidth its examples were archived at.
drawingFields = {Class, Highlight, Reach, Target, Tex, symbol Type, Typeset,
	Fallback, Code, Html, TypeNames, ExampleWidth}

-- HLG "Operator": a highlight group by its name, one of highlightGroups; any
-- other name is an error where the group is made.
HLG = new SelfInitializingType of BasicList

-- Spectral's own shapes, laid out as no class of Core's is.
-- UnderExpression{base, label}, OverExpression{base, label}: a label centred
-- beneath or above an expression, keeping the expression's baseline.
UnderExpression = new HeaderType of Expression
OverExpression = new HeaderType of Expression
-- AlignedExpression{{a, b, c}, …}: rows of cells, every cell but a row's last
-- in a column aligned across the rows, the last running on and wrapping beneath
-- where it started, as a table's values beside its keys.
AlignedExpression = new HeaderType of Expression
-- DiagramExpression{pieces, arrows}: pieces {{row, column}, piece} on a grid,
-- joined by arrows {from, to, label}, each end a {row, column} and the label
-- null when there is none; Straight => diagram gives the same diagram for a
-- layout in characters when this one runs arrows across columns.
DiagramExpression = new HeaderType of Expression
-- TreeExpression{{label, subtree}, …}: a hierarchy, each branch a label over
-- its subtree.
TreeExpression = new HeaderType of Expression

-- The shapes the shell draws, each an expression class a drawing is laid out
-- as: Holder{text} an atom, the texts of a row or a list side by side or
-- between their delimiters, a fraction, a subscript and a superscript, a matrix
-- with its rows' Degrees beside them, a bare table of cells, and Spectral's
-- own. An expression of a class derived from one is drawn as that one.
shapes = { Holder, RowExpression, Parenthesize, Divide, Subscript, Superscript,
	List, Array, Sequence, AngleBarList, VerticalList, MatrixExpression, Table,
	AlignedExpression, UnderExpression, OverExpression, DiagramExpression,
	TreeExpression }

-- A drawing, the format string a value is shown by: Rod{shape, meta}, an
-- expression of one of the shapes whose parts are drawings in turn, and what
-- it says of how it is drawn: Class, the type it is drawn as, which colours an
-- atom and decides what is typeset; a Highlight colouring it and its parts in
-- place of their own, reaching Reach levels below it (all when unset); a Target
-- it links to; an atom's own Tex. M2 prints it as the expression it is:
-- rod(1/2) is Rod{1/2, {Class => Divide}}, its parts Rod{Holder{"1"}, …}.
Rod = new HeaderType of Expression

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
-- formatted e: an expression drawn as its class lays it out, before it is
-- marked with that class: a shape as itself, its parts drawn in turn, and any
-- other class as shapes: a sum as a row of its terms between plus signs.
formatted = method(Dispatch => Thing, TypicalValue => Rod)

-- drawsAs(drawn, type): whether a drawing is laid out as `type` or a class
-- derived from it: drawsAs(rod(x + 1), Sum) is true.
drawsAs = method(TypicalValue => Boolean)
-- shapeOf e: the shape an expression is drawn as, the nearest of its class's
-- ancestors among the shapes; null for one that is none.
shapeOf = method(Dispatch => Thing)

-- The drawing's own machinery, used by the methods of every class.
-- field key: the field of a drawing's meta a key names, Spectral's own symbol
-- spelled as the key is.
field = method(Dispatch => Thing)
-- parts drawn extends Core's parts to drawings: the drawings a node is built
-- from, in the order they are read.
-- nested part: the drawings in a part of a shape, a drawing or lists of them.
nested = method(Dispatch => Thing, TypicalValue => List)
-- changedIn(part, change): a part of a shape with each drawing in it changed.
changedIn = method()
-- partsChanged(drawn, change): the drawing with each drawing in its shape
-- passed through change(position, part), `position` the index of the shape's
-- part it sits in.
partsChanged = method(TypicalValue => Rod)
-- transmitted drawn: the drawing as the shell is sent it, a table of its
-- shape's name, its Parts and its options, and what it says of how it is drawn,
-- every colour named by its highlight group.
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
-- arranged(e, straight): the DiagramExpression of a ComplexMapExpression e, its
-- target under its source by degree, or shifted under the components when
-- straight.
arranged = method(TypicalValue => DiagramExpression)

-- Settings: what a class says of how its values are drawn, each a method of the
-- class itself returning a constant, found up the class's ancestry as any
-- method is: install `highlightGroup Gene := class' -> HLG "Keyword"` to change one.
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
highlightGroup = method(Dispatch => Type, TypicalValue => HLG)

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
-- lined(lines, class): the lines one under another, each an atom of `class`, a
-- type.
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
