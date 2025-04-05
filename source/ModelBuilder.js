import Model from './Model.js'
import stream from 'stream'

export default class ModelBuilder extends stream.Writable {
  constructor(options) {
    if (options == null) { options = {}; }
    super(options);
    this.options = options;
    if (this.options.objectMode == null) { this.options.objectMode = true; }
    this.modelObject = {
      mesh: {
        faces: []
      }
    };

    this.on('finish', function() {
      return this.emit(
        'model',
        Model.fromObject(this.modelObject)
      );
    });
  }

  _write(chunk, _encoding, callback) {
    const data = typeof chunk === 'string' ? JSON.parse(chunk) : chunk;

    if (data.name) {
      this.modelObject.name = data.name;
      if (data.faceCount) {
        this.modelObject.faceCount = data.faceCount;
      }
    }
    else if (data.vertices || data.normal) {
      this.modelObject.mesh.faces.push(data);
    }

    return callback();
  }
}
