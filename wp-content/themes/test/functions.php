<?php
function theme_scripts() {
  $scripts = [];
  $styles  = [];

  foreach (glob(get_template_directory() . '/dist/js/*.js') as $script) {
    $file_name   = basename($script);
    $script_name = explode('.', $file_name)[0];

    $scripts[$script_name] = get_template_directory_uri() . '/dist/js/' . $file_name;
  }

  foreach (glob(get_template_directory() . '/dist/css/*.css') as $style) {
    $file_name  = basename($style);
    $style_name = explode('.', $file_name)[0];

    $styles[$style_name] = get_template_directory_uri() . '/dist/css/' . $file_name;
  }

  foreach ($scripts as $name => $path) {
    wp_enqueue_script($name, $path, [], '0.02', true);
  }
  foreach ($styles as $name => $path) {
    wp_enqueue_style($name, $path, [], '0.02');
  }

  wp_dequeue_style('wp-block-library'); // Remove Gutenberg styles
}

add_action('wp_enqueue_scripts', 'theme_scripts', 100);
