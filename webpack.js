import webpack from 'webpack';
import HappyPack from 'happypack';
import path from 'path';

const BABEL_PLUGINS = [
    'transform-runtime',
    'transform-class-properties',
    'transform-object-rest-spread',
    'syntax-dynamic-import'
];
const FILENAME = '[name].js';

export default (env, modules, includePaths) => {
    let watch = env === 'dev';
    let entries = {};
    let aliases = {};

    modules.forEach((module) => {
        entries[module.name] = path.join(module.relativePath, 'js/index');
        aliases[module.name] = module.relativePath;
    });

    let config = {
        context: __dirname + '/frontend',
        entry: entries,
        output: {
            path: __dirname + '/public/assets/',
            filename: FILENAME,
            library: '[name]',
            publicPath: '/assets/'
        },

        watch: watch,
        watchOptions: {
            aggregateTimeout: 100
        },
        devtool: 'source-map',
        bail: true,

        plugins: [
            new webpack.DefinePlugin({
                'process.env.NODE_ENV': JSON.stringify(env === 'prod' ? 'production' : '')
            }),
            new HappyPack({
                loaders: [{
                    path: 'babel-loader',
                    query: {
                        presets: ['es2015', 'react'],
                        plugins: BABEL_PLUGINS,
                        cacheDirectory: __dirname + '/tmp/babel/'
                    }
                }]
            })
        ],

        resolve: {
            modules: includePaths,
            extensions: ['.js', '.jsx'],
            alias: aliases
        },

        module: {
            rules: [{
                test: /.jsx?$/,
                exclude: /node_modules/,
                loader: 'happypack/loader'
            }]
        }
    };

    if (env !== 'dev') {
        config.plugins.push(
            new webpack.optimize.UglifyJsPlugin({
                compress: {
                    warnings: false,
                    unsafe: true
                }
            })
        );
    }

    return config;
};
