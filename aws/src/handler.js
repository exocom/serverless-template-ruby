const {spawn} = require('child_process');

const invoke = (methodName) => {
  return (event, context, cb) => {

    const child  = process.env.IS_LOCAL
        ? spawn('ruby', ['./src/handler.rb', methodName, JSON.stringify(event)])
        : spawn('./src/handler.rb', methodName, [JSON.stringify(event)]);

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (data) => stdout += data.toString());
    child.stderr.on('data', (data) => stderr += data.toString());
    child.on('close',(code) => {
        if (code !== 0) return cb(new Error(`Process exited with non-zero status code: ${code}`));
        if (stderr) console.error(stderr);

        // We expect the child process to output valid JSON with a body
        try {
            const {statusCode, body, headers} = JSON.parse(stdout);
            cb(null, {
                statusCode,
                body: JSON.stringify(body),
                headers
            });
        } catch (error) {
            cb(error);
        }
    });
  };
};

module.exports = new Proxy({}, {
    get: function(target, name) {
        if (!(name in target)) return invoke(name);
    }
});