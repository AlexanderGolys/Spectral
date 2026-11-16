-- m2-ls: disable E19
-- -*- coding: utf-8 -*-
newPackage(
	"Spectral",
	Version => "0.1",
	Date => "November 14, 2026",
	Headline => "drawing values as structured, typed trees",
	PackageImports => {"Complexes", "Varieties", "Text"},
	Authors => {{
		Name => "Alexander Golys",
		Email => "alexandergolys@gmail.com",
		HomePage => "https://github.com/AlexanderGolys"
	}},
	HomePage => "https://github.com/AlexanderGolys/Spectral",
	Keywords => {"Interfaces"},
	AuxiliaryFiles => true,
	DebuggingMode => false
)

export {
	"SpecNet",
	"specNet",
	"specType",
	"specType'",
	"speek",
	"speek'",
	"UnderExpression",
	"AlignedExpression",
	"typeDepth",
	"valueDepth",
	"typeset",
	"typesetOperands",
	"typewriter",
	"specNet'"
}

-- A drawing: the class that lays it out under Classes, its ordered Children,
-- and for an opaque leaf the Text that replaces them, plus optional annotations
-- (Type, Highlight, Tex, Target, Typeset, …); see Spectral/SpecNet.m2.
-- 1/2 is {Classes => Divide, Children => {<1>, <2>}}, each child a leaf ZZ.
SpecNet = new Type of HashTable

-- The public drawing, what the shell shows a value as. Install it for a class
-- to draw that class differently.
-- specNet x: x drawn from its expression, the classes of every part kept.
specNet = method(Dispatch => Thing, TypicalValue => SpecNet)
-- specNet'(depth, x): specNet x unfolding `depth` unnamed values deep, in
-- place of x's class's valueDepth.
specNet' = method(TypicalValue => SpecNet)
-- specType x: the type annotation shown beside x, as detailed as its class's
-- typeDepth: 1/2 is QQ, and R^2, a module of typeDepth 2, is Module[R].
specType = method(Dispatch => Thing, TypicalValue => SpecNet)
-- specType'(depth, x): specType x at an explicit depth. Also given a drawing,
-- it folds the drawing's parts to their classes, one level per depth.
specType' = method(TypicalValue => SpecNet)
-- speek x: the structure x is drawn as, two levels deep, read without the
-- shell: speek(1/2) is QQ => {ZZ => 1, ZZ => 2}.
speek = method(Dispatch => Thing)
-- speek'(depth, x): speek x to an explicit depth.
speek' = method()

-- The drawing's own machinery, used by the methods of every class.
-- opaque x: x as a leaf with no parts, spelled by its text (see spelling).
-- Used for values whose expression holds nothing but themselves.
opaque = method(Dispatch => Thing, TypicalValue => SpecNet)
-- spelling x: the text an opaque leaf of x shows, toString x by default.
spelling = method(Dispatch => Thing, TypicalValue => String)
-- valueClass drawn: the class a drawing stands for, its value's Type, or for a
-- part that is only part of an expression, its expression class.
valueClass = method()
-- contentsOf(container, items): a container drawn as `items`, each at the
-- container's own depth; a container already being drawn, which holds itself,
-- is drawn opaque rather than endlessly.
contentsOf = method(TypicalValue => SpecNet)
-- unfolding(x, shape): x drawn from its expression `shape`, its parameters
-- drawn as themselves at the next depth. An unnamed x with a placeholder costs
-- one level, and past the value depth is drawn as the placeholder alone.
unfolding = method(TypicalValue => SpecNet)
-- typesetMarked(drawn, forced): the drawing with every part marked whether it
-- is typeset maths, by the typeset, typesetOperands and typewriter settings;
-- `forced` when a typeset value holds the drawing.
typesetMarked = method(TypicalValue => SpecNet)
-- nearestSetting(field, type): the Boolean setting `field` (typeset, …) of the
-- nearest ancestor of `type` that sets it; false given anything but a type.
nearestSetting = method(TypicalValue => Boolean)
-- configuredDepth(depth, x): the integer setting `depth` (typeDepth or
-- valueDepth) of the nearest ancestor of x's class that sets it.
configuredDepth = method()

-- Hooks a class's block installs to say how its values are drawn.
-- placeholder x: the conventional name an unnamed x keeps past the value depth
-- (R for a ring, M for a module, …); null when x is always drawn whole.
placeholder = method(Dispatch => Thing)
-- parameters x: the values x is built over, which its expression spells in
-- place and a typedByParameters type lists: a module's is {its ring}.
parameters = method(Dispatch => Thing, TypicalValue => List)
-- spelledShape(x, shape): the expression x is drawn from, given its expression
-- `shape`: a module drops the `^1` M2 spells rank one with.
spelledShape = method()
-- optionKey key: the key before `=>`, coloured as an option's name when it is
-- spelled by a symbol or a string.
optionKey = method(Dispatch => Thing, TypicalValue => SpecNet)

-- Links: what a source position or a documentation page points to.
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
load "./Spectral/SpecNet.m2"
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
