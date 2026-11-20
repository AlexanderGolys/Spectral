-- m2-ls: disable E19
-- -*- coding: utf-8 -*-
newPackage(
	"Spectral",
	Version => "0.8.0",
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

export {
	"Rod",
	"rod",
	"rod'",
	"specType",
	"specType'",
	"speek",
	"speek'",
	"typeParameters",
	"HLG",
	"UnderExpression",
	"OverExpression",
	"AlignedExpression",
	"DiagramExpression",
	"TreeExpression",
	"Shape",
	"Class",
	"Group",
	"Highlight",
	"Reach",
	"Target",
	"Font",
	"Parameters",
	"Html",
	"TypeNames",
	"ExampleWidth",
	"Straight"
}

-- The highlight groups a drawing is coloured with, those of the shell's that
-- code and its values can be; the shell colours nothing a drawing names
-- otherwise.
highlightGroups = {"Text", "Muted", "Canvas", "Keyword", "Operator", "Delimiter",
	"Punctuation", "Comment", "String", "Number", "Boolean", "Builtin", "Variable",
	"Type", "Function", "Macro", "Option", "Package", "MapArrow", "MarkupLink"}
-- HLG "Operator": a highlight group by its name, one of highlightGroups; any
-- other name is an error where the group is made.
HLG = new SelfInitializingType of BasicList

-- The fonts an atom is set in, each by the TeX command setting it: TeX's maths
-- alphabets, set as maths, and its text faces, set as text beside it; TeX's own
-- maths, italic letters and upright digits, has none. An atom of a drawing that
-- names none is code, typewritten.
fonts = hashTable {
	"mathbb" => "MathBB",
	"mathfrak" => "MathFrak",
	"mathcal" =>
		"MathCal",
	"mathbf" => "MathBf",
	"mathit" => "MathIt",
	"mathrm" => "MathRm",
	"texttt" => "TextTT",
	"text" => "TextNormal",
	"textbf" => "TextBf",
	"textit" =>
		"TextIt"
}
-- The alphabets M2's names spell each letter of twice: QQ, OO.
doubledFonts = {fonts#"mathbb", fonts#"mathcal"}
mathsFont = Font => "MathNormal"
codeFont = Font => fonts#"texttt"

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

-- The classes whose values a global name holding them stands for inside other
-- drawings, as M2 spells a ring by its name: after I = ideal(x^2), S/I is
-- drawn as S/I, while J := ideal(x^2) leaves S/J drawn as S/(x^2).
namedClasses = { Ring, Ideal, Module, Matrix, RingMap, Variety, CoherentSheaf,
	SheafMap, Complex, ComplexMap }

-- A drawing, the format string a value is shown by: a table of its fields,
-- read as x.Shape, x.Highlight, …: the Shape it lays out, an expression of one
-- of the shapes whose parts are drawings in turn; the Class it is laid out as;
-- an atom's own colour Group; a Highlight colouring it and its parts in place
-- of their own, reaching Reach levels below it, all when unset; the Target it
-- links to; the Font its atoms are set in unless they say otherwise; the
-- Parameters of a value drawn from its expression, the values it is built
-- over; and, for a documentation page, its Html, the TypeNames it resolves and
-- the ExampleWidth its examples were archived at. M2 prints it as
-- the expression it is: rod(1/2) is Rod{Divide{…}, Class => Divide}, printing
-- as 1/2.
Rod = new SelfInitializingType of HashTable
-- f x and f_n x: a function of one value, any value, a sequence too, and the
-- same function n levels deep: rod'_1 x is x drawn with its names resolved
-- once. atDepth#f is the function of (n, x) that f_n x calls.
DepthFunction = new Type of FunctionClosure
atDepth = new MutableHashTable
DepthFunction_ZZ := FunctionClosure => (f, depth) -> x -> atDepth#f(depth, x)
deepened = (shallow, deep) -> (
	f := new DepthFunction from shallow;
	atDepth#f = deep;
	f
)

-- rod x: x drawn by its value, any value a global name holds inside it drawn
-- by that name. Install rod for a class to draw its values, returning a Rod.
rod = method(Dispatch => Thing, TypicalValue => Rod)
-- specType x: the type annotation shown beside x, its class over its
-- typeParameters by their names: 1/2 is QQ, and R^2 is Module[R].
specType = method(Dispatch => Thing, TypicalValue => Rod)
-- typeParameters x: the values x's type is over, none for most: a module's
-- ring.
typeParameters = method(Dispatch => Thing, TypicalValue => List)
-- speek x: the drawing of x laid out as the table it is, one level deep.
speek = method(Dispatch => Thing, TypicalValue => Rod)
-- rod' x, the drawing of a part, by its name when it has one, rod'_n x,
-- specType'_n x and speek'_n x are DepthFunctions, made where they are drawn.

-- How a value is drawn, class by class, in the file of its subject.
load "./Spectral/Rod.m2"
load "./Spectral/expressions.m2"
load "./Spectral/containers.m2"
load "./Spectral/language.m2"
load "./Spectral/algebra.m2"
load "./Spectral/complexes.m2"
load "./Spectral/varieties.m2"
load "./Spectral/hypertext.m2"

beginDocumentation()
doc ///
Node
  Key
    Spectral
  Headline
    structured value and type formatting
  Description
    Text
      @TO rod@ draws a value by its value, each part laid out in one of the
      @TO "shapes"@ the shell draws and coloured by one of its highlight
      groups, an @TO HLG@; inside it, a ring, an ideal, a module and the like
      that a global name holds is drawn by that name. @TO specType@ lays out
      the type of a value the same way. Both are what the
      @HREF{"https://github.com/AlexanderGolys/spectral-m2", "spectral-m2"}@
      shell draws its results from, and work on their own: a @TO Rod@ prints as
      the text it lays out. @TO speek@ shows the drawing itself, the table of
      fields it is.
    Example
      R = QQ[x, y];
      rod((x + 1)/2)
      I = ideal(x^2, y);
      rod(R/I)
      speek(1/2)
  Subnodes
    Rod
    rod
    shapes
    HLG
    "drawing fields"
    specType
    speek
Node
  Key
    AlignedExpression
  Headline
    rows aligned in columns, each ending in a cell that runs on
  Usage
    AlignedExpression{{a, b, c}, {d, e, f}}
  Description
    Text
      Every cell but a row's last sits in a column aligned across the rows.
      The last cell takes the rest of the width: when it is too long it wraps,
      continuing beneath where it started rather than at the left margin.
      A hash table draws its pairs this way, each key and its arrow in aligned
      columns; install @TO rod@ for a type to draw it the same way.
    Example
      rod AlignedExpression{{"x", symbol =>, 1}, {"longer", symbol =>, {1, 2, 3}}}
Node
  Key
    UnderExpression
  Headline
    center a label beneath an expression
  Usage
    UnderExpression{base, label}
  Description
    Text
      Keeps the baseline of the base while placing the label below it.
      A complex sets each module over its degree this way, and a map's label
      sits over its arrow as an @TO OverExpression@.
Node
  Key
    Rod
  Headline
    an expression with how it is drawn
  Usage
    Rod{shape}
    Rod{shape, Highlight => HLG "Keyword", …}
    x.Shape
  Description
    Text
      A Rod is the format string a value is shown by: a table of fields, its
      Shape an expression in one of the @TO "shapes"@ whose parts are Rods in
      turn, the others saying how it is drawn, as listed under
      @TO "drawing fields"@ and read as x.Shape, x.Class, …. An atom is a
      Holder of its text, coloured by its Group or a Highlight over it. A
      field given as null is not set, so one may be given only when it
      applies. A Rod prints as the text it lays out;
      the shell is sent the tree, never the value.
    Example
      R = QQ[x, y];
      Rod {Divide {rod x, Rod {Holder {"n"}, Highlight => HLG "Keyword"}}}
      half = rod(1/2);
      half.Shape
      half.Class
Node
  Key
    rod
    rod'
  Headline
    draw a value as a tree of shapes
  Usage
    rod x
    rod' x
    rod'_n x
  Description
    Text
      rod x is x drawn by its value, laid out by the rod installed for its
      class. Inside the drawing, a value of one of the classes M2 spells by
      name (a ring, an ideal, a module, a matrix, a map of rings, a variety, a
      coherent sheaf, a map of sheaves, a complex or a map of complexes) is
      drawn by the global name holding it, the first in alphabetical order
      when several do; rod'_n x draws x with those names resolved to their
      values n times over, so rod'_1(R/I) spells I out. The value the drawing
      is of is always drawn by its value. rod' x draws x as a part of the
      drawing in progress, by its name when it has one, and never fails on
      Spectral's own account: a class with no rod is spelled as M2 spells it,
      and a value holding itself is drawn once.
    Text
      Install rod for a class to draw its values, returning a @TO Rod@ whose
      parts are drawn with rod', which draws a part of the drawing in progress,
      by its name when it has one. A value laid out from an expression instead
      gives the expression as its Shape and the values it is built over as its
      Parameters; each part of the expression is then drawn in turn, and each
      parameter a name holds is drawn by that name.
    Example
      R = QQ[x, y];
      I = ideal(x^2, y^3);
      rod(R/I)
      rod'_1(R/I)
      Pair = new Type of BasicList;
      rod Pair := pair -> Rod {RowExpression {rod' pair#0, Rod {Holder {" & "}, Highlight => HLG "Operator"}, rod' pair#1}};
      rod {new Pair from {I, x}}
Node
  Key
    HLG
  Headline
    the shell's colours a drawing can name
  Description
    Text
      HLG "name" is a highlight group of the shell's by its name, one of those
      code and its values are coloured with, and any other name an error:
      Text, Muted, Canvas, Keyword, Operator, Delimiter, Punctuation, Comment,
      String, Number, Boolean, Builtin, Variable, Type, Function, Macro, Option,
      Package, MapArrow and MarkupLink. The Group and Highlight among a
      drawing's @TO "drawing fields"@ name one of them.
    Example
      HLG "Operator"
      Rod {Holder {"+"}, Highlight => HLG "Operator"}
Node
  Key
    specType
    (specType, Thing)
    specType'
    typeParameters
    (typeParameters, Thing)
  Headline
    the type of a value, drawn
  Usage
    specType x
    specType'_n x
    typeParameters x
  Description
    Text
      specType x is the class of x over its typeParameters, the values its
      type is over, by their names: an ideal and a module over their ring, a
      matrix and a map of sheaves from source to target, a coherent sheaf over
      its ring, a sheaf of rings over its variety, a complex over its ring;
      most values' type is over none. specType'_n x resolves those names n
      times. Install typeParameters for a class as a method returning a list,
      as typeParameters Module := M -> {ring M} is.
    Example
      R = QQ[x, y];
      specType(1/2)
      specType(R^2)
      specType'_1(R^2)
      specType x
Node
  Key
    speek
    (speek, Thing)
    speek'
  Headline
    show the drawing of a value, the table it is
  Usage
    speek x
    speek'_n x
  Description
    Text
      The drawing of x laid out as the table of fields it is: Rod over its
      fields, its Shape the class of the expression over the expression's
      parts. The parts are drawings too, nested as deep as the value is, so
      speek shows them as the text they print as, and speek'_n x opens n
      levels of them.
    Example
      speek(1/2)
      speek'_2(1/2)
Node
  Key
    "shapes"
    OverExpression
    DiagramExpression
    TreeExpression
    Straight
  Headline
    the expression classes the shell draws
  Description
    Text
      A @TO Rod@ is an expression of one of these classes, its parts Rods:
      Holder{text}, an atom; RowExpression, its items side by side;
      Parenthesize; Divide, a fraction; Subscript and Superscript; List, Array,
      Sequence and AngleBarList, their items between their delimiters, and
      VerticalList, one under another; MatrixExpression, its rows in
      parentheses, its Degrees beside them; Table, a bare grid of cells; and
      Spectral's own @TO AlignedExpression@, @TO UnderExpression@,
      OverExpression{base, label}, DiagramExpression{pieces, arrows}, pieces
      {{row, column}, piece} joined by arrows {from, to, label} with a
      Straight diagram for a layout in characters, and
      TreeExpression{{label, subtree}, ...}. An expression of a class derived
      from one is drawn as that one. A drawing's Class is the expression class
      it was laid out from: a sum and a product are both rows, told apart by
      their Class.
    Example
      R = QQ[x, y];
      Rod {Superscript {rod x, rod 2}}
      (rod(x + 1)).Class
Node
  Key
    "drawing fields"
    Shape
    Class
    Group
    Highlight
    Reach
    Target
    Font
    Parameters
    Html
    TypeNames
    ExampleWidth
  Headline
    what a Rod may carry
  Description
    Text
      Shape is the expression a drawing lays out, and Class the class it is
      laid out as. Group is the @TO HLG@ an atom is coloured as; Highlight an
      HLG the node and its parts are coloured as in place of their own, and
      Reach, when set, how many levels below the node it reaches, 0 for the
      node alone. Target is a link the value opens. Font is the font the
      node's atoms are set in, by its name: "MathNormal" for TeX's own maths,
      a maths alphabet such as "MathBB", where Q is ℚ, and "MathCal", or a
      text face such as "TextTT", the typewriter face code is spelled in; a
      node naming none is set as the node holding it is, and code when none
      does. Parameters are the values a value drawn from its expression is
      built over (see @TO rod@ and @TO specType@). A documentation page
      carries its Html, the TypeNames it resolves and the ExampleWidth its
      examples were archived at.
    Example
      R = QQ[x, y];
      speek(rod ideal(x, y) ++ {Highlight => HLG "Keyword", Reach => 1})
///

-- Worked examples of what Spectral draws, each checked.

TEST ///
-- A Rod is a table of how it is drawn, its Shape an expression whose parts are
-- Rods, every field read by its name.
R = QQ[x, y]
half = rod(1/2)
assert instance(half, Rod)
assert instance(half.Shape, Divide)
assert all(toList half.Shape, part -> instance(part, Rod))
assert(half.Class === Divide)
assert(toString half == "1/2")
assert((rod(x + 1)).Class === Sum)
-- Built by hand, a drawing is the expression it lays out.
assert(toString Rod {RowExpression {rod x, Rod {Holder {" (+) "}, Highlight => HLG "Operator"}, rod y}} == "x (+) y")
///

TEST ///
-- A colour is one of the shell's highlight groups: a made-up one is an error
-- where it is written.
assert(HLG "Operator" === HLG "Operator")
assert(try (HLG "Operatr"; false) else true)
-- A field given as null is not set.
assert(not (Rod {Holder {"+"}, Group => null})#?Group)
///

TEST ///
-- A value is drawn by its value, any named value inside it by its name, and
-- rod'_n resolves those names n times; a value assigned with :=
-- has no global name.
R = QQ[x, y]
I = ideal(x^2, y^3)
assert(toString rod(R/I) == "R/I")
assert match("ideal", toString rod I)
assert(toString rod {I} == "{I}")
assert match("ideal", toString rod'_1 {I})
J := ideal(x^2)
assert(toString rod(R/J) != "R/J")
///

TEST ///
-- A complex is drawn as its modules and differentials, none of which has a
-- name of its own, inside it by its name.
R = QQ[x, y]
C = freeResolution coker vars R
assert match("R", toString net rod C)
assert(toString rod {C} == "{C}")
///

TEST ///
-- specType x is x's class, over the values its type is over by their names,
-- given by typeParameters; specType'_n x resolves them n times.
R = QQ[x, y]
assert(toString specType(1/2) == "QQ")
assert(toString specType {1} == "List")
assert(toString specType(R^2) == "Module[R]")
assert match("QQ", toString specType'_1(R^2))
///

TEST ///
-- A class without a rod is spelled as M2 spells it, and a value holding itself
-- is drawn once.
Gene = new Type of BasicList
assert(toString rod'(new Gene from {1}) == toString new Gene from {1})
-- A sequence is one value, drawn between its parentheses.
assert(toString rod' (1, 2) == "(1,2)")
L = new MutableList from {1}
L#0 = L
assert instance(rod' L, Rod)
///
end--
