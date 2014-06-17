define( ->
  fontStyle = { font: "20px Arial", fill: "#ffffff", align: "left" }

  class Hero
    expText = null
    healthText = null
    manaText = null

    set: (property, value) ->
      @[property] = value

    constructor: (@game, @phaser, @meta) ->
      @sprite = null
      @speed = 400
      @startOnScreenPos = 10

      @upKey = null
      @downKey = null
      @leftKey = null
      @rightKey = null
      
    preload: ->
      @game.load.spritesheet "roshan", "images/roshan.png", 32, 48

    create: ->
      @sprite = @game.add.sprite(@meta.x, @meta.y, "roshan")
      @game.physics.enable(@sprite, @phaser.Physics.ARCADE)
      @sprite.body.collideWorldBounds = true;
      @sprite.body.bounce.set(1)
      expText = @game.add.text(20, 10, "exp: #{@meta.exp}", fontStyle)
      healthText = @game.add.text(20, 30, "health: #{@meta.health}", fontStyle)
      mana = @game.add.text(20, 50, "mana: #{@meta.mana}", fontStyle)
     
      @sprite.animations.add "down", [0, 3], false
      @sprite.animations.add "left", [4, 7], false
      @sprite.animations.add "right", [8, 11], false
      @sprite.animations.add "up", [12, 15], false
      @_setControls()

    update: ->
      @sprite.body.velocity.x = 0
      @sprite.body.velocity.y = 0

      if @sprite.x < 0
        @sprite.x = @game.width - @startOnScreenPos
        @trigger('changeMap', 'left')

      if @sprite.x > @game.width
        @sprite.x = @startOnScreenPos
        @trigger('changeMap', 'right')

      if @sprite.y < 0
        @sprite.y = @game.height - @startOnScreenPos
        @trigger('changeMap', 'up')

      if @sprite.y > @game.height
        @sprite.y = @startOnScreenPos
        @trigger('changeMap', 'down')

      if @upKey.isDown
        @sprite.body.velocity.y = -@speed
        @sprite.animations.play "up", 5, false
        @actions.move 'up', @user, @mapId, @sprite.x, @sprite.y
      else if @downKey.isDown
        @sprite.body.velocity.y = @speed
        @sprite.animations.play "down", 5, false
        @actions.move 'down', @user, @mapId, @sprite.x, @sprite.y
      else if @leftKey.isDown
        @sprite.body.velocity.x = -@speed
        @sprite.animations.play "left", 5, false
        @actions.move 'left', @user, @mapId, @sprite.x, @sprite.y
      else if @rightKey.isDown
        @sprite.body.velocity.x = @speed
        @sprite.animations.play "right", 5, false
        @actions.move 'right', @user, @mapId, @sprite.x, @sprite.y

      @sprite.bringToTop()

      return

    _setControls: ->
      @upKey = @game.input.keyboard.addKey(Phaser.Keyboard.UP)
      @downKey = @game.input.keyboard.addKey(Phaser.Keyboard.DOWN)
      @leftKey = @game.input.keyboard.addKey(Phaser.Keyboard.LEFT)
      @rightKey = @game.input.keyboard.addKey(Phaser.Keyboard.RIGHT)

  return Hero
)