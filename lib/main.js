'use babel';

import path, {delimiter} from 'path';

module.exports = {
  config: {
    path: {
      type: 'string',
      title: 'Path',
      default: '/features',
      description: 'This is the relative path (from your project root) to your projects features directory.'
    }
  }
};

function test(param = 'tom') {
  console.log(param)
};

test();
