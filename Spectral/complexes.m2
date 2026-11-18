-- Complexes and their maps, drawn as their modules and the maps between them
-- rather than only by their names.

-- A complex is its chain of modules C_i and differentials d_i between zeros.
Complex.typeset = true
Complex.valueDepth = 2
Complex.typedByParameters = true
placeholder Complex := String => x -> "C"
parameters Complex := x -> {ring x}
rod Complex := complex -> (
	if complex == 0 then
		return rod 0;
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

-- It is laid out as a diagram: the source complex above the target, between
-- zeros, each module in the column of its degree, the degrees numbered beneath,
-- and each component an arrow down from its source module to its target. A map
-- of nonzero degree runs its components across columns, which characters cannot
-- draw, so it also carries the Straight diagram, the target shifted under the
-- components' sources and each complex numbered on its own.
formatted ComplexMapExpression := shape -> (
	aligned := arranged(shape, false);
	if shape#0 == 0 or #shape#3 == 0 then
		aligned
	else aligned ++ {Straight => arranged(shape, true)}
)
arranged (ComplexMapExpression, Boolean) := (shape, straight) -> (
	(shift, source, target, components) := toSequence shape;
	degrees := chain -> apply(chain, entry -> entry#0);
	-- How far left of its degree's column each complex's modules sit, the row
	-- each complex takes, and the rows its degrees are numbered on.
	offsets := {0, if straight then
				shift
			else 0};
	rows := if straight then {1, 2} else {0, 1};
	numbered := if straight then
			{(0, 0, degrees source), (3, shift, degrees target)} else {(2, 0,
				degrees source | degrees target)};
	-- The first column is the zero before the lowest degree.
	lowest := min flatten apply(2, k -> apply(degrees {source, target}#k, degree ->
			degree - offsets#k));
	column := (degree, offset) -> degree - offset - lowest + 1;
	zero := rod 0;
	-- Each complex as its pieces and its arrows.
	drawn := apply(2, k -> (
		chain := {source, target}#k;
		at := degree -> {rows#k, column(degree, offsets#k)};
		(first', last') := (min degrees chain, max degrees chain);
		{{{at(first' - 1), zero}, {at(last' + 1), zero}} | apply(chain, entry ->
				{at entry#0, rod entry#1}),
			{{at first', at(first' - 1), null}, {at(last' + 1), at last', null}}
				| apply(select(chain, entry -> #entry > 2), entry ->
						{at entry#0, at(entry#0 - 1), rod entry#2})}
	));
	new Rod from {
		Shape => "Diagram",
		Pieces => flatten apply(drawn, first) | flatten apply(numbered, (row,
			offset, numbers) ->
				apply(toList(min numbers .. max numbers), degree ->
						{{row, column(degree, offset)}, rod degree})),
		Arrows => flatten apply(drawn, last) | apply(components, component -> {
			{rows#0, column(component#0, offsets#0)},
			{rows#1, column(component#0 + shift, offsets#1)},
			rod component#1
		})
	}
)

-- A map is drawn as its two complexes aligned by degree, each nonzero component
-- running down from its source to its target, as many columns across as the
-- map's degree: straight down for a chain map, one column for a differential.
-- A slanting component has no room beside it for a matrix, only its name.
-- The matrices, two to each degree, wait one level past the modules.
ComplexMap.typeset = true
ComplexMap.valueDepth = 2
placeholder ComplexMap := String => x -> "f"
rod ComplexMap := map -> (
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
