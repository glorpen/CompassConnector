========================
Glorpen CompassConnector
========================

When loaded CompassConnector replaces internal compass methods and delegates it to remote process (given by *COMPASS_CONNECTOR* env variable). It allows compass to better match your project requirements.

So, through connector you can scss to support:

- multiple images/css/fonts dir support
- assets in different bundles/modules/plugins (choose one used in your app)
- asset url rewriting from your app

Installation
============

`gem install compass-connector`

Usage
=====

To compile whole project with eg. *zurb-foundation*:

.. sourcecode:: bash

   COMPASS_CONNECTOR=./connector.py ~/.gem/ruby/1.9.1/bin/compass compile -r zurb-foundation -r compass-connector .

Remember to add *compass-connector* as last (`-r`) required library.

Vendor and app paths
====================

Any fonts, images, styles included by other *compass* extensions/plugins should be accesible by single *vendor_path* and *vendor_web*.
Vendor path (in scss files) is a relative path, paths starting with **/** and not schema absolute should be handled by connector.

.. sourcecode:: css

   test {
      app-url: image-url("/my/app/image.png");     /* => /app-assets/my/app/image.png */
      vendor-url: image-url("foundation/image.png");  /* => /vendor/images/foundation/image.png */
   }


Connector
=========

Connectors allow any framework to integrate compass. Example connector can be found in **test_project/connector.py**.

Protocol
********

Any data passed to or from connector is encoded as JSON, communication takes place through pipes.

On compass method call connector will receive following json:

.. sourcecode:: json

   { "method": "some_method", "args": ["arg1","arg2",...] }

and should respond with another JSON data.


Connector should implement following methods:

- `get_configuration`, returns: associative array

Any key/value pair returned will be applied to compass configuration object. Keys prefixed with **:** will be handled as *symbol*. See http://compass-style.org/help/tutorials/configuration-reference/

- `list_main_files`, returns: list of main scss files

Used when compiling whole project (`compass compile /path/to/project`)

- `find_scss(path)`, returns: path to scss files

Should search for scss file in given path, which can be "my_style", "test/_asd" for compass or even "my_app_module:test/asd" if you choose to implement this in your connector

- `get_image_url(path)`
- `find_image(path)`
- `get_font_url(path)`
- `find_font(path)`
- `get_stylesheet_url(path)`

As in *Vendor and app paths* path could be app-path or vendor-path, should handle accordingly.

- `find_generated_image(path)`
- `get_generated_image_url(path)`

Same as in `get_image_url` and others, just one exception - since all generated images are stored in *generated_images_path* there is no vendor path possible.

- `find_sprites_matching(path)`, return list of paths to found sprites

Will recieve path eg. "/assets/my-sprites/\*.png" and should return list of paths to found sprites.

- `find_sprite(path)`, returns path to sprite file

Should return absolute path for given sprite (could be path returned by `find_sprites_matching` or from scss)

