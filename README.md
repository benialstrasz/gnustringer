# gnustring

Create commands for gnuplot for the same file in multiple directories.

Inputs:

** directories: space separated list of multiple directories containing the data file.

** X Column: Column number in the data file for the x axis
** X Scale: Scale the X values by this amount

** Y Columns: Column number(s) in the data file for the y axis! (space separated list possible)
** Y Scale: Scale the Y values by this amount

** CB Column: Optional column for the colour palette

** Plot Style: Plot data points, with line or with linespoints

** Data blocks loop: Supports a single file only; loop over multiple data blocks.

# Example
Generates the following string for given directories "dirA dirB dirC", the file "data.dat", X column "1", Y column "2 3 4":

```
plot "dirA/data.dat" u 1:2 w l, "" u 1:3 w l, "" u 1:4 w l, "dirB/data.dat" u 1:2 w l, "" u 1:3 w l, "" u 1:4 w l, "dirC/data.dat" u 1:2 w l, "" u 1:3 w l, "" u 1:4 w l
```
Double click generated string to edit.
