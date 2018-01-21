module.exports = (ctx) => {
   return {
     plugins: [
        require('postcss-cssnext')({ browsers: [ 'last 3 versions' ] }),
        require('css-mqpacker')()
     ]
   }
}
