-- Complexes and their maps, drawn as their modules and the maps between them,
-- each by its name when it has one.

-- A complex is its chain of modules, each over its degree, and the
-- differentials between them, between zeros.
typeParameters Complex := complex -> {ring complex}
rod Complex := complex -> (
	if complex == 0 then
		return rod' 0;
	(lo, hi) := concentration complex;
	module := degree -> UnderExpression {complex_degree, degree};
	chain := fold((drawn, degree) -> MapExpression {drawn, module degree,
		complex.dd_degree}, MapExpression {expression 0, module lo},
		toList(lo + 1 .. hi));
	rod' MapExpression {chain, expression 0} ++ {Typeset => true}
)

-- A map of complexes is drawn as a diagram: the source complex above the
-- target, between zeros, each module in the column of its degree, the degrees
-- numbered beneath, and each nonzero component an arrow down from its source
-- module to its target, as many columns across as the map's degree: straight
-- down for a chain map, one column for a differential. A map of nonzero degree
-- runs its components across columns, which characters cannot draw, so it also
-- carries the Straight diagram, the target shifted under the components'
-- sources and each complex numbered on its own. A complex is listed as
-- {degree, module, differential into the module before}, the module at the
-- lowest degree without one, and a component as {degree, map}.
rod ComplexMap := map' -> (
	shift := degree map';
	listed := complex -> (
		(lo, hi) := concentration complex;
		apply(toList(lo .. hi), degree -> join({degree, complex_degree},
			if degree == lo then {} else {complex.dd_degree}))
	);
	(source, target) := (listed source map', listed target map');
	(lo, hi) := concentration source map';
	components := select(apply(toList(lo .. hi), degree -> {degree, map'_degree}),
		component -> component#1 != 0);
	arranged := straight -> (
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
		-- Each complex as its pieces and its arrows.
		drawn := apply(2, k -> (
			chain := {source, target}#k;
			at := degree -> {rows#k, column(degree, offsets#k)};
			(first', last') := (min degrees chain, max degrees chain);
			{{{at(first' - 1), 0}, {at(last' + 1), 0}} | apply(chain, entry ->
					{at entry#0, entry#1}),
				{{at first', at(first' - 1), null}, {at(last' + 1), at last', null}}
					| apply(select(chain, entry -> #entry > 2), entry ->
							{at entry#0, at(entry#0 - 1), entry#2})}
		));
		DiagramExpression {
			flatten apply(drawn, first) | flatten apply(numbered, (row, offset,
				numbers) -> apply(toList(min numbers .. max numbers), degree ->
						{{row, column(degree, offset)}, degree})),
			flatten apply(drawn, last) | apply(components, component -> {
				{rows#0, column(component#0, offsets#0)},
				{rows#1, column(component#0 + shift, offsets#1)},
				component#1
			})
		}
	);
	diagram := if shift == 0 or #components == 0 then
			arranged false
		else append(arranged false, Straight => arranged true);
	rod' diagram ++ {Typeset => true}
)
