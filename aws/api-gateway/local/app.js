const Serverless = require('serverless');

function getProcessedInput(plugin) {
  return {
    commands: [plugin],
    options: {stage: undefined, region: undefined}
  };
}

process.env.SLS_DEBUG = 'true';

const serverless = new Serverless();
serverless.init().then(function () {
  serverless.processedInput = getProcessedInput('local-dev-server');
  serverless.run();
});
