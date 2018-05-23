# travis-npm-deploy

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/djanta/travis-npm-deploy/blob/master/LICENSE)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg?style=flat-square)](https://gitter.im/djantajs/tools?utm_source=share-link&utm_medium=link&utm_campaign=share-link)

> Internal platform shared npm deploy script

# Installation
You can clone the repository `travis-npm-deploy` at [git](https://github.com/djanta/travis-npm-deploy.git).

```bash
git clone https://github.com/djanta/travis-npm-deploy.git ~/travis-npm-deploy
```

Once the repository has been cloned and to be able to invoke our provided npm login tool, the `expect` command must be installed. 
To do so, you'll have to run the following command.  

```bash
sh ~/travis-npm-deploy/deploy.sh --install
```

# Usage

## Npm login

```bash
sh ~/travis-npm-deploy/deploy.sh login --user=MyNpmUserName --password=MyNpmUserPassord --email=MyNpmUserEmail
```

## Npm logout

```bash
sh ~/travis-npm-deploy/deploy.sh logout #You pass any mandatory npm arugment here
```

## Npm publish
```bash
sh ~/travis-npm-deploy/deploy.sh #You pass any mandatory npm arugment here
```

# Git Confgiure Usage

```bash
sh ~/travis-npm-deploy/deploy.sh --git-config
```

# Contributing
I welcome any contributions, enhancements, and bug-fixes.  [File an issue](https://github.com/djanta/travis-npm-deploy/issues) on GitHub and [submit a pull request](https://github.com/djanta/travis-npm-deploy/pulls).
