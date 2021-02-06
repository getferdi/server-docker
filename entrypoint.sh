#!/bin/sh

echo << EOL
-------------------------------------
          ____           ___
         / __/__ _______/ (_)
        / _// -_) __/ _  / /
      _/_/  \__/_/  \_,_/_/
     / __/__ _____  _____ ____
    _\ \/ -_) __/ |/ / -_) __/
   /___/\__/_/  |___/\__/_/

Brought to you by getferdi.com
Support our Open Collective at:
https://opencollective.com/getferdi/
EOL

node ace migration:run --force

exec node server.js
