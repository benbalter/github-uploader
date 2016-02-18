***Note: [this is now supported by GitHub natively](https://help.github.com/articles/adding-a-file-to-a-repository/).***

# GitHub Uploader

A simple app to enable drag-and-drop uploading of binary and other assets to GitHub Repositories

[![Build Status](https://travis-ci.org/benbalter/github-uploader.svg)](https://travis-ci.org/benbalter/github-uploader)

## Demo

[Live Demo](https://github-uploader.herokuapp.com/)

## Usage

1. Select a repository
2. Navigate to the target directory
3. Drag and drop the file to upload

## Creating an OAuth application

GitHub Uploader needs a GitHub OAUth application to run. You can create on [in your account or organization's settings](https://github.com/settings/applications/new).

## Deploying

GitHub Uploader works well with Heroku or Cloud Foundry. Simply follow the platform's instructions to create a new application and push the repository. You'll need to set the following environmental variables:

* `GITHUB_CLIENT_SECRET`
* `GITHUB_CLIENT_ID`

## Running locally

You can also run the server yourself. To do so:

1. `script/bootstrap`
2. Create [a new (development) OAuth application](https://github.com/settings/applications/new) and add the `GITHUB_CLIENT_SECRET` and `GITHUB_CLIENT_ID` to a `.env` file in the repository root
3. `script/server`
4. Open [`localhost:9292`](http://localhost:9292) in your browser

## Project Status

Please note this project is a proof of concept, and should not be relied on for mission-critical workflows.

## Contributing

1. Fork the repository
2. Create a descriptively named feature branch
3. Make your changes
4. Submit a pull request

## License

MIT
