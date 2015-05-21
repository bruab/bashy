// Generated by CoffeeScript 1.9.1
(function() {
  var BashyGame, BashyOS, Directory, DisplayManager, File, FileSystem, Man, Task, TaskManager, Terminal,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Man = (function() {
    function Man() {
      this.entries = {
        "cd": "This command moves you around.\n" + "Type 'cd /' to go to the top.\n" + "Type 'cd' by itself to go home.\n" + "Type 'cd ..' to go up one level.",
        "pwd": "This command gives your location.\n" + "(Technically, it gives  the path\n" + "to your current working directory.)",
        "man": "This command gives instructions\n" + "on how commands work.\n" + "Type 'man cd' to learn about the\n" + "'cd' command"
      };
    }

    Man.prototype.getEntry = function(command) {
      var ref, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      if (command in this.entries) {
        stdout = this.entries[command];
      } else {
        stderr = "No manual entry for " + command;
      }
      return [stdout, stderr];
    };

    return Man;

  })();

  File = (function() {
    function File(name1, contents) {
      this.name = name1;
      this.contents = contents;
    }

    return File;

  })();

  Directory = (function() {
    function Directory(path1) {
      this.path = path1;
      this.subdirectories = [];
      this.files = [];
    }

    Directory.prototype.name = function() {
      var len, splitPath;
      if (this.path === "/") {
        return this.path;
      } else {
        splitPath = this.path.split("/");
        len = splitPath.length;
        return splitPath[len - 1];
      }
    };

    Directory.prototype.toString = function() {
      return "Directory object with path=" + this.path;
    };

    Directory.prototype.getChild = function(name) {
      var child, j, len1, ref;
      ref = this.subdirectories;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        child = ref[j];
        if (child.name() === name) {
          return child;
        }
      }
      return "";
    };

    return Directory;

  })();

  FileSystem = (function() {
    function FileSystem() {
      var bashy, foo, home, list, media, pics;
      this.root = new Directory("/");
      media = new Directory("/media");
      pics = new Directory("/media/pics");
      media.subdirectories.push(pics);
      this.root.subdirectories.push(media);
      home = new Directory("/home");
      bashy = new Directory("/home/bashy");
      foo = new File("foo.txt", "This is a simple text file.");
      list = new File("list", "1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20");
      bashy.files.push(list);
      bashy.files.push(foo);
      home.subdirectories.push(bashy);
      this.root.subdirectories.push(home);
    }

    FileSystem.prototype.isValidDirectoryPath = function(path) {
      var currentParent, dir, dirName, j, len1, ref, splitPath;
      if (path === "/") {
        return true;
      }
      splitPath = path.split("/");
      currentParent = this.root;
      ref = splitPath.slice(1);
      for (j = 0, len1 = ref.length; j < len1; j++) {
        dirName = ref[j];
        dir = currentParent.getChild(dirName);
        if (!dir) {
          return false;
        } else {
          currentParent = dir;
        }
      }
      return true;
    };

    FileSystem.prototype.isValidFilePath = function(path) {
      var currentParent, dir, dirName, file, filename, j, k, len, len1, len2, ref, ref1, splitPath;
      if (path === "/") {
        return true;
      }
      splitPath = path.split("/");
      len = splitPath.length;
      currentParent = this.root;
      ref = splitPath.slice(1, +(len - 2) + 1 || 9e9);
      for (j = 0, len1 = ref.length; j < len1; j++) {
        dirName = ref[j];
        dir = currentParent.getChild(dirName);
        if (!dir) {
          return false;
        } else {
          currentParent = dir;
        }
      }
      filename = splitPath[len - 1];
      ref1 = currentParent.files;
      for (k = 0, len2 = ref1.length; k < len2; k++) {
        file = ref1[k];
        if (file.name === filename) {
          return true;
        }
      }
      return false;
    };

    FileSystem.prototype.splitPath = function(path) {
      var dirPath, filename, len, splitPath;
      splitPath = path.split("/");
      len = splitPath.length;
      filename = splitPath[len - 1];
      dirPath = splitPath.slice(0, +(len - 2) + 1 || 9e9).join("/");
      return [dirPath, filename];
    };

    FileSystem.prototype.getDirectory = function(path) {
      var currentParent, dirName, j, len1, ref, splitPath;
      if (path === "/") {
        return this.root;
      }
      currentParent = this.root;
      splitPath = path.split("/");
      ref = splitPath.slice(1);
      for (j = 0, len1 = ref.length; j < len1; j++) {
        dirName = ref[j];
        currentParent = currentParent.getChild(dirName);
      }
      return currentParent;
    };

    FileSystem.prototype.getFile = function(path) {
      var dir, dirPath, file, filename, j, len1, ref, ref1;
      ref = this.splitPath(path), dirPath = ref[0], filename = ref[1];
      dir = this.getDirectory(dirPath);
      ref1 = dir.files;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        file = ref1[j];
        if (file.name === filename) {
          return file;
        }
      }
    };

    return FileSystem;

  })();

  BashyOS = (function() {
    function BashyOS() {
      this.pwd = bind(this.pwd, this);
      this.cd = bind(this.cd, this);
      this.runCommand = bind(this.runCommand, this);
      this.validCommands = ["man", "cd", "pwd", "ls", "cat", "head", "tail"];
      this.fileSystem = new FileSystem();
      this.cwd = this.fileSystem.root;
      this.man = new Man();
    }

    BashyOS.prototype.runCommand = function(command, args) {
      var ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      if (indexOf.call(this.validCommands, command) < 0) {
        stderr = "Invalid command: " + command;
      } else if (command === 'man') {
        ref1 = this.man.getEntry(args[0]), stdout = ref1[0], stderr = ref1[1];
      } else if (command === 'cd') {
        ref2 = this.cd(args), stdout = ref2[0], stderr = ref2[1];
      } else if (command === 'pwd') {
        ref3 = this.pwd(), stdout = ref3[0], stderr = ref3[1];
      } else if (command === 'ls') {
        ref4 = this.ls(args[0]), stdout = ref4[0], stderr = ref4[1];
      } else if (command === 'cat') {
        ref5 = this.cat(args[0]), stdout = ref5[0], stderr = ref5[1];
      } else if (command === 'head') {
        ref6 = this.head(args[0]), stdout = ref6[0], stderr = ref6[1];
      } else if (command === 'tail') {
        ref7 = this.tail(args[0]), stdout = ref7[0], stderr = ref7[1];
      }
      return [this.cwd.path, stdout, stderr];
    };

    BashyOS.prototype.cd = function(args) {
      var path, ref, stderr, stdout, targetDirectory;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      if (args.length === 0) {
        this.cwd = this.fileSystem.getDirectory("/home");
      } else {
        path = args[0];
        targetDirectory = this.getDirectoryFromPath(path);
        if (targetDirectory != null) {
          this.cwd = targetDirectory;
        } else {
          stderr = "Invalid path: " + path;
        }
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.pwd = function() {
      var ref, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      stdout = this.cwd.path;
      return [stdout, stderr];
    };

    BashyOS.prototype.ls = function(path) {
      var dir, directory, file, j, k, len1, len2, ref, ref1, ref2, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      if (path == null) {
        dir = this.cwd;
      } else {
        dir = this.getDirectoryFromPath(path);
      }
      if (dir == null) {
        stderr = "ls: " + path + ": No such file or directory";
      } else {
        ref1 = dir.files;
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          file = ref1[j];
          stdout += file.name + "\t";
        }
        ref2 = dir.subdirectories;
        for (k = 0, len2 = ref2.length; k < len2; k++) {
          directory = ref2[k];
          stdout += directory.name() + "\t";
        }
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.cat = function(path) {
      var file, ref, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      file = this.getFileFromPath(path);
      if (!file) {
        stderr = "cat: " + path + ": No such file or directory";
      } else {
        stdout = file.contents;
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.head = function(path) {
      var file, numberOfLines, ref, splitContents, stderr, stdout;
      numberOfLines = 10;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      file = this.getFileFromPath(path);
      if (!file) {
        stderr = "head: " + path + ": No such file or directory";
      } else {
        splitContents = file.contents.split("\n");
        stdout = splitContents.slice(0, +(numberOfLines - 1) + 1 || 9e9).join("\n");
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.tail = function(path) {
      var file, numberOfLines, ref, splitContents, stderr, stdout, totalLines;
      numberOfLines = 10;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      file = this.getFileFromPath(path);
      if (!file) {
        stderr = "tail: " + path + ": No such file or directory";
      } else {
        splitContents = file.contents.split("\n");
        totalLines = splitContents.length;
        stdout = splitContents.slice(totalLines - numberOfLines).join("\n");
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.cleanPath = function(path) {
      path = path.replace(/\/+/g, "/");
      path = path.replace(/\/$/, "");
      return path;
    };

    BashyOS.prototype.getParentPath = function(path) {
      var i, j, len, parentPath, ref, splitPath;
      if (path === "/") {
        return "/";
      } else {
        splitPath = path.split("/");
        len = splitPath.length;
        parentPath = "";
        for (i = j = 0, ref = len - 2; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          parentPath = parentPath + "/" + splitPath[i];
        }
        return this.cleanPath(parentPath);
      }
    };

    BashyOS.prototype.getDirectoryFromPath = function(path) {
      if (this.isRelativePath(path)) {
        path = this.parseRelativePath(path);
        path = this.cleanPath(path);
      }
      if (this.fileSystem.isValidDirectoryPath(path)) {
        return this.fileSystem.getDirectory(path);
      } else {
        return null;
      }
    };

    BashyOS.prototype.getFileFromPath = function(path) {
      path = this.cleanPath(path);
      if (this.isRelativePath(path)) {
        path = this.parseRelativePath(path);
        path = this.cleanPath(path);
      }
      if (this.fileSystem.isValidFilePath(path)) {
        return this.fileSystem.getFile(path);
      } else {
        return null;
      }
    };

    BashyOS.prototype.isRelativePath = function(path) {
      if (path[0] === "/") {
        return false;
      } else {
        return true;
      }
    };

    BashyOS.prototype.parseRelativePath = function(relativePath) {
      var cwd, dir, fields, finished, newPath;
      cwd = this.cwd.path;
      if (relativePath === "..") {
        newPath = this.getParentPath(cwd);
        return newPath;
      }
      fields = relativePath.split("/");
      finished = false;
      while (!finished) {
        if (fields.length === 1) {
          finished = true;
        }
        dir = fields[0];
        if (dir === ".") {
          fields = fields.slice(1, +fields.length + 1 || 9e9);
          continue;
        } else if (dir === "..") {
          cwd = this.getParentPath(cwd);
        } else {
          cwd = cwd + "/" + dir;
        }
        fields = fields.slice(1, +fields.length + 1 || 9e9);
      }
      return cwd;
    };

    return BashyOS;

  })();

  Terminal = (function() {
    function Terminal(callback) {
      $('#terminal').terminal(callback, {
        greetings: "",
        prompt: '$ ',
        onBlur: false,
        name: 'bashyTerminal'
      });
    }

    return Terminal;

  })();

  TaskManager = (function() {
    function TaskManager() {
      this.winner = false;
      this.tasks = this.getTasks();
      this.currentTask = this.tasks[0];
      this.showTask(this.currentTask);
    }

    TaskManager.prototype.update = function(os) {
      if (!this.winner) {
        if (this.currentTask.done(os)) {
          if (this.tasks.length > 1) {
            this.tasks = this.tasks.slice(1);
            this.currentTask = this.tasks[0];
            this.showTask(this.currentTask);
          } else {
            this.winner = true;
            this.win();
          }
        }
      }
    };

    TaskManager.prototype.showTask = function(task) {
      $("#menu").html(task.name);
    };

    TaskManager.prototype.win = function() {
      $("#menuHeader").html("");
      $("#menu").html("<h4>You Win!</h4>");
    };

    TaskManager.prototype.getTasks = function() {
      var task1, task1Function, task2, task2Function, task3, task3Function;
      task1Function = function(os) {
        return os.cwd.path === "/home";
      };
      task2Function = function(os) {
        return os.cwd.path === "/media";
      };
      task3Function = function(os) {
        return os.cwd.path === "/";
      };
      task1 = new Task("navigate to home", ["type 'cd' and press enter"], task1Function);
      task2 = new Task("navigate to /media", ["type 'cd /media' and press enter"], task2Function);
      task3 = new Task("navigate to root", ["type 'cd /' and press enter"], task3Function);
      return [task1, task2, task3];
    };

    return TaskManager;

  })();

  Task = (function() {
    function Task(name1, hints, completeFunction) {
      this.name = name1;
      this.hints = hints;
      this.completeFunction = completeFunction;
      this.isComplete = false;
    }

    Task.prototype.done = function(os) {
      if (this.isComplete) {
        return true;
      } else {
        this.isComplete = this.completeFunction(os);
        return this.isComplete;
      }
    };

    Task.prototype.toString = function() {
      return this.name;
    };

    return Task;

  })();

  DisplayManager = (function() {
    function DisplayManager() {
      this.update = bind(this.update, this);
      var canvas;
      canvas = $("#bashyCanvas")[0];
      this.stage = new createjs.Stage(canvas);
      this.initializeMap();
      this.initializeSprite();
      return;
    }

    DisplayManager.prototype.initializeMap = function() {
      var ref, ref1;
      ref = [130, 60], this.startingX = ref[0], this.startingY = ref[1];
      this.centeredOn = "/";
      this.map = new createjs.Container();
      this.map.name = "map";
      ref1 = [this.startingX, this.startingY], this.map.x = ref1[0], this.map.y = ref1[1];
    };

    DisplayManager.prototype.initializeSprite = function() {
      var bashyImage;
      bashyImage = new Image();
      bashyImage.onload = (function(_this) {
        return function() {
          return _this.spriteSheetLoaded(bashyImage);
        };
      })(this);
      bashyImage.src = "assets/bashy_sprite_sheet.png";
    };

    DisplayManager.prototype.spriteSheetLoaded = function(image) {
      this.bashySprite = this.createBashySprite(image, this.stage);
      this.startTicker(this.stage);
    };

    DisplayManager.prototype.update = function(fs, newDir) {
      var deltaX, deltaY, newX, newY, oldX, oldY, ref, ref1, ref2;
      ref = this.getCoordinatesForPath(this.centeredOn), oldX = ref[0], oldY = ref[1];
      ref1 = this.getCoordinatesForPath(newDir), newX = ref1[0], newY = ref1[1];
      ref2 = [oldX - newX, oldY - newY], deltaX = ref2[0], deltaY = ref2[1];
      createjs.Tween.get(this.map).to({
        x: this.map.x + deltaX,
        y: this.map.y + deltaY
      }, 500, createjs.Ease.getPowInOut(2));
      this.centeredOn = newDir;
    };

    DisplayManager.prototype.getCoordinatesForPath = function(path) {
      var item, j, len1, ref;
      ref = this.map.children;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        item = ref[j];
        if (item.name === path) {
          return [item.x, item.y];
        }
      }
    };

    DisplayManager.prototype.drawFileSystem = function(fs) {
      this.drawFile(this.map, fs.root, this.map.x, this.map.y);
      this.drawChildren(this.map, fs.root, this.map.x, this.map.y);
      this.stage.addChild(this.map);
    };

    DisplayManager.prototype.helpScreen = function(hint) {
      var helpHtml;
      helpHtml = "<h3>B@shy Help</h3>";
      helpHtml += "<p>Hint: " + hint + "</p>";
      $('#helpText').html(helpHtml);
      $('#helpScreen').foundation('reveal', 'open');
    };

    DisplayManager.prototype.createBashySprite = function(image) {
      var SPRITEX, SPRITEY, bashySpriteSheet, ref, sprite;
      ref = [200, 50], SPRITEX = ref[0], SPRITEY = ref[1];
      bashySpriteSheet = new createjs.SpriteSheet({
        images: [image],
        frames: {
          width: 64,
          height: 64
        },
        animations: {
          walking: [0, 4, "walking"],
          standing: [0, 0, "standing"]
        }
      });
      sprite = new createjs.Sprite(bashySpriteSheet, 0);
      sprite.name = "bashySprite";
      sprite.framerate = 4;
      sprite.gotoAndPlay("walking");
      sprite.currentFrame = 0;
      sprite.x = SPRITEX;
      sprite.y = SPRITEY;
      this.stage.addChild(sprite);
      return sprite;
    };

    DisplayManager.prototype.startTicker = function(stage) {
      var tick;
      tick = function(event) {
        return stage.update(event);
      };
      createjs.Ticker.addEventListener("tick", tick);
      createjs.Ticker.useRAF = true;
      createjs.Ticker.setFPS(15);
    };

    DisplayManager.prototype.calculateChildCoords = function(count, parentX, parentY) {
      var coords, i, startingX, xOffset, y, yOffset;
      yOffset = 80;
      xOffset = 100;
      startingX = parentX - 0.5 * count * xOffset;
      y = parentY + yOffset;
      coords = (function() {
        var j, ref, results;
        results = [];
        for (i = j = 0, ref = count - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          results.push([startingX + 2 * i * xOffset, y]);
        }
        return results;
      })();
      return coords;
    };

    DisplayManager.prototype.drawFile = function(map, file, x, y) {
      var ref, text;
      text = new createjs.Text(file.name(), "20px Arial", "black");
      text.name = file.path;
      ref = [x, y], text.x = ref[0], text.y = ref[1];
      text.textBaseline = "alphabetic";
      map.addChild(text);
    };

    DisplayManager.prototype.drawChildren = function(map, parent, parentX, parentY) {
      var child, childCoords, childX, childY, i, j, line, lineOffsetX, lineOffsetY, numChildren, ref;
      lineOffsetX = 20;
      lineOffsetY = 20;
      numChildren = parent.subdirectories.length;
      childCoords = this.calculateChildCoords(numChildren, parentX, parentY);
      for (i = j = 0, ref = numChildren - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        child = parent.subdirectories[i];
        childX = childCoords[i][0];
        childY = childCoords[i][1];
        if (child.subdirectories.length > 0) {
          this.drawChildren(map, child, childX, childY);
        }
        this.drawFile(map, child, childX, childY);
        line = new createjs.Shape();
        line.graphics.setStrokeStyle(1);
        line.graphics.beginStroke("gray");
        line.graphics.moveTo(parentX, parentY + lineOffsetY);
        line.graphics.lineTo(childX + lineOffsetX, childY - lineOffsetY);
        line.graphics.endStroke();
        map.addChild(line);
      }
    };

    return DisplayManager;

  })();

  jQuery(function() {
    var game;
    return game = new BashyGame();
  });

  BashyGame = (function() {
    function BashyGame() {
      this.handleInput = bind(this.handleInput, this);
      this.taskMgr = new TaskManager();
      this.os = new BashyOS();
      this.displayMgr = new DisplayManager();
      this.displayMgr.drawFileSystem(this.os.fileSystem);
      this.terminal = new Terminal(this.handleInput);
      $("#helpButton").click((function(_this) {
        return function() {
          return _this.help();
        };
      })(this));
    }

    BashyGame.prototype.help = function() {
      var currentHint;
      currentHint = this.taskMgr.currentTask.hints[0];
      return this.displayMgr.helpScreen(currentHint);
    };

    BashyGame.prototype.parseCommand = function(input) {
      var args, command, splitInput;
      input = input.replace(/^\s+|\s+$/g, "");
      splitInput = input.split(/\s+/);
      command = splitInput[0];
      args = splitInput.slice(1);
      return [command, args];
    };

    BashyGame.prototype.executeCommand = function(command, args) {
      var cwd, fs, ref, stderr, stdout;
      fs = this.os.fileSystem;
      ref = this.os.runCommand(command, args), cwd = ref[0], stdout = ref[1], stderr = ref[2];
      this.taskMgr.update(this.os);
      this.displayMgr.update(fs, cwd);
      if (stderr) {
        return stderr;
      } else if (stdout) {
        return stdout;
      } else {

      }
    };

    BashyGame.prototype.handleInput = function(input) {
      var args, command, ref;
      ref = this.parseCommand(input), command = ref[0], args = ref[1];
      return this.executeCommand(command, args);
    };

    return BashyGame;

  })();

}).call(this);
