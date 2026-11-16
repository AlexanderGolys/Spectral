-- Varieties and sheaves on them. A sheaf of modules is over its sheaf of rings,
-- which is over its variety.

Variety.typeset = true
placeholder Variety := String => x -> "X"
parameters Variety := x -> {ring x}

-- A sheaf of rings is always drawn whole, M2 spelling it over its variety.
SheafOfRings.typeset = true
SheafOfRings.typedByParameters = true
placeholder SheafOfRings := Nothing => x -> null
parameters SheafOfRings := x -> {variety x}

-- A sheaf's rank is an index on it, as in OO_X^2, spelled as a module's is.
CoherentSheaf.typeset = true
CoherentSheaf.typedByParameters = true
placeholder CoherentSheaf := String => x -> "F"
parameters CoherentSheaf := x -> {ring x}
spelledShape (CoherentSheaf, Expression) := lookup(spelledShape, Module, Expression)

-- A map of sheaves is from its source to its target, a level below its sheaves'
-- sheaf of rings.
SheafMap.typeset = true
SheafMap.typeDepth = 3
SheafMap.typedByParameters = true
parameters SheafMap := f -> {MapExpression {f.target, f.source}}
