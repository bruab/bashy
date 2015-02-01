// Generated by CoffeeScript 1.8.0
(function() {
  var BashyOS, BashySprite, DisplayManager, MenuManager, Task, TaskManager, createBashySprite, drawFileSystemMap, drawLines, get_tasks, helpScreen, playIntro, showHomeText, showMediaText, showRootText, startTicker, validPath,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  validPath = function(path) {
    if (path === '/' || path === '/home' || path === '/media') {
      return true;
    } else {
      return false;
    }
  };

  BashyOS = (function() {
    BashyOS.prototype.cwd = '/';

    function BashyOS() {
      this.pwd = __bind(this.pwd, this);
      this.cd = __bind(this.cd, this);
      this.cd_absolute_path = __bind(this.cd_absolute_path, this);
      this.cd_relative_path = __bind(this.cd_relative_path, this);
      this.handleTerminalInput = __bind(this.handleTerminalInput, this);
    }

    BashyOS.prototype.handleTerminalInput = function(input) {
      var fields, stderr, stdout, _ref, _ref1, _ref2;
      _ref = ["", ""], stdout = _ref[0], stderr = _ref[1];
      fields = input.split(/\s+/);
      if (fields[0] === 'cd') {
        _ref1 = this.cd(fields), stdout = _ref1[0], stderr = _ref1[1];
      } else if (fields[0] === 'pwd') {
        _ref2 = this.pwd(), stdout = _ref2[0], stderr = _ref2[1];
      }
      return [this.cwd, stdout, stderr];
    };

    BashyOS.prototype.cd_relative_path = function(path) {
      var fields, newpath, stderr, stdout, x, _ref;
      _ref = ["", ""], stdout = _ref[0], stderr = _ref[1];
      newpath = "";
      fields = path.split("/");
      if (fields[0] === "..") {
        if (fields.length === 1) {
          this.cwd = "/";
        } else {
          newpath = "/";
          [
            (function() {
              var _i, _len, _ref1, _results;
              _ref1 = fields.slice(1, -1);
              _results = [];
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                x = _ref1[_i];
                _results.push(newpath += x + "/");
              }
              return _results;
            })()
          ];
          newpath += fields.slice(-1);
          if (validPath(newpath)) {
            this.cwd = newpath;
          } else {
            stderr = "Invalid path";
          }
        }
      } else {
        if (validPath(this.cwd + path)) {
          this.cwd = this.cwd + path;
        } else {
          stderr = "Invalid path";
        }
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.cd_absolute_path = function(path) {
      var stderr, stdout, _ref;
      _ref = ["", ""], stdout = _ref[0], stderr = _ref[1];
      if (validPath(path)) {
        this.cwd = path;
      } else {
        stderr = "Invalid path";
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.cd = function(args) {
      var path, stderr, stdout, _ref, _ref1, _ref2;
      _ref = ["", ""], stdout = _ref[0], stderr = _ref[1];
      if (args.length === 1) {
        this.cwd = '/home';
      } else if (args.length > 1) {
        path = args[1];
        if (path[0] === "/") {
          _ref1 = this.cd_absolute_path(path), stdout = _ref1[0], stderr = _ref1[1];
        } else {
          _ref2 = this.cd_relative_path(path), stdout = _ref2[0], stderr = _ref2[1];
        }
      }
      return [stdout, stderr];
    };

    BashyOS.prototype.pwd = function() {
      var stderr, stdout, _ref;
      _ref = ["", ""], stdout = _ref[0], stderr = _ref[1];
      stdout = this.cwd;
      return [stdout, stderr];
    };

    return BashyOS;

  })();

  DisplayManager = (function() {
    function DisplayManager(bashy_sprite) {
      this.bashy_sprite = bashy_sprite;
      this.update = __bind(this.update, this);
    }

    DisplayManager.prototype.update = function(new_dir) {
      return this.bashy_sprite.goToDir(new_dir);
    };

    return DisplayManager;

  })();

  BashySprite = (function() {
    function BashySprite(sprite) {
      this.sprite = sprite;
      this.sprite.x = 200;
      this.sprite.y = 50;
    }

    BashySprite.prototype.goToDir = function(dir) {
      if (dir === "/") {
        return this.goRoot();
      } else if (dir === "/home") {
        return this.goHome();
      } else if (dir === "/media") {
        return this.goMedia();
      }
    };

    BashySprite.prototype.goRoot = function() {
      this.sprite.x = 200;
      return this.sprite.y = 50;
    };

    BashySprite.prototype.goHome = function() {
      this.sprite.x = 80;
      return this.sprite.y = 180;
    };

    BashySprite.prototype.goMedia = function() {
      this.sprite.x = 390;
      return this.sprite.y = 180;
    };

    BashySprite.prototype.moveTo = function(x, y) {
      this.sprite.x = x;
      return this.sprite.y = y;
    };

    return BashySprite;

  })();

  MenuManager = (function() {
    function MenuManager() {}

    MenuManager.prototype.showTask = function(task) {
      var current_html;
      current_html = $("#menu").html();
      return $("#menu").html(current_html + "<p>" + task.name + "</p>");
    };

    return MenuManager;

  })();

  window.BashyOS = BashyOS;

  window.BashySprite = BashySprite;

  window.DisplayManager = DisplayManager;

  window.MenuManager = MenuManager;

  get_tasks = function() {
    var task1, task1_fn, task2, task2_fn, task3, task3_fn;
    task1_fn = function(os) {
      return os.cwd === "/home";
    };
    task2_fn = function(os) {
      return os.cwd === "/media";
    };
    task3_fn = function(os) {
      return os.cwd === "/";
    };
    task1 = new Task("navigate to home", ["type 'cd' and press enter"], task1_fn);
    task2 = new Task("navigate to /media", ["type 'cd /media' and press enter"], task2_fn);
    task3 = new Task("navigate to root", ["type 'cd /' and press enter"], task3_fn);
    return [task1, task2, task3];
  };

  TaskManager = (function() {
    function TaskManager(menu_mgr) {
      var task, _i, _len, _ref;
      this.menu_mgr = menu_mgr;
      this.tasks = get_tasks();
      _ref = this.tasks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        task = _ref[_i];
        this.menu_mgr.showTask(task);
      }
    }

    TaskManager.prototype.update = function(os) {
      var all_complete, task, _i, _len, _ref;
      all_complete = true;
      _ref = this.tasks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        task = _ref[_i];
        if (!task.done(os)) {
          alert("uncompleted task: " + task.name);
          all_complete = false;
        }
      }
      if (all_complete) {
        return alert("you win");
      }
    };

    return TaskManager;

  })();

  Task = (function() {
    function Task(name, hints, complete_fn) {
      this.name = name;
      this.hints = hints;
      this.complete_fn = complete_fn;
      this.is_complete = false;
    }

    Task.prototype.done = function(os) {
      if (this.is_complete) {
        return true;
      } else {
        this.is_complete = this.complete_fn(os);
        return this.is_complete;
      }
    };

    return Task;

  })();

  window.TaskManager = TaskManager;

  playIntro = function() {
    var intro_html;
    intro_html = "<h3>Welcome to B@shy!</h3>";
    intro_html += "<p>Use your keyboard to type commands.</p>";
    intro_html += "<p>Available commands are 'pwd' and 'cd'</p>";
    $('#help_text').html(intro_html);
    return $('#helpScreen').foundation('reveal', 'open');
  };

  helpScreen = function() {
    var help_html;
    help_html = "<h3>B@shy Help</h3>";
    help_html += "TODO contextual help messages";
    $('#help_text').html(help_html);
    return $('#helpScreen').foundation('reveal', 'open');
  };

  this.BashyOS = (function() {
    function BashyOS() {}

    return BashyOS;

  })();

  this.BashySprite = (function() {
    function BashySprite() {}

    return BashySprite;

  })();

  this.FileSystem = (function() {
    function FileSystem() {}

    return FileSystem;

  })();

  this.DisplayManager = (function() {
    function DisplayManager() {}

    return DisplayManager;

  })();

  this.TaskManager = (function() {
    function TaskManager() {}

    return TaskManager;

  })();

  this.MenuManager = (function() {
    function MenuManager() {}

    return MenuManager;

  })();

  showRootText = function(stage) {
    var rootText;
    rootText = new createjs.Text("/", "20px Arial", "black");
    rootText.x = 250;
    rootText.y = 120;
    rootText.textBaseline = "alphabetic";
    return stage.addChild(rootText);
  };

  showHomeText = function(stage) {
    var homeText;
    homeText = new createjs.Text("/home", "20px Arial", "black");
    homeText.x = 140;
    homeText.y = 235;
    homeText.textBaseline = "alphabetic";
    return stage.addChild(homeText);
  };

  showMediaText = function(stage) {
    var mediaText;
    mediaText = new createjs.Text("/media", "20px Arial", "black");
    mediaText.x = 340;
    mediaText.y = 235;
    mediaText.textBaseline = "alphabetic";
    return stage.addChild(mediaText);
  };

  drawLines = function(stage) {
    var line1, line2;
    line1 = new createjs.Shape();
    line1.graphics.setStrokeStyle(1);
    line1.graphics.beginStroke("gray");
    line1.graphics.moveTo(255, 125);
    line1.graphics.lineTo(350, 220);
    line1.graphics.endStroke();
    stage.addChild(line1);
    line2 = new createjs.Shape();
    line2.graphics.setStrokeStyle(1);
    line2.graphics.beginStroke("gray");
    line2.graphics.moveTo(245, 125);
    line2.graphics.lineTo(150, 220);
    line2.graphics.endStroke();
    return stage.addChild(line2);
  };

  drawFileSystemMap = function(stage) {
    showRootText(stage);
    showHomeText(stage);
    showMediaText(stage);
    return drawLines(stage);
  };

  createBashySprite = function(bashy_himself, stage) {
    var bashySpriteSheet, bashy_sprite, sprite;
    bashySpriteSheet = new createjs.SpriteSheet({
      images: [bashy_himself],
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
    sprite.gotoAndPlay("walking");
    sprite.currentFrame = 0;
    stage.addChild(sprite);
    return bashy_sprite = new BashySprite(sprite);
  };

  startTicker = function(stage) {
    var tick;
    tick = function() {
      return stage.update();
    };
    createjs.Ticker.addEventListener("tick", tick);
    createjs.Ticker.useRAF = true;
    return createjs.Ticker.setFPS(5);
  };

  jQuery(function() {
    var bashy_himself, canvas, handleFileLoad, playOops, playSound, playSounds, playTheme, seenIntro, soundOff, stage, startGame;
    canvas = $("#bashy_canvas")[0];
    stage = new createjs.Stage(canvas);
    bashy_himself = new Image();
    bashy_himself.onload = function() {
      return startGame();
    };
    bashy_himself.src = "assets/bashy_sprite_sheet.png";
    playSounds = true;
    soundOff = function() {
      playSounds = false;
      return createjs.Sound.stop();
    };
    playSound = function() {
      if (playSounds) {
        if (Math.random() < 0.5) {
          return createjs.Sound.play("boing1");
        } else {
          return createjs.Sound.play("boing2");
        }
      }
    };
    playOops = function() {
      if (playSounds) {
        return createjs.Sound.play("oops");
      }
    };
    playTheme = function() {
      return createjs.Sound.play("bashy_theme1", createjs.SoundJS.INTERRUPT_ANY, 0, 0, -1, 0.5);
    };
    handleFileLoad = (function(_this) {
      return function(event) {
        console.log("Preloaded:", event.id, event.src);
        if (event.id === "bashy_theme1") {
          playTheme();
          return soundOff();
        }
      };
    })(this);
    createjs.Sound.addEventListener("fileload", handleFileLoad);
    createjs.Sound.alternateExtensions = ["mp3"];
    createjs.Sound.registerManifest([
      {
        id: "boing1",
        src: "boing1.mp3"
      }, {
        id: "boing2",
        src: "boing2.mp3"
      }, {
        id: "oops",
        src: "oops.mp3"
      }, {
        id: "bashy_theme1",
        src: "bashy_theme1.mp3"
      }
    ], "assets/");
    $("#audio_off").click(soundOff);
    seenIntro = false;
    $("#playScreen").click(function() {
      if (!seenIntro) {
        playIntro();
        return seenIntro = true;
      } else {
        return helpScreen();
      }
    });
    return startGame = function() {
      var bashy_sprite, display_mgr, handleInput, menu_mgr, os, task_mgr;
      drawFileSystemMap(stage);
      bashy_sprite = createBashySprite(bashy_himself, stage);
      startTicker(stage);
      os = new BashyOS();
      display_mgr = new DisplayManager(bashy_sprite);
      menu_mgr = new MenuManager();
      task_mgr = new TaskManager(menu_mgr);
      handleInput = function(input) {
        var cwd, stderr, stdout, _ref;
        _ref = os.handleTerminalInput(input), cwd = _ref[0], stdout = _ref[1], stderr = _ref[2];
        task_mgr.update(os);
        display_mgr.update(cwd);
        if (stderr) {
          playOops();
          return stderr;
        } else {
          playSound();
          if (stdout) {
            return stdout;
          } else {
            return void 0;
          }
        }
      };
      return $('#terminal').terminal(handleInput, {
        greetings: "",
        prompt: '> ',
        onBlur: false,
        name: 'test'
      });
    };
  });

}).call(this);
