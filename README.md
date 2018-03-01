# Sudoku Challenge

## Basis

Sudoku is basically a gridworld style puzzle based on number placement. An example implementation is to fill up a 9×9 grid with digits so that each column, each row, and each of the nine 3×3 sub-grids that compose the grid contain all of the digits from 1 to 9.

There is a validity condition, however, which is broken into three parts. A sudoku board is said to be "valid" if the following conditions hold:

* no duplicates in a row
* no duplicates in a column
* no duplicates in a sub-grid

If any condition is violated, the board is said to be "invalid."

There is also a completeness condition. The board must be entirely filled with numbers. Any space on the board not populated by a digit is considered empty. If a board has any empty cells, it is said to be "incomplete."

Here's an example of a board that is Valid, Complete

```
8 5 9 |6 1 2 |4 3 7
7 2 3 |8 5 4 |1 6 9
1 6 4 |3 7 9 |5 2 8
------+------+------
9 8 6 |1 4 7 |3 5 2
3 7 5 |2 6 8 |9 1 4
2 4 1 |5 9 3 |7 8 6
------+------+------
4 3 2 |9 8 1 |6 7 5
6 1 7 |4 2 5 |8 9 3
5 9 8 |7 3 6 |2 4 1
```

## Simple Validator

In my implementation that becomes (via `SudokuBoardParser : initialize :: contents`):

```
"8 5 9 |6 1 2 |4 3 7 \n" +
"7 2 3 |8 5 4 |1 6 9 \n" +
"1 6 4 |3 7 9 |5 2 8 \n" +
"------+------+------\n" +
"9 8 6 |1 4 7 |3 5 2 \n" +
"3 7 5 |2 6 8 |9 1 4 \n" +
"2 4 1 |5 9 3 |7 8 6 \n" +
"------+------+------\n" +
"4 3 2 |9 8 1 |6 7 5 \n" +
"6 1 7 |4 2 5 |8 9 3 \n" +
"5 9 8 |7 3 6 |2 4 1 \n"
```

I break the board down as such: (via `SudokuBoardParser : initialize :: sudoku_values`):

"859612437723854169164379528986147352375268914241593786432981675617425893598736241"

Then I create a grid (via `SudokuBoardParser : initialize :: grid`):

```
[["8", "5", "9", "6", "1", "2", "4", "3", "7"],
 ["7", "2", "3", "8", "5", "4", "1", "6", "9"],
 ["1", "6", "4", "3", "7", "9", "5", "2", "8"],
 ["9", "8", "6", "1", "4", "7", "3", "5", "2"],
 ["3", "7", "5", "2", "6", "8", "9", "1", "4"],
 ["2", "4", "1", "5", "9", "3", "7", "8", "6"],
 ["4", "3", "2", "9", "8", "1", "6", "7", "5"],
 ["6", "1", "7", "4", "2", "5", "8", "9", "3"],
 ["5", "9", "8", "7", "3", "6", "2", "4", "1"]]
```

The above is the grid that goes into the RowChecker, ColumnChecker and SubGridChecker classes.

RowChecker will look at each row:

```
["8", "5", "9", "6", "1", "2", "4", "3", "7"]
["7", "2", "3", "8", "5", "4", "1", "6", "9"]
...
```

It then checks if the row.uniq.size is equal to the row.size. That will only be the case if the row has entirely unique numbers for each cell.

ColumnChecker will look at each column:

```
["8", "7", "1", "9", "3", "2", "4", "6", "5"]
["5", "2", "6", "8", "7", "4", "3", "1", "9"]
...
```

Then a transposition is done and the RowChecker is reused. So, for example, these:

```
["8", "5", "9", "6", "1", "2", "4", "3", "7"]
["7", "2", "3", "8", "5", "4", "1", "6", "9"]
```

become these:

```
["8", "7", "1", "9", "3", "2", "4", "6", "5"]
["5", "2", "6", "8", "7", "4", "3", "1", "9"]
```

In other words, the column is made a row that can checked by the row checker. This allows the same type of check to be done.

The SubGridChecker is, by necessity, a little more complicated. The above board will be broken into subgrids:

```
 ["8", "5", "9", "6", "1", "2", "4", "3", "7"],
 ["7", "2", "3", "8", "5", "4", "1", "6", "9"],
 ["1", "6", "4", "3", "7", "9", "5", "2", "8"]

 ["9", "8", "6", "1", "4", "7", "3", "5", "2"],
 ["3", "7", "5", "2", "6", "8", "9", "1", "4"],
 ["2", "4", "1", "5", "9", "3", "7", "8", "6"]

 ["4", "3", "2", "9", "8", "1", "6", "7", "5"],
 ["6", "1", "7", "4", "2", "5", "8", "9", "3"],
 ["5", "9", "8", "7", "3", "6", "2", "4", "1"]
```

The subgrid breakdown will look like this:

```
 ["8", "5", "9", "7", "2", "3", "1", "6", "4"]
 ["6", "1", "2", "8", "5", "4", "3", "7", "9"]
 ["4", "3", "7", "1", "6", "9", "5", "2", "8"]

 ["9", "8", "6", "3", "7", "5", "2", "4", "1"]
 ["1", "4", "7", "2", "6", "8", "5", "9", "3"]
 ["3", "5", "2", "9", "1", "4", "7", "8", "6"]

 ["4", "3", "2", "6", "1", "7", "5", "9", "8"]
 ["9", "8", "1", "4", "2", "5", "7", "3", "6"]
 ["6", "7", "5", "8", "9", "3", "2", "4", "1"]
```

If you look at the numbers and the original graph you can see that the first row in the first table above is (spacing it like the original sudoku board):

```
[ "8" "5" "9" ]
[ "7" "2" "3" ]
[ "1" "6" "4" ]
```

That's matching grid space 1 (top left) on the original board. This happens for all 3x3 sections of the board and a new grid is created with this new configuration. Once this is done the RowChecker is run again since it's the same basic check, just with re-oriented data.

## Reporting Validator

Here I wanted the program to report on where it found issues such that valid solutions were not achieved. I did this in another implementation because I could not immediately figure out how to incorporate what I was doing here with what I already did.

Start off with a valid, complete board:

```
 [8, 5, 9, 6, 1, 2, 4, 3, 7],
 [7, 2, 3, 8, 5, 4, 1, 6, 9],
 [1, 6, 4, 3, 7, 9, 5, 2, 8],
 [9, 8, 6, 1, 4, 7, 3, 5, 2],
 [3, 7, 5, 2, 6, 8, 9, 1, 4],
 [2, 4, 1, 5, 9, 3, 7, 8, 6],
 [4, 3, 2, 9, 8, 1, 6, 7, 5],
 [6, 1, 7, 4, 2, 5, 8, 9, 3],
 [5, 9, 8, 7, 3, 6, 2, 4, 1]
```

This will get broken down into each row:

```
[8, 5, 9, 6, 1, 2, 4, 3, 7]
[7, 2, 3, 8, 5, 4, 1, 6, 9]
...
```

This does a simple check to see if the unique size of the row and the size of the row are the same. That will only happen if the numbers in the row are unique for each cell.

Then the same thing is done for the columns. They will be generated like this:

```
[8, 7, 1, 9, 3, 2, 4, 6, 5]
[5, 2, 6, 8, 7, 4, 3, 1, 9]
...
```

It's a row, but composed of the columns. Then it's just a matter of doing the same kind of row check as before.

If any data is missing, it will be converted to a 0. For example, if the first two rows of the grid are like this:

```
 [8, 5, 0, 0, 0, 2, 4, 0, 0]
 [7, 2, 0, 0, 0, 0, 0, 0, 9]
```

They will be handled as such:

```
 [8, 5, 0, 0, 0, 2, 4, 0, 0]
 [8, 5, 2, 4]

 [7, 2, 0, 0, 0, 0, 0, 0, 9]
 [7, 2, 9]
```

You can see there that only non-zero values are considered.

It's possible for the there to be invalid entries. For example consider this:

```
           8     2
           |     |
 [8, 5, 9, 6, 1, 2, 4, 3, 7],
 [7, 2, 3, 8, 5, 4, 1, 6, 9],
 [1, 6, 4, 3, 7, 9, 5, 2, 8],
 [9, 8, 6, 1, 4, 7, 3, 5, 2],
 [3, 7, 5, 8, 6, 2, 9, 1, 4],
 [2, 4, 1, 5, 9, 3, 7, 8, 6],
 [4, 3, 2, 9, 8, 1, 6, 7, 5],
 [6, 1, 7, 4, 2, 5, 8, 9, 3],
 [5, 9, 8, 7, 3, 6, 2, 4, 1]
```

There are two errors here (indicated above the columns):

```
 [6, 8, 3, 1, 8, 5, 9, 4, 7]
 Error: [8]
 ----------
 [2, 4, 9, 7, 2, 3, 1, 5, 6]
 Error: [2]
```

