export default class NoFacesError extends Error {
  constructor(message?: string) {
    super(message || 'No faces available. Make sure to generate them first.');
    this.name = 'NoFacesError';
  }
}
