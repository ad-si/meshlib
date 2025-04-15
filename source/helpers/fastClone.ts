export default function fastClone (object) {
  // Handle string, int, boolean, null or undefined
  if ((object === null) || (typeof object !== 'object')) {
    return object;
  }

  if (Array.isArray(object)) {
    const arrayClone = [];

    for (let index = 0, end = object.length, asc = 0 <= end; asc ? index < end : index > end; asc ? index++ : index--) {
      arrayClone[index] = fastClone(object[index]);
    }

    return arrayClone;
  }


  if (object instanceof Object) {
    const objectClone = {};

    for (var key in object) {
      var value = object[key];
      objectClone[key] = fastClone(value);
    }

    return objectClone;
  }

  throw new Error('Unable to copy object! Its type is not supported.');
};
