-- Numbers, rings and what is built over them: ideals, modules, matrices and maps.
-- All of it is typeset maths.

-- A number M2 spells as one atom is a numeral; any other, such as 1/2 or -3,
-- is drawn from its expression.
numeral := number -> Rod {Holder {toString number}, Group => HLG "Number",
	Typeset => true}
rod Number := number -> (
	if instance(expression number, Holder) then
		numeral number
	else rod' expression number
)
rod InexactNumber := numeral

rod RingElement := rod Vector := element -> rod' expression element ++ {
	Typeset => true
}

-- A ring M2 spells by itself is drawn by its name with its own TeX, as are a
-- family of rings and a functor such as OO or HH; any other ring by what M2
-- spells it from, without the options only a description lists:
-- QQ[x, Degrees => {1}] is QQ[x], and over the rings it is built from, given
-- as a function of that expression.
named := (x, group) -> Rod {Holder {toString x}, Group => HLG group, Tex => texMath x,
	Typeset => true}
optionsDropped := shape -> (
	if instance(shape, Array) then
		select(shape, part ->
				not (instance(part, BinaryOperation) and part#0 === symbol =>))
	else if instance(shape, Expression) and not instance(shape, Holder) then
		apply(shape, optionsDropped)
	else shape
)
described := (ring', parameters) -> (
	description := (describe ring')#0;
	if instance(description, Ring) then
		return named(ring', "Type");
	shape := optionsDropped expression description;
	rod' Rod {shape, Parameters => parameters shape, Typeset => true}
)
rod Ring := ring' -> described(ring', shape -> {})
rod PolynomialRing := ring' -> described(ring', shape -> {coefficientRing ring'})
-- M2 spells a quotient ring over its relations, which name no ideal; one
-- whose ideal has a name is drawn over that name. A fraction field is over the
-- ring it is the field of, which its description spells out in full.
rod QuotientRing := ring' -> described(ring', shape -> {ambient ring',
	shape#1 => ideal ring'})
rod FractionField := field' -> described(field', shape -> {shape#1 =>
		last field'.baseRings})
rod RingFamily := family -> named(family, "Type")
rod ScriptedFunctor := functor -> named(functor, "Function")

-- An ideal is over its ring.
typeParameters Ideal := ideal' -> {ring ideal'}
rod Ideal := ideal' -> rod' Rod {expression ideal', Parameters => {ring ideal'},
	Typeset => true}

-- A module is over its ring. Its rank is an index on it, as in R^2, rather
-- than a power, and M2 spells rank one as an explicit `^1` that its type
-- already tells apart from the base; a sheaf is spelled as a module is.
typeParameters Module := module' -> {ring module'}
rankOneDropped = shape -> (
	if instance(shape, Superscript) and instance(shape#1, OneExpression) then
		shape#0
	else if instance(shape, Adjacent) then
		apply(shape, rankOneDropped)
	else shape
)
rod Module := module' -> rod' Rod {rankOneDropped expression module', Parameters => {
	ring module'
}, Typeset => true}

-- A map is from its source to its target, spelled `N <-- M` as M2 spells it;
-- a map of rings over the rings it maps between.
typeParameters Matrix := matrix' -> {MapExpression {matrix'.target, matrix'.source}}
rod Matrix := matrix' -> rod' expression matrix' ++ {Typeset => true}
rod RingMap := map' -> rod' Rod {expression map', Parameters => {target map',
	source map'},
	Typeset => true}

-- A mutable matrix is drawn as a matrix is, without the mark M2 spells it
-- apart by.
rod MutableMatrix := matrix' -> rod' select(expression matrix', row ->
		not (instance(row, Option) and row#0 === symbol MutableMatrix)) ++ {
			Typeset => true
		}

-- Betti numbers as M2 tabulates them: a column for each homological degree i, a
-- row for each slanted degree j - i, the totals above, and a dot for none.
rod BettiTally := betti' -> (
	columns := sort unique apply(keys betti', key -> key#0);
	slants := sort unique apply(keys betti', key -> key#2 - key#0);
	counted := select' -> sum(select(keys betti', select'), key -> betti'#key);
	label := text -> Rod {Holder {text}, Highlight => HLG "Muted"};
	Rod {Table join({prepend(label "", apply(columns, rod'))}, {prepend(label "total:",
		apply(columns, i -> rod' counted(key -> key#0 == i)))}, apply(slants, slant ->
				prepend(label(toString slant | ":"), apply(columns, i -> (
					count := counted(key -> key#0 == i and key#2 - key#0 == slant);
					if count == 0 then
						label "."
					else rod' count
				)))))}
)
