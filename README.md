# Spectral

A Macaulay2 package that draws values as trees that keep their structure. M2's `net` flattens a value into text. `rod` keeps the expression it came from, and records the class of every part, so a front end can lay it out and colour it by meaning. `specType` does the same for a value's type.

It is what the [spectral-m2](https://github.com/AlexanderGolys/spectral-m2) shell draws its results from, and it works on its own in any M2.

```m2
needsPackage "Spectral"
R = QQ[x, y];
rod(x/2)          -- a Rod, printed as the text it lays out
speek {1, 1/2}    -- List{1, 1/2}: inspected as peek inspects it, drawn
speek rod(1/2)    -- the fields of the drawing itself

Point = new Type of List
expression Point := p -> new FunctionApplication from (symbol point, toSequence p)
rod new Point from {1, 1/2}   -- point(1, 1/2)
```

A class that already has an `expression` is drawn from it with nothing else to do. Install `rod` for a class to draw it some other way. What a class says about how its values are drawn, its colour or the depth its type is shown to, is a method of the class returning a constant: `highlightGroup Point := class' -> "Function"`.

## Install

From a checkout:

```m2
installPackage("Spectral", FileName => "path/to/Spectral/Spectral.m2")
```

then `needsPackage "Spectral"` and `viewHelp "Spectral"`.

## License

MIT or Apache-2.0, at your option.
