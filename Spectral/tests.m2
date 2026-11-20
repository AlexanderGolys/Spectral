-- Worked examples of what Spectral draws, each checked: what a drawing reads as,
-- at depths given explicitly rather than by any class's setting.

TEST ///
-- A Rod is an expression with how it is drawn: Rod{shape, meta}, its parts Rods.
R = QQ[x, y]
half = rod(1/2)
assert instance(half, Rod)
assert instance(half#0, Divide)
assert all(toList half#0, part -> instance(part, Rod))
assert(toString half == "1/2")
assert drawsAs(rod(x + 1), Sum)
-- Built by hand, a drawing is the expression it lays out.
assert(toString Rod {RowExpression {rod x, Rod {Holder {" (+) "},
	{Highlight => HLG "Operator"}}, rod y}} == "x (+) y")
///

TEST ///
-- A colour is one of the shell's highlight groups, and a meta names only the
-- fields a drawing has: anything made up is an error where it is written.
assert(HLG "Operator" === HLG "Operator")
assert(try (HLG "Operatr"; false) else true)
assert(try (Rod {Holder {"+"}, {Hilight => HLG "Operator"}}; false) else true)
///

TEST ///
-- rod'(depth, C): a complex names its modules C_i and differentials d_i at depth
-- one, and shows the modules themselves from depth two.
R = QQ[x, y]
C = freeResolution coker vars R
named = toString net rod'(1, C)
assert(match("C", named) and match("d", named))
spelled = toString net rod'(2, C)
assert(not match("C", spelled) and match("R", spelled))
///

TEST ///
-- A value assigned with = is drawn by its name inside other values; the value
-- a drawing is of is spelled out, and one assigned with := keeps its notation.
R = QQ[x, y]
I = ideal(x^2, y^3)
assert(toString rod(R/I) == "R/I")
assert match("ideal", toString rod I)
J := ideal(x^2)
assert(toString rod(R/J) != "R/J")
///

TEST ///
-- specType'(depth, x): the type annotation, as deep as asked: a module over its
-- ring from depth two.
R = QQ[x, y]
assert(toString specType'(1, R^2) == "Module")
assert(toString specType'(2, R^2) == "Module[R]")
assert(toString specType'(1, 1/2) == "QQ")
///

TEST ///
-- speek'(depth, x): x inspected as peek inspects it, drawn: a list as its class
-- over its entries, a hash table as its class over its pairs.
assert(toString speek'(1, {1, 2}) == "List{1, 2}")
assert(toString speek'(2, {1, {2}}) == "List{1, List{2}}")
assert match("HashTable", toString net speek'(1, new HashTable from {symbol a => 1}))
///
