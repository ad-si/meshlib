import Model from './Model.js';
import stream from 'stream'
import { WritableOptions } from 'stream'
import { ModelObjectData } from './types.js'

interface ModelBuilderOptions extends WritableOptions {
  objectMode?: boolean
  [key: string]: unknown;
}

export default class ModelBuilder extends stream.Writable {
  private options: ModelBuilderOptions
  private modelObject: ModelObjectData;

  constructor(options: ModelBuilderOptions = {}) {
    if (options.objectMode == null) {
      options.objectMode = true
    }
    super(options)
    this.options = options

    this.modelObject = {
      mesh: {
        faces: []
      }
    }

    this.on('finish', () => {
      this.emit('model', Model.fromObject(this.modelObject, this.options))
    })
  }

  _write(
    chunk: string | object,
    _encoding: string,
    callback: (error?: Error) => void
  ) {
    let data: {
      name?: string
      faceCount?: number | string
      vertices?: number[]
      normal?: number[]
    }
    try {
      data = typeof chunk === 'string'
        ? JSON.parse(chunk)
        : chunk
    }
    catch (err) {
      callback(err)
      return
    }

    if (data.name) {
      this.modelObject.name = data.name
      if (data.faceCount) {
        this.modelObject.faceCount = data.faceCount
      }
    }
    else if (data.vertices || data.normal) {
      this.modelObject.mesh.faces.push(data)
    }
    callback()
  }
}
