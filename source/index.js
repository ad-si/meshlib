import Model from './Model.js'
import ModelBuilder from './ModelBuilder.js'

const meshlib = (modelData, options) => new Model(modelData, options);

meshlib.Model = Model;

meshlib.ModelBuilder = ModelBuilder;

export default meshlib;
