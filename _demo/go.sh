#!/bin/bash
docker run -it -p 3000:3000 -v $(pwd)/content/:/home/dan/app/content  -v $(pwd)/orgvolumes/org1:/resources/org1/ -v $(pwd)/orgvolumes/org2:/resources/org2/ -e DEBUG='*' calanais/code-hats