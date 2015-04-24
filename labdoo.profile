<?php
/**
 * @file
 * Installation steps for the profile labdoo.
 */

// Use functions from the base profile.
require_once(drupal_get_path('profile', 'openatrium') . '/openatrium.profile');

/**
 * Implements hook_appstore_stores_info().
 */
function labdoo_apps_servers_info() {
  // Call the hook of the base profile.
  openatrium_apps_servers_info();
}

/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form.
 *
 * Allows the profile to alter the site configuration form.
 */
function labdoo_form_install_configure_form_alter(&$form, $form_state) {
  // Call the hook of the base profile.
  openatrium_form_install_configure_form_alter($form, $form_state);

  // Pre-populate the site name with the server name.
  $form['site_information']['site_name']['#default_value'] = 'Labdoo';
}

/**
 * Implements hook_form_FORM_ID_alter() for panopoly_theme_selection_form.
 */
function labdoo_form_panopoly_theme_selection_form_alter(&$form, &$form_state, $form_id) {
  // Call the hook of the base profile.
  openatrium_form_panopoly_theme_selection_form_alter($form, $form_state, $form_id);
}

/**
 * Implements hook_features_post_restore().
 */
function labdoo_features_post_restore($op, $items) {
  // Call the hook of the base profile.
  openatrium_features_post_restore($op, $items);
}
