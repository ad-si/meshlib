export default function NoFacesError (message) {
  this.name = 'NoFacesError';
  return this.message = message ||
    'No faces available. Make sure to generate them first.';
};
NoFacesError.prototype = new Error;
