#!/bin/bash

LMS_URL=edx-docker-fullstack.raccoongang.com
CMS_URL=studio-docker-fullstack.raccoongang.com
PREVIEW_URL=preview-docker-fullstack.raccoongang.com

find -type f -name '*.json' | xargs sed -i 's/edx.fullstack.nginx:18000/'$LMS_URL'/g'
find -type f -name '*.json' | xargs sed -i 's/http:\/\/'$LMS_URL'/https:\/\/'$LMS_URL'/g'
find -type f -name '*.json' | xargs sed -i 's/edx.fullstack.nginx:18010/'$CMS_URL'/g'
find -type f -name '*.json' | xargs sed -i 's/http:\/\/'$CMS_URL'/https:\/\/'$CMS_URL'/g'
find -type f -name '*.json' | xargs sed -i 's/edx.fullstack.preview/'$PREVIEW_URL'/g'

