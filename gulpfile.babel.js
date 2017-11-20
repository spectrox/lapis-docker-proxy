import gulp from 'gulp';
import cssnano from 'gulp-cssnano';
import sass from 'gulp-sass';
import util from 'gulp-util';
import rename from 'gulp-rename';
import webpackStream from 'webpack-stream';
import webpackConfig from './webpack.js';
import path from 'path';
import glob from 'glob';

const ENV = util.env.env || process.env.BUILD_ENV || 'prod';
const DEV_MODE = ENV !== 'prod';

const FRONTEND_DIR = 'frontend';

let includePaths = [
    FRONTEND_DIR,
    'node_modules'
];

let modules = [];

glob.sync(path.join(FRONTEND_DIR, '*')).map((dir) => {
    let module = dir.replace(/^(?:.*\/)([^\/]+)$/, '$1');

    modules.push({
        name: module,
        basePath: dir,
        relativePath: dir.replace(FRONTEND_DIR + '/', '')
    });
});

let assetsPath = 'public/assets/';

gulp.task('default', ['sass', 'webpack']);

if (DEV_MODE) {
    gulp.task('watch', function () {
        gulp.watch(path.join(FRONTEND_DIR, '*/stylesheet/**/*.sass'), ['sass']);
    });

    gulp.task('default', ['sass', 'webpack', 'watch']);
}

gulp.task('sass', () => {
    gulp.src(path.join(FRONTEND_DIR, '*/stylesheet/index.sass'))
        .pipe(sass({
            includePaths: includePaths,
            outputStyle: 'compressed'
        }))
        .on('error', function handleError(error) {
            console.log(error);

            this.emit('end');
        })
        .pipe(cssnano({
            zindex: false
        }))
        .pipe(rename((data) => {
            data.basename = data.dirname.replace(/\/stylesheet$/, '');
            data.dirname = './';
        }))
        .pipe(gulp.dest(assetsPath));
});

gulp.task('webpack', () => {
    let entries = {};

    modules.forEach((module) => {
        entries[module.name] = path.join(module.basePath, 'js/index.js');
    });

    gulp.src(Object.values(entries))
        .pipe(webpackStream(webpackConfig(ENV, modules, includePaths), null, formatWebpackOutput))
        .on('error', function handleError(error) {
            console.log(error);

            this.emit('end');
        })
        .pipe(gulp.dest(assetsPath));
});

function formatWebpackOutput(err, stats) {
    if (err) {
        console.log(err);
        return;
    }

    util.log('[webpack]', stats.toString({
        chunks: false, // Makes the build much quieter
        colors: true
    }));
}
