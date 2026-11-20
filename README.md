# Spectral

A Macaulay2 package that draws values as trees that keep their structure. M2's `net` flattens a value into text. `rod` keeps the expression it came from, and records the class of every part, so a front end can lay it out and colour it by meaning. `specType` does the same for a value's type.

It is what the [spectral-m2](https://github.com/AlexanderGolys/spectral-m2) shell draws its results from, and it works on its own in any M2.

```m2
needsPackage "Spectral"
R = QQ[x, y];
I = ideal(x^2, y);
rod(x/2)          -- a Rod, printed as the text it lays out
rod(R/I)          -- R/I: a value a global name holds is drawn by that name
rod'_1(R/I)       -- QQ[x .. y]/ideal(x^2, y): the names resolved once
specType(R^2)     -- Module[R]
speek(1/2)        -- the drawing itself, the table of fields it is

Point = new Type of List
rod Point := p -> rod' FunctionApplication {symbol point, toSequence p}
rod new Point from {1, 1/2}   -- point(1, 1/2)
```

Install `rod` for a class to draw its values: it returns a `Rod`, here the drawing of an expression the class is spelled by, or one built of shapes whose parts are drawn with `rod'` and whose fields say how it is drawn, its colour `Group`, whether it is `Typeset`, the link it opens. A class without a `rod` is spelled as M2 spells it. The values a type is over are what `typeParameters` of the class gives: `typeParameters Module := M -> {ring M}`.

## Install

From a checkout:

```m2
installPackage("Spectral", FileName => "path/to/Spectral/Spectral.m2")
```

then `needsPackage "Spectral"` and `viewHelp "Spectral"`.

## License

MIT or Apache-2.0, at your option.
