# Meshlib

Meshlib is a JavaScript library for handling mesh based 3D models.


## Installation

As a dependencie in a project:
```sh
npm install --save meshlib
```

As command line tool:
```sh
npm install -g meshlib
```


## Architecture

![System Architecture](img/architecture.png)


## Command Line Interface

```txt
Usage: meshlib <input-file> [options] [output-file]
       meshlib < <jsonl-stream>

JavaScript library for importing, handling & exporting various 3D file formats

Options:

  -h, --help                       output usage information
  -V, --version                    output the version number
  --indent [n]                     Indent JSON output with n (default: 2) spaces or a specified string
  --input [type]                   Set input format
  --no-colors                      Do not color terminal output
  --depth <levels>                 Set depth for printing Javascript objects
  --json                           Print model as JSON (default for non TTY environments)
  --jsonl                          Print model as a newline seperated JSON stream (jsonl)
  --translate <"x y z">            Translate model in x, y, z direction
  --rotate <angleInDegrees>        Rotate model <angleInDegrees>˚ around 0,0
  --transform <transformations>    Transform model with translate(x y z), rotate(angleInDegrees) & scale(x y)
  --apply-matrix <matrix>          Applies 4x4 matrix (provided as list of 16 row-major values)
  --build-face-vertex-mesh         Build a face vertex mesh from faces
  --centering-matrix               Print matrix to center object in x and y direction
  --center                         Center model in x and y direction
  --grid-align-rotation-angle      Print dominant rotation angle relative to the cartesian grid
  --grid-align-rotation-matrix     Print rotation matrix which would align model to the cartesian grid
  --grid-align-rotation-histogram  Print a tsv with the surface area for each rotation angle relative to the cartesian grid
  --apply-grid-align-rotation      Rotate model with its dominant rotation angle relative to the cartesian grid in order to align it to the cartesian grid
  --grid-align-translation         Print translation matrix to align model to the cartesian grid
  --apply-grid-align-translation   Align model to the cartesian grid by translating it in x and y direction
  --auto-align-matrix              Print transformation matrix to rotate, center and align a model to the cartesian grid
  --auto-align                     Automatically rotate, center and align model to the cartesian grid
```
