# GitHub Uploader

A simple app to enable drag-and-drop uploading of binary and other assets to GitHub Repositories

## Demo

[Live Demo](https://github-uploader.herokuapp.com/)

## Usage

1. Select a repository
2. Navigate to the target directory
3. Drag and drop the file to upload

## Server

You can also run the server yourself. To do so:

1. `script/bootstrap`
2. Create [a new OAuth application](https://github.com/settings/applications/new) and add the `GITHUB_CLIENT_SECRET` and `GITHUB_CLIENT_ID` to a `.env` file in the repository root
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
