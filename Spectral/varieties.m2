-- Varieties and sheaves on them. A sheaf of modules is over its sheaf of rings,
-- which is over its variety.

typeset Variety := class' -> true
highlightGroup Variety := class' -> hl$Variable
parameters Variety := x -> {ring x}

-- A sheaf of rings is spelled by M2 over its variety.
typeset SheafOfRings := typedByParameters SheafOfRings := class' -> true
parameters SheafOfRings := x -> {variety x}

-- A sheaf's rank is an index on it, as in OO_X^2, spelled as a module's is.
typeset CoherentSheaf := typedByParameters CoherentSheaf := class' -> true
keepNames CoherentSheaf
parameters CoherentSheaf := x -> {ring x}
spelledShape (CoherentSheaf, Expression) := lookup(spelledShape, Module, Expression)

-- A map of sheaves is from its source to its target, a level below its sheaves'
-- sheaf of rings.
typeset SheafMap := class' -> true
typeDepth SheafMap := class' -> 3
typedByParameters SheafMap := class' -> true
keepNames SheafMap
parameters SheafMap := f -> {MapExpression {f.target, f.source}}
