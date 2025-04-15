import stream from 'stream';
import { ReadableOptions } from 'stream';
import { FaceObject } from '@datatypes/face'; // Import FaceObject if available

export interface ModelStreamOptions extends ReadableOptions {
  objectMode?: boolean;
}

// Use a more specific type for the mesh data within the stream object
interface StreamMeshData {
    faces: FaceObject[]; // Use FaceObject type
    // Include faceVertex if it might be present/needed?
}

interface ModelObjectDataForStream {
  name?: string;
  fileName?: string;
  faceCount?: number | string;
  mesh: StreamMeshData;
}

export default class ModelStream extends stream.Readable {
  // Declare properties
  private modelObject: ModelObjectDataForStream; // Use specific type
  private options: ModelStreamOptions;
  private faceIndex: number; // To track reading progress

  constructor(modelObject: ModelObjectDataForStream, options?: ModelStreamOptions) {
    super(options);
    this.modelObject = modelObject;
    if (options == null) { options = {}; }
    this.options = options;
    this.faceIndex = 0; // Initialize index
  }

  _read(): void {
    // Push header only once at the beginning
    if (this.faceIndex === 0) {
        const header = {
          name: this.modelObject.name,
          fileName: this.modelObject.fileName,
          faceCount: this.modelObject.faceCount
        };
        const headerData = this.options.objectMode ? header : JSON.stringify(header) + '\n';
        if (!this.push(headerData)) {
            return; // Stop reading if buffer is full
        }
        // Increment faceIndex after pushing header to avoid pushing it again
        this.faceIndex = -1; // Use -1 to indicate header is pushed
    } else if (this.faceIndex === -1) {
        // Start pushing faces after header
        this.faceIndex = 0;
    }


    // Push faces one by one or in chunks
    const faces = this.modelObject.mesh.faces;
    // Check if faceIndex is within bounds before accessing faces array
    if (this.faceIndex >= 0 && this.faceIndex < faces.length) {
        while (this.faceIndex < faces.length) {
            const face = faces[this.faceIndex];
            const faceData = this.options.objectMode ? face : JSON.stringify(face) + '\n';
            this.faceIndex++;
            if (!this.push(faceData)) {
                return; // Stop reading if buffer is full
            }
        }
    }

    // If all faces are pushed (or if there were no faces), signal the end
    if (this.faceIndex >= faces.length || this.faceIndex === -1) { // Check >= for empty faces case
        this.push(null);
    }
  }
}
