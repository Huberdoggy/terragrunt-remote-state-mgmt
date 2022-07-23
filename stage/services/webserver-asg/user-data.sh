#!/bin/bash

# Due to comment in main regarding how the 'vars' attribute of 'template_file' works, variables inside of here don't require the 'vars' prefix

cat > index.html <<EOF
<body style="background-color:yellow">
<h1><strong>Hello World from Kyle!</strong></h1>
<p>MySQL Database Address: ${db_address}</p>
<p>MySQL Database Port: ${db_port}</p>
</body>
EOF
# And spin up the webserver on port 8080 as a Bg job...
nohup busybox httpd -fp "${server_port}" &