module.exports = function(config) {
    config.set({
        frameworks: ['mocha', 'sinon', 'chai'],
        browsers: ['PhantomJS'],
        preprocessors: {'**/*.coffee': 'coffee'},
        singleRun: true,
        reporters: [
            'dots'
        ],
        files: [
            './lib/*.coffee',
            './spec/javascripts/*.coffee'
        ]
    });
};
