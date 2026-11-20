-- Numbers, rings and what is built over them: ideals, modules, matrices and maps.
-- All of it is typeset maths.

typeset Number := class' -> true
highlightGroup Number := class' -> "Number"
rod InexactNumber := opaque

typeset RingElement := class' -> true
highlightGroup RingElement := class' -> "Variable"

-- A ring is drawn by its name, with its own TeX; unnamed past the value depth it
-- is R.
typeset Ring := class' -> true
highlightGroup Ring := class' -> "Type"
placeholder Ring := String => x -> "R"
opaque Ring := x -> (lookup(opaque, Thing)) x ++ {Tex => texMath x}

typeset RingFamily := class' -> true
highlightGroup RingFamily := class' -> "Type"
opaque RingFamily := lookup(opaque, Ring)

-- A functor such as OO or HH is drawn by its name, with its own TeX.
highlightGroup ScriptedFunctor := class' -> "Function"
opaque ScriptedFunctor := lookup(opaque, Ring)

-- A ring is over what it is built from.
parameters QuotientRing := List => x -> {ambient x}
parameters PolynomialRing := List => x -> {coefficientRing x}

typeset Ideal := typedByParameters Ideal := class' -> true
placeholder Ideal := String => x -> "I"
parameters Ideal := List => x -> {ring x}

-- A module is over its ring. Its rank is an index on it, as in R^2, rather than
-- a power, and M2 spells rank one as an explicit `^1` that its type already
-- tells apart from the base.
typeset Module := typedByParameters Module := class' -> true
typeDepth Module := class' -> 2
placeholder Module := String => x -> "M"
parameters Module := List => x -> {ring x}
spelledShape (Module, Expression) := (x, shape) -> (
	if instance(shape, Superscript) and instance(shape#1, OneExpression) then
		shape#0
	else if instance(shape, Adjacent) then
		apply(shape, spelledShape_x)
	else shape
)

-- A map is from its source to its target, spelled `N <-- M` as M2 spells it.
-- Its parameters are modules, a level below a module's ring.
typeset Matrix := typedByParameters Matrix := class' -> true
typeDepth Matrix := class' -> 3
parameters Matrix := List => f -> {MapExpression {f.target, f.source}}

typeset RingMap := class' -> true

-- A mutable matrix is drawn as a matrix is, without the mark M2 spells it apart by.
typeset MutableMatrix := class' -> true
spelledShape (MutableMatrix, Expression) := MatrixExpression => (matrix,
	shape) -> select(shape, row ->
			not (instance(row, Option) and row#0 === symbol MutableMatrix))

-- Betti numbers as M2 tabulates them: a column for each homological degree i, a
-- row for each slanted degree j - i, the totals above, and a dot for none.
rod BettiTally := betti' -> contentsOf(betti', betti' -> (
	columns := sort unique apply(keys betti', key -> key#0);
	slants := sort unique apply(keys betti', key -> key#2 - key#0);
	counted := select' -> sum(select(keys betti', select'), key -> betti'#key);
	label := text -> atom(text, "Muted");
	grid(join({prepend(label "", apply(columns, rod))}, {prepend(label "total:",
		apply(columns, i -> rod counted(key -> key#0 == i)))}, apply(slants, slant ->
				prepend(label(toString slant | ":"), apply(columns, i -> (
					count := counted(key -> key#0 == i and key#2 - key#0 == slant);
					if count == 0 then
						label "."
					else rod count
				))))), "Bare")
))
