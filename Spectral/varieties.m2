-- Varieties and sheaves on them. A variety is over its ring, a sheaf of rings
-- over its variety, and a sheaf of modules over its sheaf of rings.

rod Variety := variety' -> rod' Rod {expression variety', Parameters => {ring variety'},
	Typeset => true}

typeParameters SheafOfRings := sheaf -> {variety sheaf}
rod SheafOfRings := sheaf -> rod' Rod {expression sheaf, Parameters => {variety sheaf},
	Typeset => true}

-- A sheaf's rank is an index on it, as in OO_X^2, spelled as a module's is.
typeParameters CoherentSheaf := sheaf -> {ring sheaf}
rod CoherentSheaf := sheaf -> rod' Rod {rankOneDropped expression sheaf,
	Parameters => {variety sheaf}, Typeset => true}

-- A map of sheaves is from its source to its target.
typeParameters SheafMap := map' -> {MapExpression {map'.target, map'.source}}
rod SheafMap := map' -> rod' expression map' ++ {Typeset => true}
