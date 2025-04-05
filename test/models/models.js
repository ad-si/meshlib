import yaml from 'js-yaml'
import path from 'path'
import fs from 'fs'

const __dirname = import.meta.dirname;

const loadYaml = path => yaml.load(fs.readFileSync(path));

const generateMap = collection => collection.reduce(function(previous, current, index) {
    previous[current.name] = models[index];
    return previous;
}
, {});

const modelPathObjects = loadYaml(path.join(__dirname, './models.yaml'));

var models = modelPathObjects.map(function(modelPathObject) {
  modelPathObject.filePath = path.join(
    __dirname,
    modelPathObject.path + '.' + modelPathObject.extension
  );
  modelPathObject.load = () => loadYaml(modelPathObject.filePath);
  return modelPathObject;
});

const modelsMap = generateMap(models);

export default modelsMap;
