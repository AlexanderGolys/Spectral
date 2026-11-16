-- Numbers, rings and what is built over them: ideals, modules, matrices and maps.
-- All of it is typeset maths.

Number.typeset = true
specNet InexactNumber := opaque

RingElement.typeset = true

-- A ring is drawn by its name, with its own TeX; unnamed past the value depth it
-- is R.
Ring.typeset = true
placeholder Ring := String => x -> "R"
opaque Ring := x -> (lookup(opaque, Thing)) x ++ {Tex => texMath x}

RingFamily.typeset = true
opaque RingFamily := lookup(opaque, Ring)

-- A functor such as OO or HH is drawn by its name, with its own TeX.
opaque ScriptedFunctor := lookup(opaque, Ring)

-- A ring is over what it is built from.
parameters QuotientRing := x -> {ambient x}
parameters PolynomialRing := x -> {coefficientRing x}

Ideal.typeset = true
Ideal.typedByParameters = true
placeholder Ideal := String => x -> "I"
parameters Ideal := x -> {ring x}

-- A module is over its ring. Its rank is an index on it, as in R^2, rather than
-- a power, and M2 spells rank one as an explicit `^1` that its type already
-- tells apart from the base.
Module.typeset = true
Module.typeDepth = 2
Module.typedByParameters = true
placeholder Module := String => x -> "M"
parameters Module := x -> {ring x}
spelledShape (Module, Expression) := (x, shape) -> (
	if instance(shape, Superscript) and instance(shape#1, OneExpression) then
		shape#0
	else if instance(shape, Adjacent) then
		apply(shape, spelledShape_x)
	else shape
)

-- A map is from its source to its target, spelled `N <-- M` as M2 spells it.
-- Its parameters are modules, a level below a module's ring.
Matrix.typeset = true
Matrix.typeDepth = 3
Matrix.typedByParameters = true
parameters Matrix := f -> {MapExpression {f.target, f.source}}

RingMap.typeset = true
