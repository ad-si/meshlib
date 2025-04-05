import fs from 'fs'
import path from 'path'
import program from 'commander'
import ndjson from 'ndjson'
import meshlib from './index.js'
import packageData from '../package.json' with { type: 'json' }
import yaml from 'js-yaml'

let indent = '\n\t\t\t      ';

function isNumber (obj) {
  return !isNaN(parseFloat(obj))
}

function processModel (model) {
  let modelChain = model;
  indent = null;

  if (program.transform) {
    program.transform.forEach(transformation => modelChain = modelChain[transformation.type]( sp,
            transformation.values
        ));
  }

  if (program.rotate) {
    modelChain = modelChain.rotate({
      angle: program.rotate,
      unit: 'degree'
    });
  }

  if (program.translate) {
    modelChain = modelChain.translate(program.translate);
  }

  if (program.applyMatrix) {
    const listMatrix = program
      .applyMatrix
      .split(/\s/)
      .map(Number)
      .filter(Boolean);

    const matrix = [
      listMatrix.slice(0, 4),
      listMatrix.slice(4, 8),
      listMatrix.slice(8, 12),
      listMatrix.slice(12, 16)
    ];
    modelChain = modelChain.applyMatrix(matrix);
  }

  if (program.buildFaceVertexMesh) {
    modelChain = modelChain.buildFaceVertexMesh();
  }

  if (program.applyGridAlignRotation) {
    modelChain = modelChain
      .calculateNormals()
      .applyGridAlignRotation()
      .calculateNormals();
  }

  if (program.center) {
    modelChain = modelChain.center();
  }

  if (program.applyGridAlignTranslation) {
    modelChain = modelChain
      .calculateNormals()
      .applyGridAlignTranslation();
  }

  if (program.autoAlign) {
    modelChain = modelChain
      .calculateNormals()
      .autoAlign();
  }

  if (program.gridAlignRotationAngle) {
    modelChain = modelChain
      .calculateNormals()
      .getGridAlignRotationAngle({unit: 'degree'})
      .then(console.log);

  } else if (program.gridAlignRotationMatrix) {
    modelChain = modelChain
      .calculateNormals()
      .getGridAlignRotationMatrix()
      .then(console.log);

  } else if (program.gridAlignRotationHistogram) {
    modelChain = modelChain
      .calculateNormals()
      .getGridAlignRotationHistogram()
      .then(console.log);

  } else if (program.gridAlignTranslation) {
    modelChain = modelChain
      .calculateNormals()
      .getGridAlignTranslationMatrix()
      .then(console.log);

  } else if (program.centeringMatrix) {
    modelChain = modelChain
      .getCenteringMatrix()
      .then(console.log);

  } else if (program.autoAlignMatrix) {
    modelChain = modelChain
      .calculateNormals()
      .getAutoAlignMatrix()
      .then(console.log);

  } else if (program.jsonl) {
    modelChain = modelChain
      .getStream({objectMode: false}) 
      .then(modelStream => modelStream.pipe(process.stdout));

  } else if (process.stdout.isTTY && !program.json) {
    modelChain = modelChain
      .getObject()
      .then(modelObject => console.dir(modelObject, {
            depth: Number(program.depth) || null,
            colors: program.colors
        }));

  } else {
    if (program.indent === true) {
      indent = 2;

    } else if (isNumber(program.indent)) {
      indent = Number(program.indent);

    } else if (program.indent) {
      ({
                indent
            } = program);
    }

    modelChain = modelChain
      .getJSON(null, indent)
      .then(console.log);
  }

  return modelChain = modelChain
    .catch(error => console.error(error.stack));
};


export default function(commandLineArguments) {
  program
    .version(packageData.version)
    .description(packageData.description)
    .option(
      '--indent [n]',
      `Indent JSON output with n (default: 2) spaces \
or a specified string`
    )
    .option(
      '--input [type]',
      'Set input format'
    )
    .option('--no-colors', 'Do not color terminal output')
    .option('--depth <levels>', 'Set depth for printing Javascript objects')
    .option(
      '--json',
      'Print model as JSON (default for non TTY environments)'
    )
    .option(
      '--jsonl',
      'Print model as a newline seperated JSON stream (jsonl)'
    )
    .option(
      '--translate <"x y z">',
      'Translate model in x, y, z direction',
      string => string
                .split(' ')
                .map(numberString => Number(numberString)))
    .option(
      '--rotate <angleInDegrees>',
      'Rotate model <angleInDegrees>˚ around 0,0'
    )
    .option(
      '--transform <transformations>',
      `Transform model with translate(x y z), \
rotate(angleInDegrees) & scale(x y)`,
      string => string
                .split(')')
                .slice(0, -1)
                .map(function(transformationString) {
                    const subStrings = transformationString.split('(');
                    const transformation = subStrings[0].trim();
                    let values = subStrings[1].split(' ');

                    if (transformation === 'rotate') {
                        values = {
                            angle: values,
                            unit: 'degree'
                        };
                    }

                    return {
                        type: transformation,
                        values
                    };}))
    .option(
      '--apply-matrix <matrix>',
      'Applies 4x4 matrix (provided as list of 16 row-major values)'
    )
    .option(
      '--build-face-vertex-mesh',
      'Build a face vertex mesh from faces'
    )
    .option(
      '--centering-matrix',
      'Print matrix to center object in x and y direction'
    )
    .option(
      '--center',
      'Center model in x and y direction'
    )
    .option(`\
--grid-align-rotation-angle`,
      'Print dominant rotation angle relative to the cartesian grid'
    )
    .option(
      '--grid-align-rotation-matrix',
      `Print rotation matrix which would align model \
to the cartesian grid`
    )
    .option(
      '--grid-align-rotation-histogram',
      `Print a tsv with the surface area for each rotation angle \
relative to the cartesian grid`
    )
    .option(
      '--apply-grid-align-rotation',
      `Rotate model with its dominant rotation angle \
relative to the cartesian grid \
in order to align it to the cartesian grid`
    )
    .option(
      '--grid-align-translation',
      'Print translation matrix to align model to the cartesian grid'
    )
    .option(
      '--apply-grid-align-translation',
      `Align model to the cartesian grid by translating it \
in x and y direction`
    )
    .option(
      '--auto-align-matrix',
      `Print transformation matrix to rotate, center and align a model \
to the cartesian grid`
    )
    .option(
      '--auto-align',
      'Automatically rotate, center and align model to the cartesian grid'
    )
    .usage(`<input-file> [options] [output-file] \
\n         <jsonl-stream> \
| ${path.basename(commandLineArguments[0])}`).arguments('<input-file> [output-file]')
    .parse(commandLineArguments);


  if (process.stdin.isTTY) {
    if (program.args.length < 1) {
      program.help();
      return process.exit(1);
    }

    if (program.input === 'base64') {
      return fs.readFile(path.resolve(program.args[0]), function(error, fileBuffer) {
        if (error) {
          throw error;
        }

        return meshlib.Model
          .fromBase64(fileBuffer.toString())
          .buildFacesFromFaceVertexMesh()
          .getStream()
          .then(modelStream => modelStream.pipe(process.stdout));
      });

    } else {
      return fs.readFile(path.resolve(program.args[0]), function(error, fileBuffer) {
        if (error) {
          throw error;
        }

        const fileContent =
          /.*(yaml|yml)$/gi.test(program.args[0])
          ? yaml.load(fileBuffer)
          : JSON.parse(fileBuffer);

        return meshlib({faces: fileContent.faces})
          .getObject()
          .then(function(model) {

            if (program.args[1]) {
              const outputFilePath = path.join(
                process.cwd(),
                program.args.pop()
              );

              fs.writeFileSync(
                outputFilePath,
                JSON.stringify(model)
              );

            } else {
              console.log(JSON.stringify(model));
            }

            return process.exit(0);}).catch(function(error) {
            console.error(error.stack);
            return process.exit(1);
        });
      });
    }


  } else {
    const modelBuilder = new meshlib.ModelBuilder();

    modelBuilder
      .on('model', processModel)
      .on('error', function(error) {
        console.error(error.stack);
        return process.exit(1);
    });

    process.stdin.setEncoding('utf-8');
    return process.stdin
      .pipe(ndjson.parse({strict: false}))
      .pipe(modelBuilder);
  }
};
