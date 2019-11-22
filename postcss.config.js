module.exports = ctx => {
   return {
     plugins: [
       require('postcss-clean'),
       require('postcss-import')({ addDependencyTo: ctx.webpack }),
       require('postcss-custom-properties')(),
       require('postcss-cssnext')({customProperties: true,browsers: ['last 3 versions']}),
       require('postcss-apply'),
       require('css-mqpacker')()
     ]
   };
 };
