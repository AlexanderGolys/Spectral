-- Containers: drawn as their items, each at the container's own depth; a
-- container that holds itself is drawn once.

specNet VisibleList :=
specNet MutableList :=
specNet Option :=
	items -> contentsOf(items, toList items)

-- A table keeping the stock formatting shows its pairs, keys and arrows aligned.
specNet HashTable := table -> (
	stock := base -> lookup(expression, class table) === lookup(expression, base)
		and lookup(net, class table) === lookup(net, base);
	if any({HashTable, MutableHashTable}, stock) then
		contentsOf(table, {AlignedExpression apply(pairs table, pair -> {
			optionKey pair#0, symbol =>, pair#1
		})})
	else (lookup(specNet, Thing)) table
)

-- Class hierarchies keep their branches, rather than an opaque table summary.
-- Sorting the labels gives each level the same order as M2's native net.
-- A class name is a label, so a ring name never typesets the entire hierarchy.
specNet Descent := tree -> contentsOf(tree,
	apply(sort(pairs tree, pair -> toString net pair#0), pair ->
			new SpecNet from (RowExpression, {
				specNet(toString net pair#0) ++ {Highlight => {"Type"}},
				specNet pair#1
			})))
