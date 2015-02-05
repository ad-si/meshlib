// Generated by CoffeeScript 1.9.0
(function() {
  var Ascii, Binary, FacetError, FileError, NormalError, Poly, Stl, Vec3, VertexError, optimizeModel, parseAscii, parseBinary, textEncoding;

  require('string.prototype.startswith');

  require('string.prototype.includes');

  textEncoding = require('text-encoding');

  Vec3 = require('./Vector');

  optimizeModel = require('./optimizeModel');

  FileError = function(message, calcDataLength, dataLength) {
    this.name = 'FileError';
    return this.message = message || ("Calculated length of " + calcDataLength + " does not match specified file-size of " + dataLength + ". Triangles might be missing!");
  };

  FileError.prototype = new Error;

  FacetError = function(message) {
    this.name = 'FacetError';
    return this.message = message || 'Previous facet was not completed!';
  };

  FacetError.prototype = new Error;

  NormalError = function(message) {
    this.name = 'NormalError';
    return this.message = message || ("Invalid normal definition: (" + nx + ", " + ny + ", " + nz + ")");
  };

  NormalError.prototype = new Error;

  VertexError = function(message) {
    this.name = 'VertexError';
    return this.message = message || ("Invalid vertex definition: (" + nx + ", " + ny + ", " + nz + ")");
  };

  VertexError.prototype = new Error;

  parseAscii = function(fileContent) {
    var astl, cmd, currentPoly, nx, ny, nz, stl, vx, vy, vz;
    astl = new Ascii(fileContent);
    stl = new Binary();
    currentPoly = null;
    while (!astl.reachedEnd()) {
      cmd = astl.nextText();
      cmd = cmd.toLowerCase();
      switch (cmd) {
        case 'solid':
          astl.nextText();
          break;
        case 'facet':
          if ((currentPoly != null)) {
            throw new FacetError;
            stl.addPolygon(currentPoly);
            currentPoly = null;
          }
          currentPoly = new Poly();
          break;
        case 'endfacet':
          if (!(currentPoly != null)) {
            throw new FacetError('Facet was ended without beginning it!');
          } else {
            stl.addPolygon(currentPoly);
            currentPoly = null;
          }
          break;
        case 'normal':
          nx = parseFloat(astl.nextText());
          ny = parseFloat(astl.nextText());
          nz = parseFloat(astl.nextText());
          if (!(nx != null) || !(ny != null) || !(nz != null)) {
            throw new NormalError;
          } else {
            if (!(currentPoly != null)) {
              throw new NormalError('Normal definition without an existing polygon!');
              currentPoly = new Poly();
            }
            currentPoly.setNormal(new Vec3(nx, ny, nz));
          }
          break;
        case 'vertex':
          vx = parseFloat(astl.nextText());
          vy = parseFloat(astl.nextText());
          vz = parseFloat(astl.nextText());
          if (!(vx != null) || !(vy != null) || !(vz != null)) {
            throw new VertexError;
          } else {
            if (!(currentPoly != null)) {
              throw new VertexError('Point definition without an existing polygon!');
              currentPoly = new Poly();
            }
            currentPoly.addPoint(new Vec3(vx, vy, vz));
          }
      }
    }
    return stl;
  };

  parseBinary = function(stlBuffer) {
    var binaryIndex, calcDataLength, dataLength, i, numTriangles, nx, ny, nz, poly, polyLength, reader, stl, vx, vy, vz, _i;
    stl = new Binary();
    reader = new DataView(stlBuffer, 80);
    numTriangles = reader.getUint32(0, true);
    dataLength = stlBuffer.byteLength - 80 - 4;
    polyLength = 50;
    calcDataLength = polyLength * numTriangles;
    if (calcDataLength > dataLength) {
      throw new FileError(null, calcDataLength, dataLength);
    }
    binaryIndex = 4;
    while ((binaryIndex - 4) + polyLength <= dataLength) {
      poly = new Poly();
      nx = reader.getFloat32(binaryIndex, true);
      binaryIndex += 4;
      ny = reader.getFloat32(binaryIndex, true);
      binaryIndex += 4;
      nz = reader.getFloat32(binaryIndex, true);
      binaryIndex += 4;
      poly.setNormal(new Vec3(nx, ny, nz));
      for (i = _i = 0; _i <= 2; i = ++_i) {
        vx = reader.getFloat32(binaryIndex, true);
        binaryIndex += 4;
        vy = reader.getFloat32(binaryIndex, true);
        binaryIndex += 4;
        vz = reader.getFloat32(binaryIndex, true);
        binaryIndex += 4;
        poly.addPoint(new Vec3(vx, vy, vz));
      }
      binaryIndex += 2;
      stl.addPolygon(poly);
    }
    return stl;
  };

  Ascii = (function() {
    var skipWhitespaces, whitespaces;

    whitespaces = [' ', '\r', '\n', '\t', '\v', '\f'];

    skipWhitespaces = function() {
      var skip, _results;
      skip = true;
      _results = [];
      while (skip) {
        if (this.currentCharIsWhitespace() && !this.reachedEnd()) {
          _results.push(this.index++);
        } else {
          _results.push(skip = false);
        }
      }
      return _results;
    };

    function Ascii(fileContent) {
      this.content = fileContent;
      this.index = 0;
    }

    Ascii.prototype.nextText = function() {
      skipWhitespaces.call(this);
      return this.readUntilWhitespace();
    };

    Ascii.prototype.currentChar = function() {
      return this.content[this.index];
    };

    Ascii.prototype.currentCharIsWhitespace = function() {
      var space, _i, _len;
      for (_i = 0, _len = whitespaces.length; _i < _len; _i++) {
        space = whitespaces[_i];
        if (this.currentChar() === space) {
          return true;
        }
      }
      return false;
    };

    Ascii.prototype.readUntilWhitespace = function() {
      var readContent;
      readContent = '';
      while (!this.currentCharIsWhitespace() && !this.reachedEnd()) {
        readContent = readContent + this.currentChar();
        this.index++;
      }
      return readContent;
    };

    Ascii.prototype.reachedEnd = function() {
      return this.index === this.content.length;
    };

    return Ascii;

  })();

  Binary = (function() {
    function Binary() {
      this.polygons = [];
      this.importErrors = [];
    }

    Binary.prototype.addPolygon = function(stlPolygon) {
      return this.polygons.push(stlPolygon);
    };

    Binary.prototype.addError = function(string) {
      return this.importErrors.push(string);
    };

    Binary.prototype.removeInvalidPolygons = function(infoResult) {
      var deletedPolys, newPolys, poly, _i, _len, _ref;
      newPolys = [];
      deletedPolys = 0;
      _ref = this.polygons;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        poly = _ref[_i];
        if (poly.points.length === 3) {
          newPolys.push(poly);
        }
      }
      if (infoResult) {
        deletedPolys = this.polygons.length - newPolys.length;
      }
      this.polygons = newPolys;
      return deletedPolys;
    };

    Binary.prototype.recalculateNormals = function(infoResult) {
      var d1, d2, dist, n, newNormals, poly, _i, _len, _ref;
      newNormals = 0;
      _ref = this.polygons;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        poly = _ref[_i];
        d1 = poly.points[1].minus(poly.points[0]);
        d2 = poly.points[2].minus(poly.points[0]);
        n = d1.crossProduct(d2);
        n = n.normalized();
        if (infoResult) {
          if (poly.normal != null) {
            dist = poly.normal.euclideanDistanceTo(n);
            if (dist > 0.001) {
              newNormals++;
            }
          } else {
            newNormals++;
          }
        }
        poly.normal = n;
      }
      return newNormals;
    };

    Binary.prototype.cleanse = function(infoResult) {
      var result;
      if (infoResult == null) {
        infoResult = false;
      }
      result = {};
      result.deletedPolygons = this.removeInvalidPolygons(infoResult);
      result.recalculatedNormals = this.recalculateNormals(infoResult);
      return result;
    };

    return Binary;

  })();

  Poly = (function() {
    function Poly() {
      this.points = [];
      this.normal = new Vec3(0, 0, 0);
    }

    Poly.prototype.setNormal = function(_at_normal) {
      this.normal = _at_normal;
      return void 0;
    };

    Poly.prototype.addPoint = function(p) {
      return this.points.push(p);
    };

    return Poly;

  })();

  Stl = (function() {
    function Stl(stlBuffer, options) {
      var error, stlString;
      this.modelObject = {};
      if (options == null) {
        options = {};
      }
      if (options.optimize == null) {
        options.optimize = true;
      }
      if (options.cleanse == null) {
        options.cleanse = true;
      }
      if (Buffer) {
        stlString = new Buffer(new Uint8Array(stlBuffer)).toString();
      } else {
        stlString = textEncoding.TextDecoder('utf-8').decode(new Uint8Array(stlBuffer));
      }
      if (stlString.startsWith('solid') && stlString.includes('facet') && stlString.includes('vertex')) {
        try {
          this.modelObject = parseAscii(stlString);
        } catch (_error) {
          error = _error;
          console.error(error);
          this.modelObject = parseBinary(stlBuffer);
        }
      } else {
        this.modelObject = parseBinary(stlBuffer);
      }
      if (options.optimize) {
        this.modelObject = optimizeModel(this.modelObject, options);
      }
    }

    Stl.prototype.model = function() {
      return this.modelObject;
    };

    return Stl;

  })();

  module.exports = Stl;

}).call(this);