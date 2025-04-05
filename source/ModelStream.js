import stream from 'stream'

export default class ModelStream extends stream.Readable {
  constructor(modelObject, options) {
    super(options);
    this.modelObject = modelObject;
    if (options == null) { options = {}; }
    this.options = options;
    if (this.options.objectMode == null) { this.options.objectMode = false; }
  }

  _read() {
    const header = {
      name: this.modelObject.name,
      fileName: this.modelObject.fileName,
      faceCount: this.modelObject.faceCount
    };

    // In objectMode push objects, otherwise strings
    if (this.options.objectMode) {
      this.push(header);

      this.modelObject.mesh.faces
      .forEach(face => {
        return this.push(face);
      });

    }
    else {
      this.push(JSON.stringify(header) + '\n');

      this.modelObject.mesh.faces
      .forEach(face => {
        return this.push(JSON.stringify(face) + '\n');
      });
    }

    return this.push(null);
  }
}
