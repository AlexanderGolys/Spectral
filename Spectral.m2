-- -*- coding: utf-8 -*-
newPackage(
	"Spectral",
	Version => "1.0.0",
	Date => "November 21, 2026",
	Headline => "values serialized for the Spectral shell",
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
	"shape",
	"typeShape",
	"atom",
	"HLG",
	"highlightGroup",
	"font",
	"UnderExpression",
	"OverExpression",
	"AlignedExpression",
	"DiagramExpression",
	"TreeExpression",
	"Straight"
}

-- The names a drawing keeps its fields under, and the spellings below theirs:
-- keys only, protected as M2 asks of the names a package binds nothing to.
protect \ { symbol Shape, symbol Parts, symbol Atom, symbol Highlight, symbol Font,
	symbol Rows, symbol Pieces, symbol Arrows, symbol typeNames, symbol PathSeparator,
	symbol Elided, symbol FileScheme, symbol LineMark, symbol ColumnMark,
	symbol RangeMark }

-- HLG "Operator": one of the shell's highlight groups, a unit value known by its
-- name alone. The shell keeps the groups and tells them as it starts, so a name
-- it has none of is an error where the group is made, and a group it gains
-- needs nothing here; before it tells, or with no shell at all, any name goes.
knownGroups = null
HLG = new SelfInitializingType of BasicList
new HLG from String := (HLG, name) -> (
	if knownGroups =!= null and not member(name, knownGroups) then
		error("the shell has no highlight group " | format name);
	{ name }
)
net HLG := toString HLG := group -> toString Adjacent { class group, format group#0 }

-- The faces an atom can be set in: TeX's own maths, italic letters and upright
-- digits, is MathNormal; the rest are TeX's alphabets and text faces.
fonts = { "MathNormal", "MathBB", "MathFrak", "MathCal", "MathBf", "MathIt", "MathRm",
	"TextTT", "TextNormal", "TextBf", "TextIt" }

-- What the shell reads that no value and nothing of M2's spells: how a path is
-- separated, the mark standing for the directories a shortened path leaves out,
-- and a link to a file, `file:///a/b.m2#L12:C3-L14:C5`.
Spelling = new HashTable from {
	symbol PathSeparator => "/",
	symbol Elided => "[...]",
	symbol FileScheme => "file://",
	symbol LineMark => "#L",
	symbol ColumnMark => ":C",
	symbol RangeMark => "-L"
}

-- A drawing as the shell reads it: its shape, named by the class it draws or
-- by Atom for a leaf, and its parts.
shaped = (kind, parts) -> hashTable {
	symbol Shape => toString kind,
	symbol Parts => parts
}

atom = method()
atom (String, HLG, String) := (text, group, face) -> (
	if not member(face, fonts) then
		error("no font " | format face | "; there are " | demark(", ", fonts));
	shaped(symbol Atom, hashTable {
		symbol Text => text,
		symbol Highlight => group#0,
		symbol Font => face
	})
)

shape = method(Dispatch => Thing)
typeShape = method(Dispatch => Thing)
highlightGroup = method(Dispatch => Type)
font = method(Dispatch => Type)

-- Spectral's own expressions, for layouts no class of Core's has.
-- UnderExpression{base, label}, OverExpression{base, label}: a label centred
-- beneath or above an expression, keeping the expression's baseline.
UnderExpression = new HeaderType of Expression
OverExpression = new HeaderType of Expression
-- AlignedExpression{{a, b, c}, …}: rows whose every cell but the last sits in a
-- column aligned across the rows, the last running on, as a table's values
-- beside its keys.
AlignedExpression = new HeaderType of Expression
-- DiagramExpression{pieces, arrows}: pieces {{row, column}, piece} on a grid
-- joined by arrows {from, to, label}, the label null for none; Straight => d
-- gives the same diagram for a layout in characters when this one runs arrows
-- across columns.
DiagramExpression = new HeaderType of Expression
-- TreeExpression{{label, subtree}, …}: a hierarchy, each branch a label over
-- its subtree.
TreeExpression = new HeaderType of Expression

load "./Spectral/expressions.m2"
load "./Spectral/values.m2"
load "./Spectral/complexes.m2"
load "./Spectral/documentation.m2"

-- What the shell is sent for a value, the value itself drawn by what it is
-- rather than by a name holding it. A serializer that throws leaves the value
-- spelled as M2 spells it.
spelled = x -> atom(try toString x
		else toString class x, HLG "Text", "TextTT")
drawnAs = x -> hashTable {
	symbol value => try shape x
		else spelled x,
	symbol location => try location x,
	symbol document => if instance(x, Hypertext) then
			page x
}
typedAs = x -> try typeShape x else spelled class x
inspectedAs = x -> try shape TreeExpression { branch expression x } else spelled x

beginDocumentation()

doc ///
Node
  Key
    Spectral
  Headline
    values serialized for the Spectral shell
  Description
    Text
      Spectral sends each value the Spectral shell shows as a drawing: the
      value's @TO expression@, every part in one of the shapes the shell lays
      out, every leaf an @TO atom@ with its colour and face. A class drawn
      through its expression needs nothing more; @TO shape@ is installed only
      where an expression is not enough, as for complexes.
Node
  Key
    shape
    (shape, Thing)
  Headline
    a value serialized for the shell
  Usage
    shape x
  Description
    Text
      shape x is x as the shell draws it: the shape of its expression, each
      part shaped in turn, down to the atoms of what M2 spells by itself. A
      class whose expression says too little gets a shape of its own,
      returning the shape of an expression built for it. Complexes are drawn
      so: a complex as its chain of modules over their degrees, a map of
      complexes as a @TO DiagramExpression@.
    Example
      R = QQ[x, y];
      shape(x^2 - 1/2)
      Pair = new Type of BasicList;
      shape Pair := p -> shape MapExpression { p#0, p#1 };
      shape new Pair from { R^1, R^2 }
Node
  Key
    typeShape
    (typeShape, Thing)
  Headline
    the type shown beside a value
  Usage
    typeShape x
  Description
    Text
      The class of x, or, where one is installed, how a class labels its
      values: an ideal and a module over their ring, a matrix from its source
      to its target.
    Example
      R = QQ[x, y];
      typeShape ideal x
Node
  Key
    atom
    (atom, String, HLG, String)
  Headline
    a leaf of a drawing
  Usage
    atom(text, group, face)
  Description
    Text
      Text coloured as one of the shell's highlight groups, an @TO HLG@, and set in a face:
      MathNormal for TeX's own maths, a maths alphabet such as MathBB, where Q
      is ℚ, or a text face such as TextTT, the typewriter face of code.
    Example
      atom("+", HLG "Operator", "MathNormal")
Node
  Key
    highlightGroup
    (highlightGroup, Thing)
    font
    (font, Thing)
  Headline
    how a leaf of a class is coloured and set
  Usage
    highlightGroup T
    font T
  Description
    Text
      A value M2 spells by itself, and a name standing for a value, is an atom
      coloured as highlightGroup of its class says and set in its font.
      Install both for a class of your own.
    Example
      highlightGroup Ring
      font ZZ
      Point = new Type of List;
      highlightGroup Point := T -> HLG "Operator";
Node
  Key
    HLG
  Headline
    the shell's colours an atom can name
  Description
    Text
      HLG "name" is the shell's highlight group by that name, one of those code
      and its values are coloured with, such as Operator, Type or Comment. The
      shell keeps the groups and tells them as it starts; inside it a name it
      has none of is an error where the group is made.
    Example
      HLG "Operator"
Node
  Key
    UnderExpression
    OverExpression
    AlignedExpression
    DiagramExpression
    TreeExpression
    Straight
  Headline
    layouts the shell draws beyond Core's expressions
  Description
    Text
      UnderExpression{base, label} and OverExpression{base, label} centre a
      label beneath or above an expression. AlignedExpression rows align every
      cell but the last. DiagramExpression{pieces, arrows} places pieces on a
      grid joined by labelled arrows, Straight giving the same diagram for a
      layout in characters. TreeExpression{{label, subtree}, …} is a hierarchy.
    Example
      shape UnderExpression { 1, 2 }
///