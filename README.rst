========================
Glorpen CompassConnector
========================

Simply put - it allows compass to better match your project requirements. This gem is only providing hooks & needed communication for remote connectors.

When loaded CompassConnector replaces internal compass methods and delegates them to another app. Communication is passed through STDOUT/STDIN as JSON. It is up to remote connector to provide needed files/urls.

So, through connector you can make your scss assets support:

- multiple images/css/fonts dir
- assets in different bundles/modules/plugins (choose one used in your app :) )
- asset url routing from your app
- detecting scss file dependencies (inlined fonts, images, @imports)
- loading compass plugins with given version

Official repositories
=====================

For forking and other funnies


BitBucket: https://bitbucket.org/glorpen/compassconnector

GitHub: https://github.com/glorpen/CompassConnector


Remote Connectors
=================

- PHP

  - Assetic: https://bitbucket.org/glorpen/asseticcompassconnector
  - Symfony2: https://bitbucket.org/glorpen/glorpencompassconnectorbundle

- Python

  - webassets: https://bitbucket.org/glorpen/webassets_compassconnector


Installation
============

`gem install compass-connector`


Vendor and app paths nomenclature
=================================

All paths (url, disk path) used in assets are in following categories:

- app - starts with ``@`` (it is ONLY requirement) and is handled by remote application
- vendor - relative paths, should be used only by native compass plugins/extensions
- absolute - absolute paths, starting with eg. ``//``, ``http://``, ``whatever://``, ``/``

Below is example of possible values for given path:

.. sourcecode:: css

   test {
      absolute-url: image-url("/satic/image.png");     /* => /static/image.png */
      vendor-url: image-url("foundation/image.png");  /* => /vendor/images/foundation/image.png */
      app-url: image-url("@SomeSchema:handled:by-remote"); /* => /your/app/SomeSchema/data/handled/by-remote
   }


Connector
=========

Connector allows compass to closely integrate with any framework. Example connector code can be found in **test_project/connector.py**.

Protocol
********

Any data passed to or from connector is encoded as JSON, communication takes place through normal STDOUT/STDIN - so your remote connector needs to filter and respond to data emitted by compass process.

Legend
------

**mode** - string "app" or "vendor" since "absolute" is never passed to remote connector.
**type** - one of "image", "font", "scss", "css", "generated_image", "out_css".
The "css" type is only used for stylesheet url, "out_css" stands for *the* generated css and will be used only for ``put_file`` and ``get_file``. The "scss" type is used only for ``get_file`` when importing other scss files.

**vpath** - a virtual path which is sent to remote connector, it can be relative path or prefixed with ``@``.

Description
-----------

On compass method call connector will receive following json:

.. sourcecode:: json

   { "method": "some_method", "args": ["arg1","arg2",...] }

and should respond with another JSON data.


Connector should implement following methods:

- ``array get_configuration``

  Any key/value pair returned will be applied to compass configuration object. Keys prefixed with **:** will be handled as *symbol*. See http://compass-style.org/help/tutorials/configuration-reference/
  
  Additional keys:
  
  - *plugins* appeared in v0.8 which can be list of plugins to require or array where values should be required version - as in ``gem 'zurb-foundation', '>4'``.
  - *imports* appeared in v0.8.3 which can be list of paths for compass to search for additional files to import.

- ``integer api_version()``

  Version of currently used api - the remote conenctor version must match native conenctor version.

- ``string get_url(vpath, type, mode)``

  Simply returns resolved url for given vpath.

- ``array get_file(vpath, type, mode)``

  Should return associative array with file data or null if file is not found. The returned array consists of: mtime, data (base64 encoded file contents), hash (some *safe* and *unique* value for file, eg. md5 from filename), ext - file extension.
  In case of importing scss files, connector will automatically make requests for _file.scss and file.scss.

- ``boolean put_file(vpath, type, data, mode)``

  Returns true if file was succesfully saved, false otherwise. The data parameter is base64 encoded.

- ``list find_sprites_matching(path, mode)``
  
  Returns list of paths to sprites. method will recieve path eg. "my-sprites/\*.png" and should return list of *virtual paths* to found sprites.

