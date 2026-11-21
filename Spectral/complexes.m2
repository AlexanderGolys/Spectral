-- Complexes and their maps: values no expression of M2's lays out, each given a
-- shape of its own as an expression built for it, as any class can be.

-- A complex is its chain of modules, each over its degree, and the
-- differentials between them, between zeros.
shape Complex := complex -> (
	if complex == 0 then
		return shape 0;
	(lo, hi) := concentration complex;
	module := i -> UnderExpression { complex_i, i };
	shape MapExpression { fold((chain, i) -> MapExpression { chain, module i,
		complex.dd_i }, MapExpression { 0, module lo }, toList(lo + 1 .. hi)), 0 }
)

-- A map of complexes is a diagram: the source complex above the target, between
-- zeros, each module in the column of its degree, the degrees numbered beneath,
-- and each nonzero component an arrow down from its source module to its
-- target, as many columns across as the map's degree. Characters cannot draw an
-- arrow across columns, so a map of nonzero degree also carries the Straight
-- diagram, the target shifted under the components' sources and each complex
-- numbered on its own.
shape ComplexMap := map' -> (
	shift := degree map';
	chains := { source map', target map' };
	spans := apply(chains, complex -> toList((concentration complex)#0 ..
		(concentration complex)#1));
	components := select(spans#0, i -> map'_i != 0);
	arranged := straight -> (
		-- How far left of its degree's column each complex's modules sit, the row
		-- each complex takes, and the rows its degrees are numbered on.
		offsets := { 0, if straight then shift else 0 };
		rows := if straight then { 1, 2 } else { 0, 1 };
		numbered := if straight then
				{ (0, 0, spans#0), (3, shift, spans#1) }
			else { (2, 0, toList(min flatten spans .. max flatten spans)) };
		-- The first column is the zero before the lowest degree.
		lowest := min apply(2, k -> min spans#k - offsets#k);
		column := (i, offset) -> i - offset - lowest + 1;
		at := (k, i) -> { rows#k, column(i, offsets#k) };
		pieces := k -> (
			(lo, hi) := (first spans#k, last spans#k);
			{ { at(k, lo - 1), 0 }, { at(k, hi + 1), 0 } }
				| apply(spans#k, i -> { at(k, i), (chains#k)_i })
		);
		arrows := k -> (
			(lo, hi) := (first spans#k, last spans#k);
			{ { at(k, lo), at(k, lo - 1), null }, { at(k, hi + 1), at(k, hi), null } }
				| apply(drop(spans#k, 1), i -> { at(k, i), at(k, i - 1), (chains#k).dd_i })
		);
		DiagramExpression {
			pieces 0 | pieces 1 | flatten apply(numbered, (row', offset, span') ->
				apply(span', i -> { { row', column(i, offset) }, i })),
			arrows 0 | arrows 1 | apply(components, i -> { at(0, i),
				{ rows#1, column(i + shift, offsets#1) }, map'_i })
		}
	);
	shape(if shift == 0 or #components == 0 then
			arranged false
		else append(arranged false, Straight => arranged true))
)