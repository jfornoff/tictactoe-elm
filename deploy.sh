#!/bin/sh
elm-app build
git add build
git commit -m "Deploying to Heroku"
git heroku master
