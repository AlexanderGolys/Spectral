-- Complexes and their maps, drawn as their modules and the maps between them
-- rather than only by their names.

-- A complex is its chain of modules C_i and differentials d_i between zeros.
Complex.typeset = true
Complex.valueDepth = 2
Complex.typedByParameters = true
placeholder Complex := String => x -> "C"
parameters Complex := x -> {ring x}
specNet Complex := complex -> (
	if complex == 0 then
		return specNet 0;
	(lo, hi) := concentration complex;
	module := degree -> Intermediate {
		Subscript {symbol C, degree},
		complex_degree,
		UnderExpression {Holder {complex_degree}, degree}
	};
	differential := degree -> Intermediate {
		Subscript {symbol d, degree},
		complex.dd_degree,
		new Array from {Table entries complex.dd_degree}
	};
	chain := fold((drawn, degree) -> MapExpression {
		drawn,
		module degree,
		differential degree
	}, MapExpression {expression 0, module lo}, toList(lo + 1 .. hi));
	unfolding(complex, MapExpression {chain, expression 0})
)

-- A map of complexes as its two complexes, one above the other with each degree
-- in a column of its own, and the components between them:
-- ComplexMapExpression{degree, source, target, components}, where a complex is a
-- list of {degree, module, differential into the module before} and a component
-- is {degree, map}; the module at the lowest degree has no differential.
ComplexMapExpression = new HeaderType of Expression

-- A map is drawn as its two complexes aligned by degree, each nonzero component
-- running down from its source to its target, as many columns across as the
-- map's degree: straight down for a chain map, one column for a differential.
-- A slanting component has no room beside it for a matrix, only its name.
-- The matrices, two to each degree, wait one level past the modules.
ComplexMap.typeset = true
ComplexMap.valueDepth = 2
placeholder ComplexMap := String => x -> "f"
specNet ComplexMap := map -> (
	matrixPart := (name, degree, matrix) -> Intermediate {
		Subscript {name, degree}, matrix,
		new Array from {Table entries matrix}, 2
	};
	chain := (complex, name) -> (
		(lo, hi) := concentration complex;
		apply(toList(lo .. hi), degree -> join({degree,
			Intermediate {Subscript {name, degree}, complex_degree,
				Holder {complex_degree}}},
			if degree == lo then {} else {matrixPart(symbol d, degree,
				complex.dd_degree)}))
	);
	targetName := if source map === target map then
			symbol C
		else symbol D;
	mapName := if map === (source map).dd then
			symbol d
		else symbol f;
	shift := degree map;
	(lo, hi) := concentration source map;
	components := select(apply(toList(lo .. hi), degree -> (
		component := map_degree;
		if component != 0 then
			if shift != 0 then {degree, Subscript {mapName, degree}} else {
				degree, matrixPart(mapName, degree, component)
			}
	)),
		entry -> entry =!= null);
	unfolding(map, ComplexMapExpression {
		shift,
		chain(source map, symbol C),
		chain(target map, targetName),
		components
	})
)
