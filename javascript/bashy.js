// Generated by CoffeeScript 1.9.1
(function() {
  var BashyGame, BashyOS, Directory, DisplayManager, FileSystem, MenuManager, Task, TaskManager, Terminal, Zone,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Directory = (function() {
    function Directory(path1) {
      this.path = path1;
      this.children = [];
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
      ref = this.children;
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
    function FileSystem(zoneName) {
      var bashy, home, media, pics;
      if (zoneName === "nav") {
        this.root = new Directory("/");
        media = new Directory("/media");
        pics = new Directory("/media/pics");
        media.children.push(pics);
        this.root.children.push(media);
        home = new Directory("/home");
        bashy = new Directory("/home/bashy");
        home.children.push(bashy);
        this.root.children.push(home);
      } else {
        console.log("FileSystem instantiated with unknown zone name: " + zoneName);
      }
    }

    FileSystem.prototype.isValidPath = function(path) {
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

    return FileSystem;

  })();

  BashyOS = (function() {
    function BashyOS(zoneName) {
      this.pwd = bind(this.pwd, this);
      this.cd = bind(this.cd, this);
      this.cdAbsolutePath = bind(this.cdAbsolutePath, this);
      this.cdRelativePath = bind(this.cdRelativePath, this);
      this.runCommand = bind(this.runCommand, this);
      if (zoneName === "nav") {
        this.validCommands = ["cd", "pwd"];
        this.fileSystem = new FileSystem(zoneName);
      } else {
        console.log("BashyOS instantiated with unknown zone name: " + zoneName);
        this.validCommands = [];
        this.fileSystem = None;
      }
      this.cwd = this.fileSystem.root;
    }

    BashyOS.prototype.runCommand = function(command, args) {
      var ref, ref1, ref2, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      if (indexOf.call(this.validCommands, command) < 0) {
        stderr = "Invalid command: " + command;
      } else if (command === 'cd') {
        ref1 = this.cd(args), stdout = ref1[0], stderr = ref1[1];
      } else if (command === 'pwd') {
        ref2 = this.pwd(), stdout = ref2[0], stderr = ref2[1];
      }
      return [this.cwd.path, stdout, stderr];
    };

    BashyOS.prototype.cdRelativePath = function(path) {
      var absolutePath, ref, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      absolutePath = this.parseRelativePath(path, this.cwd.path);
      absolutePath = this.cleanPath(absolutePath);
      if (this.fileSystem.isValidPath(absolutePath)) {
        this.cwd = this.fileSystem.getDirectory(absolutePath);
      } else {
        stderr = "Invalid path: " + absolutePath;
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.cdAbsolutePath = function(path) {
      var absolutePath, ref, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      absolutePath = this.cleanPath(path);
      if (this.fileSystem.isValidPath(path)) {
        this.cwd = this.fileSystem.getDirectory(path);
      } else {
        stderr = "Invalid path";
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.cd = function(args) {
      var path, ref, ref1, ref2, stderr, stdout;
      ref = ["", ""], stdout = ref[0], stderr = ref[1];
      if (args.length === 0) {
        this.cwd = this.fileSystem.getDirectory("/home");
      } else if (args.length > 0) {
        path = args[0];
        if (path[0] === "/") {
          ref1 = this.cdAbsolutePath(path), stdout = ref1[0], stderr = ref1[1];
        } else {
          ref2 = this.cdRelativePath(path), stdout = ref2[0], stderr = ref2[1];
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

    BashyOS.prototype.cleanPath = function(path) {
      var dir, j, len1, newPath, splitPath;
      splitPath = path.split("/");
      newPath = "";
      for (j = 0, len1 = splitPath.length; j < len1; j++) {
        dir = splitPath[j];
        if (dir !== "") {
          newPath = newPath + "/" + dir;
        }
      }
      return newPath;
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

    BashyOS.prototype.parseRelativePath = function(relativePath, cwd) {
      var dir, fields, finished, newPath;
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

  MenuManager = (function() {
    function MenuManager() {}

    MenuManager.prototype.showTask = function(task) {
      $("#menu").html(task.name);
    };

    MenuManager.prototype.win = function() {
      $("#menuHeader").html("");
      $("#menu").html("<h4>You Win!</h4>");
    };

    return MenuManager;

  })();

  DisplayManager = (function() {
    function DisplayManager() {
      this.update = bind(this.update, this);
      var canvas, ref, ref1;
      canvas = $("#bashyCanvas")[0];
      this.stage = new createjs.Stage(canvas);
      ref = [130, 60], this.startingX = ref[0], this.startingY = ref[1];
      this.centeredOn = "/";
      this.map = new createjs.Container();
      this.map.name = "map";
      ref1 = [this.startingX, this.startingY], this.map.x = ref1[0], this.map.y = ref1[1];
      this.bashyImage = new Image();
      this.bashyImage.onload = (function(_this) {
        return function() {
          return _this.spriteLoaded();
        };
      })(this);
      this.bashyImage.src = "assets/bashy_sprite_sheet.png";
    }

    DisplayManager.prototype.spriteLoaded = function() {
      this.bashySprite = this.createBashySprite(this.bashyImage, this.stage);
      return this.startTicker(this.stage);
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

    DisplayManager.prototype.introScreen = function() {
      var introHtml;
      introHtml = "<h3>Welcome to B@shy!</h3>";
      introHtml += "<p>Use your keyboard to type commands.</p>";
      introHtml += "<p>Available commands are 'pwd' and 'cd'</p>";
      $('#helpText').html(introHtml);
      $('#helpScreen').foundation('reveal', 'open');
    };

    DisplayManager.prototype.helpScreen = function(hint) {
      var helpHtml;
      helpHtml = "<h3>B@shy Help</h3>";
      helpHtml += "<p>Hint: " + hint + "</p>";
      $('#helpText').html(helpHtml);
      $('#helpScreen').foundation('reveal', 'open');
    };

    DisplayManager.prototype.createBashySprite = function() {
      var SPRITEX, SPRITEY, bashySpriteSheet, ref, sprite;
      ref = [200, 50], SPRITEX = ref[0], SPRITEY = ref[1];
      bashySpriteSheet = new createjs.SpriteSheet({
        images: [this.bashyImage],
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
      numChildren = parent.children.length;
      childCoords = this.calculateChildCoords(numChildren, parentX, parentY);
      for (i = j = 0, ref = numChildren - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        child = parent.children[i];
        childX = childCoords[i][0];
        childY = childCoords[i][1];
        if (child.children.length > 0) {
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

  Zone = (function() {
    function Zone(displayMgr, taskMgr, os1) {
      this.displayMgr = displayMgr;
      this.taskMgr = taskMgr;
      this.os = os1;
      this.handleInput = bind(this.handleInput, this);
      $("#helpButton").click((function(_this) {
        return function() {
          return _this.displayMgr.helpScreen(_this.taskMgr.currentTask.hints[0]);
        };
      })(this));
    }

    Zone.prototype.run = function() {
      return this.displayMgr.drawFileSystem(this.os.fileSystem);
    };

    Zone.prototype.parseCommand = function(input) {
      var args, command, splitInput;
      input = input.replace(/^\s+|\s+$/g, "");
      splitInput = input.split(/\s+/);
      command = splitInput[0];
      args = splitInput.slice(1);
      return [command, args];
    };

    Zone.prototype.executeCommand = function(command, args) {
      var cwd, fs, ref, stderr, stdout;
      fs = this.os.fileSystem;
      ref = this.os.runCommand(command, args), cwd = ref[0], stdout = ref[1], stderr = ref[2];
      this.taskMgr.update(this.os);
      return this.displayMgr.update(fs, cwd);
    };

    Zone.prototype.handleInput = function(input) {
      var args, command, ref;
      ref = this.parseCommand(input), command = ref[0], args = ref[1];
      return this.executeCommand(command, args);
    };

    return Zone;

  })();

  BashyGame = (function() {
    function BashyGame() {
      this.taskMgr = new TaskManager();
      this.os = new BashyOS("nav");
      this.displayMgr = new DisplayManager();
      this.currentZone = new Zone(this.displayMgr, this.taskMgr, this.os);
      this.terminal = new Terminal(this.currentZone.handleInput);
      this.currentZone.run();
    }

    return BashyGame;

  })();

}).call(this);
