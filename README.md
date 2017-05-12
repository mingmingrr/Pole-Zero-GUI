# Pole-Zero-GUI

A GUI for creating disctrete-time FIR filters based on poles and zeros. 
Inspired by the MatLab PoleZeroPlace3D GUI from the SPFirst toolbox.

## Getting Started

Fetch the latest release from the 
[releases page](https://github.com/mingmingrr/Pole-Zero-GUI/releases). 
Once it is downloaded, extract the contents and run `index.html`.

## Building

You will need [Node.js](https://nodejs.org) along with 
[npm](https://www.npmjs.com).

Run the following commands to clone the repo, install dependencies, 
and build the GUI:

```shell
git clone https://github.com/mingmingrr/Pole-Zero-GUI.git
cd Pole-Zero-GUI
npm install --dev
make release
```

The files will automatically be placed into the `releases` folder.

## Tests

Run the following commands to compile the tests and autoatically run them with 
Mocha:

```shell
make test
```

## License

This project is licensed under the MIT License - see the 
[LICENSE.md](LICENSE.md) file for details

