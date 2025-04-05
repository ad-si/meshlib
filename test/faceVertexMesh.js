import chai from 'chai'
const { expect } = chai;

import models from './models/models.js'
import meshlib from '../source/index.js'
import buildFacesFromFaceVertexMesh from '../source/helpers/buildFacesFromFaceVertexMesh.js'


describe('Mesh Transformation', function() {
  it('creates a face-vertex mesh from the list of faces of a tetrahedron', function() {
    const tetrahedronFaces = models['tetrahedron'].load();
    const tetrahedronFaceVertexMesh = models['face-vertex tetrahedron'].load();

    const modelPromise = meshlib(tetrahedronFaces)
      .buildFaceVertexMesh()
      .done(model => buildFacesFromFaceVertexMesh(model.mesh.faceVertex));

    return expect(modelPromise)
      .to.eventually
      .deep.equal(buildFacesFromFaceVertexMesh(tetrahedronFaceVertexMesh));
  });


  it(`creates a face-vertex mesh from the list of faces \
of an irregular tetrahedron`, function() {
    const tetrahedronFaces = models['irregular tetrahedron'].load();
    const tetrahedronFaceVertexMesh =
      models['face-vertex irregular tetrahedron'].load();

    const modelPromise = meshlib(tetrahedronFaces)
      .buildFaceVertexMesh()
      .done(model => buildFacesFromFaceVertexMesh(model.mesh.faceVertex));

    return expect(modelPromise)
      .to.eventually
      .deep.equal(buildFacesFromFaceVertexMesh(tetrahedronFaceVertexMesh));
  });


  return it('creates a face-vertex mesh from the list of faces of a cube', function() {
    const cubeFaces = models['cube'].load();
    const cubeFaceVertexMesh = models['face-vertex cube'].load();

    const modelPromise = meshlib(cubeFaces)
      .buildFaceVertexMesh()
      .done(model => buildFacesFromFaceVertexMesh(model.mesh.faceVertex));

    return expect(modelPromise)
      .to.eventually
      .deep.equal(buildFacesFromFaceVertexMesh(cubeFaceVertexMesh));
  });
});
