<?php
function theme_scripts() {
    $assets = array(
        'css'       => '/dist/style.min.css',
        'js'        => '/dist/scripts.min.js',
    );

    wp_enqueue_style('theme_css', get_template_directory_uri() . $assets['css'], array(), '0.01');
    wp_enqueue_script('theme_js', get_template_directory_uri() . $assets['js'], array('jquery'), '0.01', true);
}

add_action('wp_enqueue_scripts', 'theme_scripts', 100);
