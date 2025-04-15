import yaml from 'js-yaml'
import path from 'path'
import fs from 'fs'
import { fileURLToPath } from 'url'; // Needed for __dirname in ES modules

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const loadYaml = (path: string) => yaml.load(fs.readFileSync(path, 'utf8'));

interface ModelPathObject {
  name: string;
  path: string;
  extension: string;
  filePath?: string;
  load?: () => unknown;
}

const generateMap = (collection: ModelPathObject[]) => collection.reduce(function(previous: Record<string, ModelPathObject>, current, index) {
    previous[current.name] = models[index];
    return previous;
}, {} as Record<string, ModelPathObject>);

const modelPathObjects = loadYaml(path.join(__dirname, './models.yaml')) as ModelPathObject[];

var models = modelPathObjects.map(function(modelPathObject: ModelPathObject) {
  modelPathObject.filePath = path.join(
    __dirname,
    modelPathObject.path + '.' + modelPathObject.extension
  );
  modelPathObject.load = () => loadYaml(modelPathObject.filePath as string);
  return modelPathObject;
});

const modelsMap = generateMap(models);

export default modelsMap;
